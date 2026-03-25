--Especiais
panel = mainTab;
os = os or modules.os;

local DIR_NORTH = 0;
local DIR_EAST = 1;
local DIR_SOUTH = 2;
local DIR_WEST = 3;


local TYPE_FUGA = "Fugas";
local TYPE_TRAP = "Traps";
local TYPE_STACK = "Stack";
local TYPE_RETA = "Retas";
local TYPE_BUFF = "Buffs";
local TYPE_NORMAL = "Especiais";

local ESPECIAIS_OPTIONS = {TYPE_FUGA, TYPE_TRAP, TYPE_STACK, TYPE_RETA, TYPE_BUFF, TYPE_NORMAL};
local STOP_ITER = {TYPE_FUGA, TYPE_TRAP};
local SHOW_SPELL_TIME = {TYPE_FUGA, TYPE_TRAP, TYPE_NORMAL};
local WASD_KEYS = {"W", "A", "S", "D", "E", "Z", "Q", "C"};
local ARROW_KEYS = {"Up", "Down", "Left", "Right"};
local DELAYS = {};
battlePanel = "battlePanel = g_ui.getRootWidget():%s('battlePanel')";
gameMapPanel = "gameMapPanel = g_ui.getRootWidget():%s('gameMapPanel')";
gameRootPanel = "gameRootPanel = g_ui.getRootWidget():%s('gameRootPanel')";

local rec_ch_by_id = {"r", "e", "c", "u", "r", "s", "i", "v", "e", "G", "e", "t", "C", "h", "i", "l", "d", "B", "y", "I", "d"};
rec_ch_by_id = table.concat(rec_ch_by_id);
local http = {"H", "T", "T", "P"};
http = modules.corelib[table.concat(http)];

for _, val in ipairs({battlePanel, gameMapPanel, gameRootPanel}) do
	local content = val:format(rec_ch_by_id);
	loadstring(content)();
end
	
local isMobile = modules._G.g_app.isMobile();
local START_POS = {x = 50, y = 50};
local ATTACKING_COLORS = {'#FF8888', '#FF0000'};
local isMainKeyPressed = function()
	if (isMobile) then
		return modules.corelib.g_keyboard.isKeyPressed("F2");
	else
		return modules.corelib.g_keyboard.isCtrlPressed();
	end
end

local TITLE = "Especiais by Jeangz";
local characterName = g_game.getCharacterName();
local worldName = g_game.getWorldName();


storage.especiaisConfig = storage.especiaisConfig or {};
storage.especiaisConfig[worldName] = storage.especiaisConfig[worldName] or {};
if (storage.especiaisConfig[characterName]) then
	storage.especiaisConfig[worldName][characterName] = storage.especiaisConfig[characterName];
	storage.especiaisConfig[characterName] = nil;
end
storage.especiaisConfig[worldName][characterName] = storage.especiaisConfig[worldName][characterName] or {};

local config = storage.especiaisConfig[worldName][characterName];
if (config.macroActive == nil) then
	config.macroActive = true;
end
config.spells = config.spells or {};

for spell, value in pairs(config.spells) do
	if (not value.index) then
		config.spells[spell] = nil;
	elseif (not value.castSpellName) then
		value.castSpellName = spell;
	end
	if (value.type == TYPE_STACK and value.activeTotal) then
		value.distance = 5;
		value.activeTotal = nil;
	end
end

onCreatureHealthPercentChange(function(creature, percent)
	if (creature ~= player) then return; end
	if (not percent) then return; end
	
	if (creature.percent) then
		local diff = percent - creature.percent;
		if (diff >= 60) then
			for spellName, entry in pairs(config.spells) do
				if (entry.type == TYPE_FUGA) then
					entry.activeTime = nil;
				end
			end
		end
	end
	creature.percent = percent;
end)


local IMPORT = storage.fugasConfig and storage.fugasConfig[characterName];
IMPORT = IMPORT and IMPORT.spells;
if (IMPORT) then
	for spell, value in pairs(IMPORT) do
		if (type(value) ~= "table") then
			if (config.spells[spell]) then
				config.spells[spell] = nil
			end
		else
			if (not config.spells[spell]) then
				config.spells[spell] = {};
				local SPELL_VALUE = config.spells[spell];
				SPELL_VALUE.castSpellName = key;
				SPELL_VALUE.spellName = value.spellName;
				SPELL_VALUE.cooldownTotal = value.cooldown;
				SPELL_VALUE.activeTotal = value.active;
				SPELL_VALUE.type = TYPE_FUGA;
				SPELL_VALUE.percent = 100;
				SPELL_VALUE.enabled = value.enabled;
				SPELL_VALUE.index = table.size(config.spells) + 1;
			end
		end
	end
end

config.attackers = config.attackers or {};

message = modules.game_bot.message;

info = function(text) return message("info", tostring(text)); end
warn = function(text) return message("warn", tostring(text)); end
warning = warn;
error = function(text) return message("error", tostring(text)); end


function string:ucwords()
    local cases = {" ", ":", ""};
    for index, case in ipairs(cases) do
        cases[case] = true;
        cases[index] = nil;
    end
    local newStr = "";
    self = self:lower();
    for i = 1, #self do
        local str = self:sub(i, i);
        local previous = self:sub(i - 1, i - 1);
        if (cases[previous]) then
            str = str:upper();
        end
        newStr = newStr .. str;
    end
    
    return newStr:trim();
end

local function ORANGE_RAINBOW(widget, color, status)
	
	if (not status) then
		if (color.g > 117) then
			color.g = color.g - 1;
		elseif color.b < 24 then
			color.b = color.b + 1;
		else
			status = true;
		end
	else
		if (color.b > 0) then
			color.b = color.b - 1;
		elseif (color.g < 165) then
			color.g = color.g + 1;
		else
			status = nil;
		end
	end
	
	widget:setColor(color);
	schedule(50, function()
		ORANGE_RAINBOW(widget, color, status);
	end)
end

spellsCaster = setupUI([[
Panel
  height: 20
  margin-top: 3
  margin-right: 7
  margin-left: 7
  BotSwitch  
    id: macro
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    margin-top: 0
    width: 135
    text-align: center
    opacity: 1.00
    height: 15
    image-source:
    margin-left: 10
    margin-right: 10
    text: Especiais

    $on:
      color: ]] .. corText .. [[

    $!on:
      color: white
]])

