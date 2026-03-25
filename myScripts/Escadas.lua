setDefaultTab("Tools")

excludeIds = excludeIds or {
    12099,
    17393
};

stairsIds = stairsIds or {
    1666,
    6207,
    1948,
    435,
    7771,
    5542,
    8657,
    6264,
    1646,
    1648,
    1678,
    5291,
    1680,
    6905,
    6262,
    1664,
    13296,
    1067,
    13861,
    11931,
    1949,
    6896,
    6205,
    13926,
    1947,
    12097,
    13369, 
    13891, 
    13892, 
    13895, 
    11932, 
    13369,
    11932,
	615,
	1678, -- DOOR
	8367, -- DOOR
};

updateIds = function()
	excludeIds = {};
	stairsIds = {};
	
	
	for _, value in ipairs(storage.stairsIds) do
		stairsIds[value.id] = true;
	end
	
	for _, value in ipairs(storage.excludeIds) do
		excludeIds[value.id] = true;
	end
	
	-- info(json.encode(storage.stairsIds));
end

if (not stairsIdContainer) then
	UI.Label('Escadas & Portas')
	
	local stairsCallback = function(widget, items)
		storage.stairsIds = items;
		updateIds();
	end
	
	stairsIdContainer = UI.Container(stairsCallback, true);


	storage.stairsIds = storage.stairsIds or stairsIds;
	stairsIdContainer:setItems(storage.stairsIds);
	stairsIdContainer:setHeight(35);

end

if (not excludeIdsContainer) then
	UI.Label('Ids excluidos');
	
	local excludeCallback = function(widget, items)
		storage.excludeIds = items;
		updateIds();
	end
	
	excludeIdsContainer = UI.Container(excludeCallback, true);
	
	
	storage.excludeIds = storage.excludeIds or excludeIds;
	excludeIdsContainer:setItems(storage.excludeIds);
	excludeIdsContainer:setHeight(35);

end

updateIds();

--Escadas
Stairs = {}

Stairs.checkTile = function(tile)
    if (not tile) then return; end

    local tilePos = tile:getPosition();

    if (not tilePos) then return; end

    -- if (not tile:isWalkable()) then return; end

    local tileItems = tile:getItems();

    for _, item in ipairs(tileItems) do
        if excludeIds[item:getId()] then return; end
    end
	
	for _, item in ipairs(tileItems) do
        if stairsIds[item:getId()] then return true; end
    end

    -- if stairsIds[topThing:getId()] then
        -- return true;
    -- end

    local cor = g_map.getMinimapColor(tilePos);
    if (cor >= 210 and cor <= 213 and not tile:isPathable() and tile:isWalkable()) then
        return true;
    end
end

Stairs.postostring = function(pos)
    return pos.x .. "," .. pos.y .. "," .. pos.z;
end

Stairs.getDistance = function(p1, p2)

    local distx = math.abs(p1.x - p2.x);
    local disty = math.abs(p1.y - p2.y);

    return math.sqrt(distx * distx + disty * disty);
end

Stairs.nextPosition = {
    {x = 0, y = -1},
    {x = 1, y = 0},
    {x = 0, y = 1},
    {x = -1, y = 0},
    {x = 1, y = -1},
    {x = 1, y = 1},
    {x = -1, y = 1},
    {x = -1, y = -1}
}

Stairs.getPosition = function(pos, dir)
    local nextPos = Stairs.nextPosition[dir + 1]

    pos.x = pos.x + nextPos.x
    pos.y = pos.y + nextPos.y

    return pos
end

Stairs.reverseDirection = {
    2,
    3,
    0,
    1,
    6,
    7,
    4,
    5
}

function Stairs.doReverse(dir)
    return Stairs.reverseDirection[dir + 1]
end

