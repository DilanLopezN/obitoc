setDefaultTab("Tools")

LastTargetxx = null

macro(1000, function()
    if g_game.isAttacking() then
        local message = OutputMessage.create()
        message:addU8(0xF4)
        message:addU32(g_game.getAttackingCreature():getId())
        local protocol = g_game.getProtocolGame()
        protocol:send(message)
    end    
end)

macro(1000, function()
    if g_game.isAttacking() and g_game.getAttackingCreature():isPlayer() then
        LastTargetxx = g_game.getAttackingCreature()
    end
end)

hotkey("x", "Volta_Target_X", function()
    if LastTargetxx ~= null then
        g_game.attack(LastTargetxx)
    end
end)

--Target
local keepTarget = {}

keepTarget.keyCancel = "Escape"

keepTarget.macro = macro(50, function()
	if (modules.corelib.g_keyboard.isKeyPressed(keepTarget.keyCancel)) then
		keepTarget.storageId = nil;
		return g_game.cancelAttack();
	end
	local target = g_game.getAttackingCreature();
	if target and g_game.getAttackingCreature():isPlayer()  then
		local targetId = target:getId();
		if (keepTarget.storageId ~= targetId) then
			keepTarget.storageId = targetId;
		end
		return;
	else
		if (keepTarget.storageId) then
			local findCreature = getCreatureById(keepTarget.storageId);
			if (findCreature) then
				g_game.attack(findCreature);
			end
			return delay(findCreature and 500 or 100);
        	end
	end
end, mainTab)

addIcon("Target", {item = 14189, text="Target"},keepTarget.macro)

--Enemy
friendList = {'toei', 'ryan'}
enemyList = {'felipe', 'piriguete'}
for index, value in ipairs(enemyList) do
    enemyList[value:lower():trim()] = true
    enemyList[index] = nil
end
for index, value in ipairs(friendList) do
    friendList[value:lower():trim()] = true
    friendList[index] = nil
end
macro(1, 'Enemy', function()
    local pos = pos()
    local actualTarget
    for _, creature in ipairs(getSpectators(pos)) do
        local specHp = creature:getHealthPercent()
        local specPos = creature:getPosition()
        local specName = creature:getName():lower()
        if creature:isPlayer() and specHp and specHp > 0 then
            if (not friendList[specName] and creature:getEmblem() ~= 1 and creature:getShield() < 3 and creature ~= player) or enemyList[specName] then
                if creature:canShoot() then
                    if not actualTarget or actualTargetHp > specHp or (actualTargetHp == specHp and getDistanceBetween(pos, actualTargetPos) > getDistanceBetween(specPos, pos)) then
                        actualTarget, actualTargetPos, actualTargetHp = creature, specPos, specHp
                    end
                end
            end
        end
    end
    if actualTarget and g_game.getAttackingCreature() ~= actualTarget then
        g_game.attack(actualTarget)
    end
end)

-- config
local keyUp = "PageUp"
local keyDown = "PageDown"
-- script
local lockedLevel = pos().z
local m = macro(1000, "Spy Level PGUP/PGDOWN", function() end)

onPlayerPositionChange(function(newPos, oldPos)
    if oldPos.z ~= newPos.z then
        lockedLevel = pos().z
        modules.game_interface.getMapPanel():unlockVisibleFloor()
    end
end)

onKeyPress(function(keys)
    if m.isOn() then
        if keys == keyDown then
            lockedLevel = lockedLevel + 1
            modules.game_interface.getMapPanel():lockVisibleFloor(lockedLevel)
        elseif keys == keyUp then
            lockedLevel = lockedLevel - 1
            modules.game_interface.getMapPanel():lockVisibleFloor(lockedLevel)
        end
    end
end)