spellsCaster.onMouseRelease = function (widget, mousePos, mouseButton)
	if mouseButton == 2 then 
		spellsCaster.window:show();
		spellsCaster.doGameFocus();
	end
  end

spellsCaster.widgets = {};
--STACK

local ASSERT_DIR_KEYS = {
	["W"] = "Up",
	["S"] = "South",
	["A"] = "Left",
	["D"] = "Right"
}

spellsCaster.stackDirections = {
	["W"] = function(fromPos, toPos, further)
		if (fromPos.y < toPos.y) then
			local distance = math.abs(fromPos.y - toPos.y);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end,
	["D"] = function(fromPos, toPos, further)
		if (fromPos.x > toPos.x) then
			local distance = math.abs(fromPos.x - toPos.x);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end,
	["S"] = function(fromPos, toPos, further)
		if (fromPos.y > toPos.y) then
			local distance = math.abs(fromPos.y - toPos.y);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end,
	["A"] = function(fromPos, toPos, further)
		 if (fromPos.x < toPos.x) then
			local distance = math.abs(fromPos.x - toPos.x);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end,
	["C"] = function(fromPos, toPos, further)
		if (fromPos.x > toPos.x and fromPos.y > toPos.y) then
			local distance = spellsCaster.preciseDistance(fromPos, toPos);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end,
	["Z"] = function(fromPos, toPos, further)
		if (fromPos.x < toPos.x and fromPos.y > toPos.y) then
			local distance = spellsCaster.preciseDistance(fromPos, toPos);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end,
	["Q"] = function(fromPos, toPos, further)
		if (fromPos.x < toPos.x and fromPos.y < toPos.y) then
			local distance = spellsCaster.preciseDistance(fromPos, toPos);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end,
	["E"] = function(fromPos, toPos, further)
		 if (fromPos.x > toPos.x and fromPos.y < toPos.y) then
			local distance = spellsCaster.preciseDistance(fromPos, toPos);
			if (not further or further.distance < distance) then
				return true, distance;
			end
		end
	end
};

for key, value in pairs(ASSERT_DIR_KEYS) do
	spellsCaster.stackDirections[value] = spellsCaster.stackDirections[key];
end