Stairs.markOnThing = function(thing, color)
    if thing then
        local useThing = thing:getItems()[#thing:getItems()]
        if not useThing then
            if color == "#00FF00" then
                thing:setText("AQUI", "green")
            elseif color == "#FF0000" then
                thing:setText("AQUI", "red")
            else
                thing:setText("")
            end
        else
            useThing:setMarked(color)
        end
    end
end

Stairs.verifyTiles = function(pos)
    pos = pos or player:getPosition();
    local nearestTile;
    local tiles = g_map.getTiles(pos.z);
    for i = 1, #tiles do
        local tile = tiles[i];
		local tilePos = tile:getPosition();
		if (tilePos) then
			local distance = Stairs.getDistance(pos, tilePos);
			if (not nearestTile or nearestTile.distance > distance) then
				if (Stairs.checkTile(tile)) then
					if (getDistanceBetween(tilePos, pos) == 1 or findPath(tilePos, pos)) then
						nearestTile = {
							tile = tile,
							tilePos = tilePos,
							distance = distance
						};
						Stairs.markOnThing(Stairs.actualTile);
						Stairs.actualTile, Stairs.actualPos = tile, tilePos;
					end
				end
			end
		end
    end
    Stairs.hasVerified = true
end

Stairs.goUse = function(pos)
    local playerPos = player:getPosition();
    local path = findPath(pos, playerPos, 100);
    if (not path) then return; end
	local kunaiThing;
    for i = 1, #path do
        if i > 5 then break; end
        local direction = path[#path - (i - 1)];
        local nextDirection = Stairs.doReverse(direction);
        playerPos = Stairs.getPosition(playerPos, nextDirection);
		local tmpTile = g_map.getTile(playerPos);
		if (tmpTile and tmpTile:isWalkable(true) and tmpTile:isPathable() and tmpTile:canShoot()) then
			kunaiThing = tmpTile:getTopThing();
		end
    end
    local tile = g_map.getTile(playerPos);
    local topThing = tile and tile:getTopUseThing();
    if (topThing) then
		local distance = getDistanceBetween(playerPos, player:getPosition())
		if (distance > 1 and storage.useKunai and storage.kunaiId and kunaiThing) then
			--g_game.stop();
			useWith(storage.kunaiId, kunaiThing);
		end
		use(topThing);
		-- end
    end
end

local standing = now;

onPlayerPositionChange(function(newPos, oldPos)
    Stairs.tryWalk = nil;
    Stairs.tryToStep = nil;
    schedule(50, function()
        Stairs.hasVerified = nil;
    end)
end)

isKeyPressed = modules.corelib.g_keyboard.isKeyPressed;


g_game.disableFeature(37);

Stairs.doWalk = function()
    if (not Stairs.tryToStep and autoWalk(Stairs.actualPos, 1)) then
        Stairs.tryToStep = true;
    end
    Stairs.goUse(Stairs.actualPos);
    Stairs.isTrying = true;
end

local isMobile = modules._G.g_app.isMobile();

setDefaultTab("Main")
Stairs.macro = macro(1, "Auto Escadas", function()
    if (Stairs.actualPos) then
        Stairs.actualTile = g_map.getTile(Stairs.actualPos);
    end
    if (isKeyPressed(not isMobile and "Space" or "F1")) then
        -- if (not isMobile and not modules.game_walking.wsadWalking) then
            -- modules.game_textmessage.displayFailureMessage('Desative o chat para usar o auto-stairs.');
        if (Stairs.actualTile and Stairs.actualPos.z == pos().z) then
            Stairs.markOnThing(Stairs.actualTile, "#00FF00");
            Stairs.doWalk();
        elseif (not Stairs.hasVerified) then
            Stairs.verifyTiles(pos());
        else
            modules.game_textmessage.displayFailureMessage('Sem escadas por perto.');
        end
    else
        if (Stairs.isTrying) then
            Stairs.isTrying = nil;
			player:lockWalk(100);
            for i = 1, 10 do
                -- player:stopAutoWalk();
                g_game.stop();
            end
        end
        Stairs.markOnThing(Stairs.actualTile);
        Stairs.hasVerified = nil;
        Stairs.actualTile = nil;
        Stairs.actualPos = nil;
    end
end)