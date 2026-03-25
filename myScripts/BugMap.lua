local DIRECTION_OFFSETS = {
    ['w'] = {x = 0, y = -5, diagonal = false},
    ['e'] = {x = 3, y = -3, diagonal = true},
    ['d'] = {x = 5, y = 0, diagonal = false},
    ['c'] = {x = 3, y = 3, diagonal = true},
    ['s'] = {x = 0, y = 5, diagonal = false},
    ['z'] = {x = -3, y = 3, diagonal = true},
    ['a'] = {x = -5, y = 0, diagonal = false},
    ['q'] = {x = -3, y = -3, diagonal = true}
  }
  
  local function isTileFree(tile)
    if not tile then return false end
    local topThing = tile:getTopUseThing()
    if topThing and topThing.isBlocking then
        return not topThing:isBlocking()
    end
    return true
  end
  
  local function tryMove(targetPos)
    local tile = g_map.getTile(targetPos)
    if tile and isTileFree(tile) then
        g_game.use(tile:getTopUseThing())
        return true
    end
    return false
  end
  
  local function checkPos(x, y)
    local xyz = g_game.getLocalPlayer():getPosition()
    xyz.x = xyz.x + x
    xyz.y = xyz.y + y
    local tile = g_map.getTile(xyz)
    return tile and g_game.use(tile:getTopUseThing(), 1, { ignoreNonPathable = true, precision = 1 }) or false
  end
  
  local function isPathBlocked(x, y, distance)
    for i = 1, distance do
        if not checkPos(x * i, y * i) then
            return true
        end
    end
    return false
  end
  
  local function dash(x, y)
    local dashDistance = 4
    local aheadDistance = 8
  
    if isPathBlocked(x, y, aheadDistance) then
        local directions = {
            { x = x, y = y + 1 },
            { x = x, y = y - 1 },
            { x = x + 1, y = y },
            { x = x - 1, y = y }
        }
  
        for _, dir in ipairs(directions) do
            if not isPathBlocked(dir.x, dir.y, aheadDistance) and isTileFree(g_map.getTile({x = dir.x, y = dir.y, z = g_game.getLocalPlayer():getPosition().z})) then
                if checkPos(dir.x * dashDistance, dir.y * dashDistance) then
                    return
                end
            end
        end
  
        local diagonals = {
            { x = x + 1, y = y + 1 },
            { x = x - 1, y = y - 1 },
            { x = x + 1, y = y - 1 },
            { x = x - 1, y = y + 1 }
        }
  
        for _, dir in ipairs(diagonals) do
            if not isPathBlocked(dir.x, dir.y, aheadDistance) and isTileFree(g_map.getTile({x = dir.x, y = dir.y, z = g_game.getLocalPlayer():getPosition().z})) then
                if checkPos(dir.x * dashDistance, dir.y * dashDistance) then
                    return
                end
            end
        end
    end
  
    if checkPos(x * dashDistance, y * dashDistance) then
        return
    end
  
    for i = 1, dashDistance do
        if checkPos(x * i, y * i) then
            return
        end
    end
  end
  
  local function moveCharacter(config, pos)
    local targetPos = {x = pos.x + config.x, y = pos.y + config.y, z = pos.z}
    if tryMove(targetPos) then return end
  
    local deviations = {
        {x = pos.x + config.x, y = pos.y + config.y + 1, z = pos.z},
        {x = pos.x + config.x, y = pos.y + config.y - 1, z = pos.z},
        {x = pos.x + config.x + 1, y = pos.y + config.y, z = pos.z},
        {x = pos.x + config.x - 1, y = pos.y + config.y, z = pos.z}
    }
    for _, devPos in ipairs(deviations) do
        if tryMove(devPos) then return end
    end
  
    local diagonalDeviations = {
        {x = pos.x + config.x + 1, y = pos.y + config.y + 1, z = pos.z},
        {x = pos.x + config.x - 1, y = pos.y + config.y - 1, z = pos.z},
        {x = pos.x + config.x + 1, y = pos.y + config.y - 1, z = pos.z},
        {x = pos.x + config.x - 1, y = pos.y + config.y + 1, z = pos.z}
    }
    for _, diagPos in ipairs(diagonalDeviations) do
        if tryMove(diagPos) then return end
    end
  end
  
  local function moveCharacterDiagonal(config, pos)
    local midPos = {x = pos.x + config.x / 2, y = pos.y + config.y / 2, z = pos.z}
    if tryMove(midPos) then
        local targetPos = {x = pos.x + config.x, y = pos.y + config.y, z = pos.z}
        if tryMove(targetPos) then return end
    end
  
    local deviationPos1 = {x = pos.x + config.x / 2 + 1, y = pos.y + config.y / 2 + 1, z = pos.z}
    if tryMove(deviationPos1) then return end
  
    local deviationPos2 = {x = pos.x + config.x / 2 - 1, y = pos.y + config.y / 2 - 1, z = pos.z}
    if tryMove(deviationPos2) then return end
  
    local fallbackPos1 = {x = pos.x + config.x - 1, y = pos.y + config.y + 1, z = pos.z}
    if tryMove(fallbackPos1) then return end
  
    local fallbackPos2 = {x = pos.x + config.x + 1, y = pos.y + config.y - 1, z = pos.z}
    if tryMove(fallbackPos2) then return end
  end
  
  consoleModule = modules.game_console
  
  macro(1, 'Bug Map', function() 
    if consoleModule:isChatEnabled() then return end
    local pos = g_game.getLocalPlayer():getPosition()
  
    for key, config in pairs(DIRECTION_OFFSETS) do
        if modules.corelib.g_keyboard.isKeyPressed(key) then
            if config.diagonal then
                moveCharacterDiagonal(config, pos)
            else
                moveCharacter(config, pos)
            end
  
            local currentTile = g_map.getTile(pos)
            if isTileFree(currentTile) then
                dash(config.x, config.y)  -- Apenas tenta desviar se nÃ£o estiver encostado em uma parede
            end
            break
        end
    end
  end)

  --Turn
  macro(1, function()
    if modules.corelib.g_keyboard.isKeyPressed('W') then
        turn(0)
    elseif modules.corelib.g_keyboard.isKeyPressed('S') then
        turn(2)
    elseif modules.corelib.g_keyboard.isKeyPressed('A') then
        turn(3)
    elseif modules.corelib.g_keyboard.isKeyPressed('D') then
        turn(1)
    end
  end)