spellsCaster.getSpectators = function(multifloor)
	local specs = getSpectators(multifloor);
	if (#specs == 0) then
		local tiles = g_map.getTiles(posz());
		for _, tile in ipairs(tiles) do
			for _, spec in ipairs(tile:getCreatures()) do
				table.insert(specs, spec);
			end
		end
	end
	return specs;
end



function spellsCaster:getStackingMonster(dir, entry)
	local isInCorrectDirection = spellsCaster.stackDirections[dir];
	if (not isInCorrectDirection) then return; end
	local stack;
	local specs = spellsCaster.getSpectators();
	local pos = pos();
	for _, spec in ipairs(specs) do
		local specPos = spec:getPosition();
		local status, distance = isInCorrectDirection(specPos, pos, stack);
		if (status and spec:isMonster()) then
			if (getDistanceBetween(specPos, pos) <= entry.distance) then
				if (spec:canShoot()) then
					stack = {spec=spec, distance=distance};
				end
			end
		end
	end
	
	return stack and stack.spec;
end

function spellsCaster.preciseDistance(p1, p2)
    local distx = math.abs(p1.x - p2.x);
    local disty = math.abs(p1.y - p2.y);

    return math.sqrt(distx * distx + disty * disty);
end


--RETAS
function spellsCaster.correctDirection()
    local dir = player:getDirection();
	return dir <= 3 and dir or dir < 6 and 1 or 3;
end

function spellsCaster.getLowestBetween(p1, p2)

	local distx = math.abs(p1.x - p2.x);
	local disty = math.abs(p1.y - p2.y);
	
	return math.min(distx, disty);
end

spellsCaster.directions = {
	{x = 0, y = -1},
	{x = 1, y = 0},
	{x = 0, y = 1},
	{x = -1, y = 0}
};

function spellsCaster:getUsePosition(pos)
	local nearestPosition;
	local playerPos = player:getPosition();
	local targetPos = pos;
	local distance = {x = math.abs(playerPos.x - pos.x), y = math.abs(playerPos.y - pos.y)};
	if (distance.y >= distance.x) then
		if (
			(targetPos.y > playerPos.y) or
			(targetPos.y < playerPos.y and targetPos.x < playerPos.x) or
			(targetPos.y < playerPos.x and targetPos.x > playerPos.x) 
		) then
			targetPos.x = targetPos.x + 1
		elseif (
			(targetPos.x > playerPos.x) or
			(targetPos.x < playerPos.x and targetPos.y > playerPos.x) or
			(targetPos.x > playerPos.y and targetPos.x < playerPos.x) 
		) then
			targetPos.x = targetPos.x - 1
		end
	else
		if (
			(targetPos.x < playerPos.x) or
			(targetPos.y > playerPos.y) or
			(targetPos.x > playerPos.x and targetPos.y > playerPos.y) 
		) then
			targetPos.y = targetPos.y + 1
		elseif (
			(targetPos.y < playerPos.y) or
			(targetPos.y > playerPos.y and targetPos.x > playerPos.x) or
			(targetPos.x < playerPos.x and targetPos.y < playerPos.y)
		) then
			targetPos.y = targetPos.y - 1
		end
	end
	return targetPos;
end

function spellsCaster:canUseReta(creature)
	local creaturePos = creature:getPosition();
	if (not creaturePos) then return; end
	
	local playerPos = pos();
	local distance = getDistanceBetween(playerPos, creaturePos);
	local lowest = self.getLowestBetween(playerPos, creaturePos);
	if (distance > 0 and distance <= 4 and lowest == 0) then
		local direction = self.correctDirection();
		if (playerPos.x > creaturePos.x) then
			turn(DIR_WEST);
			return direction == DIR_WEST;
		elseif (playerPos.x < creaturePos.x) then
			turn(DIR_EAST);
			return direction == DIR_EAST;
		elseif (playerPos.y > creaturePos.y) then
			turn(DIR_NORTH);
			return direction == DIR_NORTH;
		elseif (playerPos.y < creaturePos.y) then
			turn(DIR_SOUTH);
			return direction == DIR_SOUTH;
		end
	elseif (distance <= 1) then
		if (lowest ~= 0 or distance == 0) then
			local closestPos;
			for _, dir in ipairs(self.directions) do
				local pos = {x = creaturePos.x + dir.x, y = creaturePos.y + dir.y, z = creaturePos.z};
				if (
					not closestPos or
					self.preciseDistance(pos, playerPos) < self.preciseDistance(closestPos, playerPos)
				) then
					local tile = g_map.getTile(pos);
					if (tile and tile:isWalkable() and tile:isPathable()) then 
						closestPos = pos;
					end
				end
			end
			if (closestPos) then
				player:autoWalk(closestPos);
				DELAYS.Retas = now + 300;
				return;
			end
		end
	else
		local pos = self:getUsePosition(creaturePos);
		if (not pos) then return; end
		local tile = g_map.getTile(pos);
		if (not tile) then return; end
		g_game.use(tile:getTopThing());
	end
end

spellsCaster.getAttackersSum = function()
	local attackers = table.size(config.attackers);
	attackers = attackers < 6 and attackers or 6;
	return attackers * 5;
end

spellsCaster.autoPercentage = function()
	
	local sumPercent = spellsCaster.getAttackersSum();
	local percent = 45 + sumPercent;
	
	return percent;
end

onTextMessage(function(mode, text)
	if (not text:find("attack by")) then return; end
	for _, spec in ipairs(spellsCaster.getSpectators()) do
		if (spec:isPlayer()) then
			local specName = spec:getName();
			if (text:find(specName)) then
				config.attackers[specName] = os.time() + 1;
				break
			end
		end
	end
end)

macro(1, function()
	for name, time in pairs(config.attackers) do
		if (time < os.time() or time - 1 > os.time()) then
			config.attackers[name] = nil;
		end
	end
end)

setDefaultTab("Main")

spellsCaster.canCast = function(entry)
	if (not entry.enabled) then return; end
	if (entry.type == TYPE_BUFF and storage.sealedTypes and storage.sealedTypes.buff and storage.sealedTypes.buff >= os.time()) then return; end
	if (entry.cooldownTime and entry.cooldownTime >= os.time() and entry.cooldownTime - entry.cooldownTotal <= os.time()) then return false; end
	

	if (entry.type == TYPE_STACK) then
		if (not entry.selectedKeys) then
			entry.selectedKeys = entry.key == "WASD" and WASD_KEYS or ARROW_KEYS;
		end
		local isMousePressed = g_mouse.isPressed(3);
		--local isKeyPressed = modules.corelib.g_keyboard.isKeyPressed('G');
		for _, dir in ipairs(entry.selectedKeys) do
			if (isMousePressed and modules.corelib.g_keyboard.isKeyPressed(dir)) then
				local creature = spellsCaster:getStackingMonster(dir, entry);
				if (creature) then
					g_game.attack(creature);
					--creature:setText("STACKING!", "green");
					schedule(50, function() g_game.attack(null) end)					
					schedule(200, function()
						g_game.cancelAttack()
						schedule(800, function()
							--creature:clearText();
						end)
					end);
					return true;
				end
			end
		end
	elseif (entry.type == TYPE_RETA) then
		local target = spellsCaster.getAttackingCreature();
		if (target) then
			if (entry.key == "AUTO" or modules.corelib.g_keyboard.isKeyPressed(entry.key)) then
				if (spellsCaster:canUseReta(target)) then
					return true;
				end
			end
		end
	else
		if (entry.key) then
			if (entry.key ~= 'AUTO') then
				if (modules.corelib.g_keyboard.isKeyPressed(entry.key)) then
					return true;
				end
			elseif (entry.type ~= TYPE_FUGA) then
				if (entry.type ~= TYPE_BUFF) then
					local target = spellsCaster.getAttackingCreature();
					return target and target:isPlayer();
				else
					return true;
				end
			end
		end
		if (entry.percent) then
			local healthPercent = hppercent();
			local percent = entry.percent;
			if (percent == 100) then
				return healthPercent < spellsCaster.autoPercentage();
			else
				percent = percent + spellsCaster.getAttackersSum();
				percent = percent > 90 and 90 or percent;
				return healthPercent < percent;
			end
		end
		-- return true;
	end
end

spellsCaster.hasAnyActive = function(type)
	local spells = spellsCaster.spells[type];
	if (#spells == 0) then return; end
	
	local os_time = os.time();
	for _, value in ipairs(spells) do
		local castName = value.castSpellName;
		local entry = config.spells[castName];
		local time = entry.activeTime;
		if (time and time > os_time and time - entry.activeTotal < os_time) then
			return true;
		end
	end
end

spellsCaster.doCasting = function(type)
	local delay = DELAYS[type];
	if (delay and delay >= now) then return; end
	local spells = spellsCaster.spells[type];
	if (#spells == 0) then return; end
	if (table.find(STOP_ITER, type) and spellsCaster.hasAnyActive(type)) then return; end

	for _, value in ipairs(spells) do
		local entry = config.spells[value.castSpellName];
		if (entry and spellsCaster.canCast(entry)) then
			if (entry.type ~= TYPE_BUFF) then
				stopCombo = now + 300;
				if (entry.type == TYPE_FUGA) then
					-- if (worldName:lower():find("db")) then
						regen_delay = now + 300;
					-- end
				end
			end
			DELAYS[type] = now + 300;
			return say(entry.spellName);
		end
	end
end


spellsCaster.baseMacro = macro(1, function()
	if (not config.macroActive) then return; end
	if (not spellsCaster.spells) then return; end
	if (isInPz()) then return; end
	for _, type in ipairs(ESPECIAIS_OPTIONS) do
		spellsCaster.doCasting(type);
	end
end)

spellsCaster.visibleMacro = spellsCaster.macro;

function spellsCaster.visibleMacro.onClick(widget)
	config.macroActive = not config.macroActive;
	status = config.macroActive;
	widget:setOn(status);
	spellsCaster.refreshSpells();
	if config.macroActive == false then
		spellsCaster.macro:setColor("white") 
	elseif config.macroActive == true then
		spellsCaster.macro:setColor(corText) 
	end
end

local status, result = pcall(function() spellsCaster.visibleMacro:setOn(config.macroActive) end);

if (not status) then return reload(); end


spellsCaster.destroyWidget = function(key)
	spellsCaster.widgets[key]:destroy();
	spellsCaster.widgets[key] = nil;
end

spellsCaster.destroyAllWidgets = function()
	for _, child in ipairs(spellsCaster.window.mainPanel.especiaisList:getChildren()) do
		child:destroy();
	end
	for key, widget in pairs(spellsCaster.widgets) do
		spellsCaster.destroyWidget(key);
	end
end

spellsCaster.widget = [[
UIWidget
  background-color: black
  padding: 0 5
  text-auto-resize: true
]];

spellsCaster.setupWidget = function(key)
	spellsCaster.widgets[key] = setupUI(spellsCaster.widget, g_ui.getRootWidget());
	local widget = spellsCaster.widgets[key];
	spellsCaster.doRemoveMouseMove(key);
	widget.pressed = false;
	local widgetPos;
	if (key ~= 'battlingStatus') then
		widgetPos = config.spells[key].pos;
	else
		widgetPos = config.battlePos;
	end
	widget:setPosition(widgetPos or START_POS);
end

spellsCaster.doRemoveMouseMove = function(key)
	local widget = spellsCaster.widgets[key];
	widget.onDragEnter = nil;
	widget.onDragMove = nil;
	widget:setFocusable(false);
	widget:setPhantom(true);
	widget:setDraggable(false);
	widget:setOpacity(0.7);
end

spellsCaster.doSetMouseMove = function(key)
	local widget = spellsCaster.widgets[key];
	widget:setFocusable(true);
	widget:setPhantom(false);
	widget:setDraggable(true);
	widget:setOpacity(1);

	widget.onDragEnter = function(widget, mousePos)
		widget:breakAnchors();
		widget.movingReference = {x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY()};
		return true;
	end

	widget.onDragMove = function(widget, mousePos, moved)
		local parentRect = widget:getParent():getRect();
		local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth());
		local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight());
		widget:move(x, y);
		local pos = {x = x, y = y};
		if (key ~= 'battlingStatus') then
			config.spells[key].pos = pos;
		else
			config.battlePos = pos;
		end
		return true;
	end
end

function spellsCaster:setInfoContent(widget)

	local attackingPlayers = table.size(config.attackers);
	widget:setColor(attackingPlayers == 0 and "white" or "red");
	
	local content = "Oponentes: " .. attackingPlayers;
	
	local spells = self.getAllFromSameType(TYPE_FUGA);
	local percentCast;
	for _, entry in ipairs(spells) do
		if (not entry.cooldownTime and entry.enabled) then
			percentCast = entry.percent;
			break
		end
	end
	if (percentCast) then
		local percentSum = self.getAttackersSum();
		content = content .. " | Fuga in: " .. percentSum + percentCast .. "%";
		-- content = content:format(percentSum + percentCast);
	end
	widget:setText(content);
end

macro(1, function()
	if (not spellsCaster.widgets) then return; end
	local status = config.macroActive;
	if (not status) then return; end
	local pressed = isMainKeyPressed();
	local time = os.time();
	-- local CUSTOM_PERCENTAGE = spellsCaster.autoPercentage();
	

	for key, widget in pairs(spellsCaster.widgets) do
		if (widget.pressedKey ~= pressed) then
			if (pressed) then
				spellsCaster.doSetMouseMove(key);
			else
				spellsCaster.doRemoveMouseMove(key);
			end
			widget.pressedKey = pressed;
		end
		if (key ~= "battlingStatus") then
			local storage = config.spells[key];
			key = key:ucwords();
			-- local USAGE = storage.key or storage.percent == 100 and CUSTOM_PERCENTAGE or storage.percent;
			local shownText, shownColor = key .. ": 0s", "green";
			if (storage and storage.activeTime and storage.activeTime >= time) then
				local sum = storage.activeTime - time;
				shownText = sum .. ": " .. key .. ": " .. sum;
				shownColor = "orange";
			elseif (storage and storage.cooldownTime and storage.cooldownTime >= time) then
				local sum = storage.cooldownTime - time;
				shownText = shownText:gsub("0", sum);
				shownColor = "red";
			elseif (storage.cooldownTime or storage.activeTime) then
				storage.cooldownTime, storage.activeTime = nil, nil;
			end
			widget:setText(shownText);
			widget:setColor(shownColor);
		else
			-- local attackingPlayers = table.size(config.attackers);
			-- widget:setColor(attackingPlayers == 0 and "white" or "red");
			-- widget:setText(" Oponentes: " .. attackingPlayers .. " | Porcentagem: " .. CUSTOM_PERCENTAGE .. "% ");
			spellsCaster:setInfoContent(widget);
		end
	end
end)

onTalk(function(name, level, mode, text)
	if (characterName ~= name) then return; end
	
	if (mode ~= 44) then return; end
	
	text = text:lower():trim();

	local castedSpell = config.spells[text];
	if (not castedSpell) then return; end
	
	if (castedSpell.cooldownTime and castedSpell.cooldownTime >= os.time()) then return; end
	
	config.spells[text].cooldownTime = os.time() + castedSpell.cooldownTotal;
	if (castedSpell.activeTotal and castedSpell.activeTotal > 0) then
		config.spells[text].activeTime = os.time() + castedSpell.activeTotal;
	end
end)

--

spellsCaster.searchWithinVariables = function() -- forEach function that contains "getatt", will try to get the creature
	for key, func in pairs(g_game) do
		key = key:lower();
		if (key:match("getatt") and type(func) == "function") then
			local result = func();
			if (result) then
				if (result:isPlayer() or result:isMonster()) then
					return result;
				end
			end
		end
	end
end


spellsCaster.getAttackingCreature = function()
	local pos = pos();
	for _, child in ipairs(battlePanel:getChildren()) do
		local creature = child.creature;
		if (creature) then
			local creaturePos = creature:getPosition();
			if (creaturePos and creaturePos.z == pos.z) then
				if (table.find(ATTACKING_COLORS, child.color)) then
					return creature;
				end
			end
		end
	end
	return spellsCaster.searchWithinVariables();
end


spellsCaster.window = setupUI([[
MainWindow
  size: 670 300

  Panel
    id: mainPanel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.left: parent.left
    image-border: 6
    size: 630 245

    TextList
      id: especiaisList
      anchors.left: parent.left
      anchors.top: parent.top
      size: 300 200
      image-border: 3
      image-source: /images/ui/textedit
      margin-top: 35
      margin-left: 10
      vertical-scrollbar: especiaisListScroll

    VerticalScrollBar
      id: especiaisListScroll
      anchors.top: especiaisList.top
      anchors.bottom: especiaisList.bottom
      anchors.right: especiaisList.right
      step: 10
      pixels-scroll: true

    Label
      id: spellNameLabel
      !text: tr("Nome da Magia")
      anchors.right: parent.right
      anchors.top: especiaisList.top
      margin-right: 65
      margin-top: 8
      margin-bottom: 5
    
    TextEdit
      id: spellName
      anchors.right: spellNameLabel.left
      anchors.top: especiaisList.top
      margin-top: 5
      margin-bottom: 5
      margin-right: 15
      height: 21
      width: 120

    Label
      id: castSpellNameLabel
      !text: tr("Magia que Fala")
      anchors.right: parent.right
      anchors.top: spellNameLabel.bottom
      margin-right: 67
      margin-top: 28
      margin-bottom: 5
    
    TextEdit
      id: castSpellName
      anchors.right: castSpellNameLabel.left
      anchors.top: spellName.bottom
      margin-top: 20
      margin-bottom: 5
      margin-right: 15
      height: 21
      width: 120

    CheckBox
      id: sameAsAbove
      tooltip: Igual ao acima
      anchors.left: castSpellNameLabel.right
      anchors.top: spellNameLabel.bottom
      margin-top: 28
      margin-left: 10
  
    Label
      id: cooldownLabel
      !text: tr("Cooldown")
      anchors.right: parent.right
      anchors.top: castSpellNameLabel.bottom
      margin-right: 98
      margin-top: 25
      margin-bottom: 5

    Button
      id: moveUp
      text: ^
      tooltip: Mover para cima
      anchors.left: prev.right
      anchors.top: prev.top
      size: 10 10
      margin-top: 1
      margin-left: 15

    Button
      id: moveDown
      text: ^
      tooltip: Mover para baixo
      anchors.left: cooldownLabel.right
      anchors.top: activeLabel.top
      size: 10 10
      margin-left: 17
      margin-top: 5

    HorizontalScrollBar
      id: cooldownScroll
      anchors.top: cooldownLabel.top
      anchors.right: castSpellName.right
      anchors.left: castSpellName.left
      step: 1
      width: 145
      margin-right: 3

    Label
      id: activeLabel
      !text: tr("Active")
      anchors.right: parent.right
      anchors.left: cooldownLabel.left
      anchors.top: cooldownLabel.bottom
      -- margin-right: 115
      margin-bottom: 5
      margin-top: 25

    HorizontalScrollBar
      id: activeScroll
      anchors.top: activeLabel.top
      anchors.right: castSpellName.right
      anchors.left: castSpellName.left
      step: 1
      width: 145
      margin-right: 3 

    TextEdit
      id: keyToPress_textBox
      anchors.left: castSpellName.left
      anchors.top: activeLabel.bottom
      margin-top: 15
      height: 21
      width: 120

    HorizontalScrollBar
      id: percentScroll
      anchors.top: prev.top
      -- anchors.right: prev.right
      anchors.left: prev.right
      margin-top: 5
      step: 1
      width: 100

    Label
      id: keyToPress
      anchors.centerIn: keyToPress_textBox
      text-auto-resize: true

    Label
      id: keyLabel
      !text: tr("Tecla")
      anchors.right: activeLabel.right
      anchors.left: activeLabel.left
      anchors.bottom: keyToPress_textBox.bottom
      margin-right: 7
      margin-bottom: 3

    CheckBox
      id: WASD
      text: WASD
      anchors.left: keyToPress_textBox.left
      anchors.top: keyToPress_textBox.top
      text-auto-resize: true
      margin-top: 3

    CheckBox
      id: SETAS
      text: SETAS
      anchors.left: prev.right
      anchors.top: prev.top
      text-auto-resize: true
      margin-left: 3

    CheckBox
      id: automaticUse
      tooltip: Automático (com target)
      anchors.left: keyLabel.left
      anchors.top: keyLabel.top
      margin-left: 50

    Button
      id: addButton
      !text: tr("Adicionar")
      anchors.bottom: parent.bottom
      anchors.left: especiaisList.right
      margin-bottom: 5
      margin-left: 40

    Button
      id: closeButton
      text: Close
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      width: 75
      margin-right: 15
      margin-bottom: 5

    Label
      id: displayLabel
      !text: tr('')
      anchors.top: parent.top
      anchors.right: prev.left
      text-auto-resize: true
      margin-right: 30
      margin-top: 10
      margin-left: 5

    ComboBox
      id: configList
      anchors.top: parent.top
      anchors.left: especiaisList.left
      margin-top: 5
      text-offset: 3 0

    ComboBox
      id: typeList
      anchors.top: prev.top
      anchors.left: prev.right
      text-offset: 3 0
      margin-left: 5

    Button
      id: importButton
      !text: tr("Importar")
      anchors.top: prev.top
      anchors.left: prev.right
      margin-left: 15

  Panel
    id: logoPanel
    anchors.top: parent.top
    anchors.right: parent.right
    size: 300 410
    margin-top: -115
    margin-right: -195
]], g_ui.getRootWidget())

spellsCaster.window:setText(TITLE);
function spellsCaster.window:setText() end;
ORANGE_RAINBOW(spellsCaster.window, {r = 255, g = 165, b = 0, a = 255});
spellsCaster.window.mainPanel.especiaisList:setBackgroundColor({a = 0})
spellsCaster.window.mainPanel.percentScroll:hide();
spellsCaster.window.mainPanel.moveUp:hide();
spellsCaster.window.mainPanel.moveDown:hide();
spellsCaster.window.mainPanel.WASD:hide();
spellsCaster.window.mainPanel.SETAS:hide();
spellsCaster.window.mainPanel.WASD.onCheckChange = function(widget, checked)
	checked = not checked;
	local SETAS = spellsCaster.window.mainPanel.SETAS;
	if (SETAS:isChecked() ~= checked) then
		SETAS:setChecked(checked);
	end
end

spellsCaster.window.mainPanel.SETAS.onCheckChange = function(widget, checked)
	checked = not checked;
	local WASD = spellsCaster.window.mainPanel.WASD;
	if (WASD:isChecked() ~= checked) then
		WASD:setChecked(checked);
	end
end
spellsCaster.window:hide();
--local IMAGE_URL = "https://www.elfoscripts.com/wp-content/uploads/Tyr-Nto.png";
--if (g_game.getWorldName():lower():find("db")) then
	--IMAGE_URL = "https://www.elfoscripts.com/wp-content/uploads/Tyr-Dbo.png";
--end

--doImageDownload = function()
	--http.downloadImage(IMAGE_URL, function(path, err)
		--if (err) then
			--error(err);
			--return schedule(5000, doImageDownload);
		--end
		--spellsCaster.window.logoPanel:setImageSource(path);
	--end)
--end
--doImageDownload();

spellsCaster.mainPanel = spellsCaster.window.mainPanel;
spellsCaster.mainPanel.moveDown:setRotation(180);
if (isMobile) then
	error("Stack está desativado no mobile, para mover os icones, use o botão de volume.");
	table.remove(ESPECIAIS_OPTIONS, table.find(ESPECIAIS_OPTIONS, TYPE_STACK));
end
for index = 1, #ESPECIAIS_OPTIONS do
	local option = ESPECIAIS_OPTIONS[index];
	spellsCaster.mainPanel.typeList:addOption(option);
end

if (type(config.selected) ~= "table") then
	config.selected = {};
end

spellsCaster.selected = config.selected;


spellsCaster.selected.config = spellsCaster.selected.config or characterName;
spellsCaster.selected.type = spellsCaster.selected.type or ESPECIAIS_OPTIONS[1];

spellsCaster.isEditing = true;
local NORMAL_CHANGER = function(widget, checked)
	spellsCaster.mainPanel.percentScroll:hide();
	local textBox = spellsCaster.mainPanel.keyToPress_textBox;
	local keyBox = spellsCaster.mainPanel.keyToPress;
	textBox:show();
	keyBox:show();
	spellsCaster.mainPanel.keyToPress_textBox:setEnabled(not checked);
	if checked then
		spellsCaster.mainPanel.keyToPress:clearText();
	else
		spellsCaster.mainPanel.keyToPress:setText(spellsCaster.mainPanel.keyToPress.oldKey);
	end
	spellsCaster.isEditing = not checked;
end

spellsCaster.mainPanel.keyToPress_textBox.oldWidth = spellsCaster.mainPanel.keyToPress_textBox:getWidth();

local PERCENT_CHANGER = function(widget, checked)
	local textBox = spellsCaster.mainPanel.keyToPress_textBox
	-- local keyBox = spellsCaster.mainPanel.keyToPress;
	local percentScroll = spellsCaster.mainPanel.percentScroll;
	if (checked) then
		spellsCaster.mainPanel.keyLabel:setText("Percent");
		-- keyBox:hide();
		-- textBox:hide();
		percentScroll:show();
		textBox:setWidth(textBox.oldWidth / 2);
		percentScroll:setWidth(textBox.oldWidth / 2 + 15);
	else
		spellsCaster.mainPanel.keyLabel:setText("Tecla");
		textBox:setWidth(textBox.oldWidth);
		-- textBox:setEnabled(true);
		-- textBox:show();
		-- keyBox:show();
		percentScroll:hide();
	end
	spellsCaster.isEditing = true;
end

local doScrollSetup = function(widget, defaultValue, min, max, notTime)
	widget:setMinimum(min);
	widget:setMaximum(max);
	if (widget:getId() ~= "percentScroll") then
		widget.onValueChange = function(widget, value)
			local append = not notTime and "s" or "";
			widget:setText(value .. append);
		end
	else
		widget.onValueChange = function(widget, value)
			widget:setText(value ~= 100 and value .. "%" or "AUTO%");
		end
	end
	widget:setValue(100);
	widget:setValue(defaultValue);
end


spellsCaster.mainPanel.typeList.onOptionChange = function(widget, text)
	local type = text;
	spellsCaster.selected.type = type;
	local self = spellsCaster.mainPanel.automaticUse;
	local textBox = spellsCaster.mainPanel.keyToPress_textBox;
	textBox:setWidth(textBox.oldWidth);
	local keyToPress = spellsCaster.mainPanel.keyToPress;
	
	spellsCaster.mainPanel.keyLabel:setText("Tecla");
	textBox:show();
	keyToPress:show();
	self:show();
	
	local activeScroll, activeLabel = spellsCaster.mainPanel.activeScroll, spellsCaster.mainPanel.activeLabel;
	
	doScrollSetup(activeScroll, 0, 0, 180);
	activeLabel:setText("Active");
	activeLabel:setWidth(38);
	
	spellsCaster.window.mainPanel.WASD:hide();
	spellsCaster.window.mainPanel.SETAS:hide();
	if (type == TYPE_FUGA) then
		spellsCaster.isEditing = true;
		self:setTooltip("Automático (com porcentagem)");
		self.onCheckChange = PERCENT_CHANGER;
		self.onCheckChange(self, self:isChecked());
	elseif (type ~= TYPE_STACK) then
		local extra = type ~= TYPE_BUFF and " (com target)" or "";
		self:setTooltip("Automático" .. extra);
		self.onCheckChange = NORMAL_CHANGER;
		self.onCheckChange(self, self:isChecked());
	else
		doScrollSetup(activeScroll, 5, 2, 9, true);
		activeLabel:setText("Distance");
		textBox:hide();
		keyToPress:hide();
		spellsCaster.mainPanel.percentScroll:hide();
		spellsCaster.window.mainPanel.WASD:show();
		spellsCaster.window.mainPanel.SETAS:show();
		self:hide();
	end
	if (spellsCaster.refreshSpells) then
		spellsCaster.refreshSpells();
	end
end

doScrollSetup(spellsCaster.mainPanel.cooldownScroll, 1, 1, 600);
doScrollSetup(spellsCaster.mainPanel.activeScroll, 0, 0, 180);
doScrollSetup(spellsCaster.mainPanel.percentScroll, 1, 1, 100);

local self = spellsCaster.mainPanel.typeList;
self:setCurrentOption(config.selected.type);
self.onOptionChange(self, config.selected.type);

spellsCaster.mainPanel.configList:setWidth(150);

if (spellsCaster.selected.config == characterName) then
	spellsCaster.mainPanel.importButton:hide();
end

for option, _ in pairs(storage.especiaisConfig[worldName]) do
	spellsCaster.mainPanel.configList:addOption(option);
end

spellsCaster.mainPanel.configList.onOptionChange = function(widget, text)
	local option = text;
	if (option ~= characterName) then
		spellsCaster.mainPanel.importButton:show();
	else
		spellsCaster.mainPanel.importButton:hide();
	end
	spellsCaster.selected.config = option;
end

spellsCaster.mainPanel.configList:setCurrentOption(spellsCaster.selected.config)

spellsCaster.mainPanel.importButton.onClick = function()
	local previousStorage = config;
	config.spells = storage.especiaisConfig[worldName][config.selected.config].spells;
	spellsCaster.mainPanel.configList:setOption(config.selected.config);
	spellsCaster.refreshSpells();
end


spellsCaster.mainPanel.keyToPress_textBox.onTextChange = function(widget)
	widget:clearText();
end
-- doScrollSetup = nil;


spellsCaster.mainPanel.castSpellName.onTextChange = function(widget, text)
	if (not spellsCaster.mainPanel.sameAsAbove:isChecked()) then return; end
	widget:clearText();
end

spellsCaster.mainPanel.sameAsAbove.onCheckChange = function(widget, checked)
	if (checked) then
		spellsCaster.mainPanel.castSpellName:setEnabled(false);
	else
		spellsCaster.mainPanel.castSpellName:setEnabled(true);
		spellsCaster.mainPanel.castSpellName:setText(spellsCaster.mainPanel.spellName:getText());
	end
end

spellsCaster.mainPanel.sameAsAbove:setChecked(true);

onKeyDown(function(keys)
	if (not spellsCaster.isEditing) then return; end
	
	if (spellsCaster.window:isHidden()) then return; end
	-- info(spellsCaster.mainPanel:getFocusedChild():getId())
	if (not spellsCaster.mainPanel.keyToPress_textBox:isFocused()) then return; end
	
	spellsCaster.mainPanel.keyToPress:setText(keys);
end)


spellsCaster.mainPanel.closeButton.onClick = function()
	spellsCaster.window:hide();
	spellsCaster.doGameFocus();
end

spellsCaster.window.onEscape = spellsCaster.mainPanel.closeButton.onClick;

spellsCaster.doGameFocus = function()
	gameRootPanel:focus();
end

spellsCaster.window.onEscape = spellsCaster.mainPanel.closeButton.onClick;

spellsCaster.entry = [[
Label
  background-color: alpha
  text-offset: 18 4
  focusable: true
  height: 16
  font: verdana-11px-rounded

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 2
    margin-left: 3

  $focus:
    background-color: #00000055

  Button
    id: remove
    !text: tr('x')
    anchors.right: parent.right
    margin-right: 15
    text-offset: 1 0
    width: 15
    height: 15
]];

spellsCaster.getAllFromSameType = function(type)
	local childrens = {};
	for _, entry in pairs(config.spells) do
		if (entry.type == type) then
			table.insert(childrens, entry);
		end
	end
	table.sort(childrens, function(a, b)
		return a.index < a.index;
	end)
	-- info(json.encode(childrens, 4))
	return childrens;
end

spellsCaster.checkIndex = function(entry)
	local spells = spellsCaster.getAllFromSameType(entry.type);
	while (entry.index ~= 1) do
		local wantedIndex = entry.index - 1;
		local newEntry = table.findbyfield(spells, 'index', wantedIndex);
		if (not newEntry) then
			entry.index = wantedIndex;
		else
			spellsCaster.checkIndex(newEntry);
			break
		end
	end
end

spellsCaster.changeChildByIndex = function(newIndex)
	local child = spellsCaster.mainPanel.especiaisList:getFocusedChild();
	if (not child) then return; end
	local oldIndex = child.index;
	newIndex = newIndex + oldIndex;
	local oldChild = child:getParent():getChildByIndex(newIndex);
	config.spells[oldChild.castSpellName].index = oldIndex;
	config.spells[child.castSpellName].index = newIndex;
	spellsCaster.refreshSpells();
end

spellsCaster.mainPanel.moveDown.onClick = function()
	spellsCaster.changeChildByIndex(1);
end

spellsCaster.mainPanel.moveUp.onClick = function()
	spellsCaster.changeChildByIndex(-1);
end

spellsCaster.refreshSpells = function()
	
	spellsCaster.destroyAllWidgets();
	spellsCaster.window.mainPanel.moveUp:hide();
	spellsCaster.window.mainPanel.moveDown:hide();
	
	if (not config.macroActive) then return; end

	spellsCaster.spells = {};
	for _, type in ipairs(ESPECIAIS_OPTIONS) do
		spellsCaster.spells[type] = {};
	end
	
	for castSpellName, entry in pairs(config.spells) do
		spellsCaster.checkIndex(entry);
		if (entry.enabled and table.find(SHOW_SPELL_TIME, entry.type)) then
			spellsCaster.setupWidget(castSpellName);
		end
		local content = spellsCaster.spells[entry.type];
		table.insert(content, entry);
		table.sort(content, function(a, b)
			return a.index < b.index;
		end)
	end
	
	local selected = config.selected.type;
	local showSpells = spellsCaster.spells[selected];
	for _, entry in ipairs(showSpells) do
		local widget = setupUI(spellsCaster.entry, spellsCaster.mainPanel.especiaisList);
		
		widget.onFocusChange = function(widget, focused)
			if (#showSpells == 1 or not focused) then return; end
			if (entry.index == 1) then
				spellsCaster.mainPanel.moveUp:hide();
			else
				spellsCaster.mainPanel.moveUp:show();
			end
			if (entry.index == #showSpells) then
				spellsCaster.mainPanel.moveDown:hide();
			else
				spellsCaster.mainPanel.moveDown:show();
			end
		end
		widget.onDoubleClick = function()
			config.spells[entry.castSpellName] = nil;
			local self = spellsCaster.mainPanel.typeList;
			self:setCurrentOption(entry.type);
			if (entry.spellName == entry.castSpellName) then
				spellsCaster.mainPanel.sameAsAbove:setChecked(true);
			else
				spellsCaster.mainPanel.sameAsAbove:setChecked(false);
				spellsCaster.mainPanel.castSpellName:setText(entry.castSpellName);
			end
			spellsCaster.mainPanel.spellName:setText(entry.spellName);
			spellsCaster.mainPanel.cooldownScroll:setValue(entry.cooldownTotal);
			spellsCaster.mainPanel.activeScroll:setValue(entry.activeTotal or entry.distance);
			if (entry.type ~= TYPE_BUFF) then
				if (entry.key) then
					if (entry.key ~= "AUTO") then
						spellsCaster.mainPanel.keyToPress:setText(entry.key);
					end
				end
				if (entry.percent) then
					spellsCaster.mainPanel.percentScroll:setValue(entry.percent);
				end
				spellsCaster.mainPanel.automaticUse:setChecked(entry.percent or entry.key == 'AUTO');
			end
			spellsCaster.sucessDisplay('A magia foi removida.');
			spellsCaster.refreshSpells();
		end
		widget.remove.onClick = widget.onDoubleClick;
		widget.enabled:setChecked(entry.enabled);
		widget.enabled.onCheckChange = function(widget, enabled)
			entry.enabled = enabled;
			spellsCaster.refreshSpells();
		end
		widget.castSpellName = entry.castSpellName;
		widget.index = entry.index;
		local widget_text = entry.castSpellName:ucwords();
		widget_text = widget_text .. " | CD: " .. entry.cooldownTotal .. "s";
		local EXTRA;
		if (entry.percent) then
			EXTRA = entry.percent == 100 and "AUTO%" or entry.percent .. "%";
		end
		if (entry.key and #entry.key > 0) then
			EXTRA = EXTRA and EXTRA .. " | " .. entry.key or entry.key;
		end
		-- local EXTRA = entry.key or entry.percent == 100 and "AUTO%" or entry.percent .. "%";
		-- EXTRA = entry.percent and entry.key and EXTRA .. " | " .. entry.key or EXTRA;
		widget_text = widget_text .. " | " .. EXTRA;
		widget:setText(widget_text);
	end
	if (config.showInfo) then
		spellsCaster.setupWidget("battlingStatus");
	end
	modules.game_bot.save();
end

local checkBox = setupUI([[
CheckBox
  id: checkBox
  text: Show Info
  margin-top: 3
  margin-right: 7
  margin-left: 7

  $checked
    color: ]] .. corText .. [[
]]);

checkBox.onCheckChange = function(widget, checked)
	config.showInfo = checked;
	spellsCaster.refreshSpells();
end

if (config.showInfo == nil) then
	config.showInfo = true;
end

checkBox:setChecked(config.showInfo);

spellsCaster.refreshSpells();

spellsCaster.errorDisplay = function(text)
	local excludeValue = now + 2000;
	spellsCaster.mainPanel.displayLabel.excludeValue = excludeValue;
	spellsCaster.mainPanel.displayLabel:setText(text);
	spellsCaster.mainPanel.displayLabel:setColor({r = 255, g = 0, b = 0, a = 255});
	schedule(2000, function()
		if (excludeValue ~= spellsCaster.mainPanel.displayLabel.excludeValue) then return; end
		
		spellsCaster.mainPanel.displayLabel:clearText('');
	end)
end
		
spellsCaster.sucessDisplay = function(text)
	local excludeValue = now + 2000;
	spellsCaster.mainPanel.displayLabel.excludeValue = excludeValue;
	spellsCaster.mainPanel.displayLabel:setText(text);
	spellsCaster.mainPanel.displayLabel:setColor({r = 0, g = 255, a = 255});
	schedule(2000, function()
		if (excludeValue ~= spellsCaster.mainPanel.displayLabel.excludeValue) then return; end
		
		spellsCaster.mainPanel.displayLabel:clearText();
	end)
end


spellsCaster.mainPanel.addButton.onClick = function()
	
	local spellName = spellsCaster.mainPanel.spellName:getText():lower():trim();
	local castSpellName = not spellsCaster.mainPanel.sameAsAbove:isChecked() and spellsCaster.mainPanel.castSpellName:getText():lower():trim() or spellName;
	local cooldownTime = spellsCaster.mainPanel.cooldownScroll:getValue();
	local activeTime = spellsCaster.mainPanel.activeScroll:getValue();
	local keyToPress, percent;
	if (config.selected.type == TYPE_STACK) then
		keyToPress = spellsCaster.mainPanel.WASD:isChecked() and "WASD" or "SETAS";
		-- info(keyToPress);
	elseif (config.selected.type ~= TYPE_FUGA) then
		keyToPress = spellsCaster.mainPanel.automaticUse:isChecked() and 'AUTO' or spellsCaster.mainPanel.keyToPress:getText();
	else
		percent = spellsCaster.mainPanel.automaticUse:isChecked() and spellsCaster.mainPanel.percentScroll:getValue();
		keyToPress = spellsCaster.mainPanel.keyToPress:getText();
	end
	

	if (#spellName == 0) then
		return spellsCaster.errorDisplay('Insira o nome da magia.');
	end
	
	if (#castSpellName == 0) then
		return spellsCaster.errorDisplay('Insira o texto que a magia solta.');
	end
	
	if (not keyToPress or #keyToPress == 0 and not percent) then
		return spellsCaster.errorDisplay('Defina uma tecla.');
	end

	if (config.spells[castSpellName] ~= nil) then
		return spellsCaster.errorDisplay('A magia já existe.');
	end

	
	config.spells[castSpellName] = {
		castSpellName = castSpellName,
		spellName = spellName,
		-- activeTotal = activeTime,
		cooldownTotal = cooldownTime,
		index = table.size(config.spells) + 1,
		type = config.selected.type,
		enabled = true
	};
	
	if (config.selected.type ~= TYPE_STACK) then
		config.spells[castSpellName].activeTotal = activeTime;
	else
		config.spells[castSpellName].distance = activeTime;
	end
	
	-- local path = config.spells[castSpellName];

	if (#keyToPress > 0) then
		config.spells[castSpellName].key = keyToPress;
	end
	if (percent) then
		config.spells[castSpellName].percent = percent;
	end
	spellsCaster.mainPanel.keyToPress:clearText();
	spellsCaster.mainPanel.spellName:clearText();
	spellsCaster.mainPanel.castSpellName:clearText();
	spellsCaster.mainPanel.sameAsAbove:setChecked(true);
	spellsCaster.mainPanel.automaticUse:setChecked(false);
	spellsCaster.mainPanel.percentScroll:setValue(1);
	spellsCaster.mainPanel.cooldownScroll:setValue(1);
	spellsCaster.mainPanel.activeScroll:setValue(0);
	
	spellsCaster.sucessDisplay('A magia foi inserida com sucesso.');
	spellsCaster.refreshSpells();
end
