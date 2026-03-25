setDefaultTab("Macros")
cor = UI.Button("- SENSE -")
cor:setColor("#FFFAFA")

-- ============================================================
-- SETUP: Widget base del sense com seta
-- ============================================================
local widget = setupUI([[
Panel
  height: 1920
  width: 1080
]], modules.game_interface.getMapPanel())

local tcLastSense = g_ui.loadUIFromString([[
Label
  color: green
  font: verdana-11px-rounded
  background-color: #00000090
  opacity: 0.87
  text-horizontal-auto-resize: true
  text: Sense  
]], widget)

lastSense = {}
lastSense.widget = [[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
]]

lastSense.pointerWidget = setupUI([[
Panel
  image-source: /images/ui/panel_flat
  size: 60 60
]], g_ui.getRootWidget())

HTTP.downloadImage("https://icons.iconarchive.com/icons/icons8/ios7/256/Maps-North-Direction-icon.png", function(image)
  return lastSense.pointerWidget:setImageSource(image)
end)



-- ============================================================
-- SETUP: Panel SQM (solo distancia, sin flecha)
-- ============================================================
storage.senseBaseDist = 0
storage.senseStartPos = nil
storage.lastUpdate    = 0

local sqmPanel = setupUI([[
Panel
  height: 60
  width: 120
  focusable: false
]], g_ui.getRootWidget())

local sqmLabel = setupUI([[
Label
  anchors.centerIn: parent
  text-auto-resize: true
  background-color: #000000AA
  font: verdana-11px-rounded
  text-align: center
]], sqmPanel)

sqmPanel:hide()

-- ============================================================
-- HELPERS
-- ============================================================
function getBaseDist(t)
  t = t:trim()
  if t == 'very far' then return 375
  elseif t == 'far' then return 190
  else return 60 end
end

-- Obtiene el target activo según qué macro está encendido
function getActiveTarget()
  -- xNombre: tiene prioridad siempre
  if storage.Sense and storage.Sense ~= false then
    return storage.Sense
  end
  -- Sense Target
  if sense and sense ~= '' then
    return sense
  end
  -- Sense com Seta
  if storage.lastSense and storage.lastSense['target'] then
    return storage.lastSense['target']
  end
  return nil
end

-- ============================================================
-- MACRO VISUAL: actualiza el panel SQM
-- ============================================================
macro(100, function()
  local target = getActiveTarget()

  if not target or not storage.sensePosReady then
    sqmPanel:hide()
    return
  end

  if not sqmPanel:isVisible() then sqmPanel:show() end

  local currentDist = storage.senseBaseDist
  if storage.senseStartPos then
    local walked = getDistanceBetween(storage.senseStartPos, player:getPosition())
    currentDist = math.max(0, storage.senseBaseDist - walked)
  end

  local elapsed = math.floor((now - storage.lastUpdate) / 1000)

  if currentDist <= 50 then sqmLabel:setColor('#55FF55')
  elseif currentDist <= 150 then sqmLabel:setColor('#FFFF55')
  else sqmLabel:setColor('#FF5555') end

  local dirText = storage.senseDir and (" " .. storage.senseDir) or ""
  sqmLabel:setText(target .. "\nE" .. elapsed .. ", " .. currentDist .. " SQM")
end)

-- ============================================================
-- INIT: configuración de posiciones de la brújula
-- ============================================================
lastSense.init = function()
  if not storage.sensePositions or table.size(storage.sensePositions) < 4 then
    lastSense.startMapeation = true
    storage.sensePositions = {}
  end

  if lastSense.startMapeation then
    lastSense.directions, lastSense.actualSense = {
      'Norte', 'Sul', 'Esquerda', 'Direita'
    }, 1

    modules.game_textmessage.displayGameMessage('Vamos configurar o sense!')
    schedule(3000, function()
      modules.game_textmessage.displayGameMessage('Arraste a caixinha para o Norte, segurando CTRL.')
      lastSense.senseBox = setupUI(lastSense.widget, g_ui.getRootWidget())
      lastSense.senseBox:setHeight(50)
      lastSense.senseBox:setWidth(50)
      lastSense.senseBox:setPosition({x = 50, y = 50})
      lastSense.senseBox:setText('AQUI')

      lastSense.senseBox.onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then return false end
        widget:breakAnchors()
        widget.movingReference = { x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY() }
        return true
      end

      lastSense.senseBox.onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
      end

      lastSense.senseBox.onDragLeave = function(widget, pos)
        storage.sensePositions[lastSense.directions[lastSense.actualSense]] = {x = widget:getX(), y = widget:getY()}
        schedule(500, function()
          lastSense.actualSense = lastSense.actualSense + 1
          if lastSense.actualSense > 4 then
            modules.game_textmessage.displayGameMessage('Configurado, pode aproveitar o seu Sense!')
            lastSense.senseBox:destroy()
            lastSense.setup()
            return true
          end
          local actualDirection = lastSense.directions[lastSense.actualSense]
          local showText = 'Arraste a caixinha para o ' .. actualDirection .. ', segurando CTRL.'
          if string.sub(actualDirection, actualDirection:len(), actualDirection:len()) == 'a' then
            showText = 'Arraste a caixinha para a ' .. actualDirection .. ', segurando CTRL.'
          end
          modules.game_textmessage.displayGameMessage(showText)
        end)
        return true
      end
    end)
  else
    lastSense.setup()
  end
end

-- ============================================================
-- SETUP: brújula + onTextMessage unificado
-- ============================================================
function lastSense.setup()
  macro(100, function()
    local sensePlayer = getCreatureByName(tostring(lastSense.actualSense))
    if (sensePlayer and getDistanceBetween(sensePlayer:getPosition(), pos()) < 6) or (not lastSense.elapsed or lastSense.elapsed < now) then
      lastSense.pointerWidget:hide()
    elseif lastSense.pointerWidget:isHidden() then
      lastSense.pointerWidget:show()
    end
  end)

  local north, south, west, east = storage.sensePositions['Norte'], storage.sensePositions['Sul'], storage.sensePositions['Esquerda'], storage.sensePositions['Direita']

  lastSense.savePos = {
    ['north']      = {x = north.x, y = north.y,  rotation = 0},
    ['south']      = {x = south.x, y = south.y,  rotation = 180},
    ['west']       = {x = west.x,  y = west.y,   rotation = 270},
    ['east']       = {x = east.x,  y = east.y,   rotation = 90},
    ['north-east'] = {x = east.x,  y = north.y,  rotation = 45},
    ['south-east'] = {x = east.x,  y = south.y,  rotation = 135},
    ['north-west'] = {x = west.x,  y = north.y,  rotation = 315},
    ['south-west'] = {x = west.x,  y = south.y,  rotation = 225}
  }

  lastSense.actualPosition = function(text) return lastSense.savePos[text] end
  lastSense.setPosition = function(position)
    lastSense.pointerWidget:setPosition(position)
    lastSense.pointerWidget:setRotation(position.rotation)
    sqmPanel:setPosition({x = position.x, y = position.y - 65})
    storage.sensePosReady = true
  end

  -- onTextMessage unificado: actualiza brújula Y panel SQM
  onTextMessage(function(mode, text)
    if mode == 20 then
      local regex = "([a-z A-Z]*) is ([a-z -A-Z]*)to the ([a-z -A-Z]*)."

      -- Brújula (sense com seta)
      local lastSenseData = regexMatch(text, regex)[1]
      if lastSenseData and lastSenseData[2] and lastSenseData[3] and lastSenseData[4] then
        lastSense.setPosition(lastSense.actualPosition(lastSenseData[4]:trim()))
        lastSense.actualSense        = lastSenseData[2]:trim()
        storage.lastSense['last']    = lastSense.actualSense:trim()
        lastSense.elapsed            = now + 5000
        lastSense.lastPosition       = player:getPosition()
      end

      -- Panel SQM
      local _, _, name, distStr, dir = string.find(text, regex)
      local target = getActiveTarget()
      if name and target and name:lower() == target:lower() then
        storage.senseBaseDist  = getBaseDist(distStr)
        storage.senseStartPos  = player:getPosition()
        storage.lastUpdate     = now
        storage.senseDir       = dir and dir:trim() or nil
      end
    end
  end)
end

lastSense.init()
storage.lastSense = storage.lastSense or {}

-- ============================================================
-- MACROS DE SENSE
-- ============================================================
senseMacro = macro(1, 'Sense com Seta', function()
  local target = g_game.getAttackingCreature()
  if target and target:isPlayer() and not table.find(storage.lastSense, target:getName():trim()) then
    storage.lastSense['target'] = target:getName():trim()
  end
  if modules.game_console:isChatEnabled() then
    return modules.game_textmessage.displayFailureMessage('Desative o chat para usar o Sense.')
  end
  if modules.corelib.g_keyboard.isKeyPressed('T') and storage.lastSense['target'] then
    say('sense "' .. storage.lastSense['target'])
  end
  if modules.corelib.g_keyboard.isKeyPressed('V') and storage.lastSense['last'] then
    say('sense "' .. storage.lastSense['last'])
  end
end)

senses = macro(3000, "Sense Target", function()
  if sense then
    say('sense "' .. sense)
  end
end)

macro(1, function()
  if g_game.isAttacking() and g_game.getAttackingCreature() and g_game.getAttackingCreature():isPlayer() then
    sense = g_game.getAttackingCreature():getName()
  end
end)

macro(1, 'Sense', '0', function()
  if storage.Sense then
    locatePlayer = getPlayerByName(storage.Sense)
    if not (locatePlayer and locatePlayer:getPosition().z == player:getPosition().z and getDistanceBetween(pos(), locatePlayer:getPosition()) <= 6) then
      say('sense "' .. storage.Sense)
      delay(3000)
    end
  end
end)

-- ============================================================
-- COMANDOS x+nombre / x0
-- ============================================================
onTalk(function(name, level, mode, text, channelId, pos)
  if player:getName() == name then
    if string.sub(text, 1, 1) == 'x' then
      local checkMsg = string.sub(text, 2, 3000):trim()
      if checkMsg == '0' then
        storage.Sense = false
        sense = nil
        if storage.lastSense then storage.lastSense['target'] = nil end
        storage.senseBaseDist = 0
        storage.senseStartPos = nil
        storage.senseDir = nil
        storage.sensePosReady = false
        sqmPanel:hide()
        modules.game_textmessage.displayGameMessage('SENSE APAGADO')
      else
        storage.Sense = checkMsg
        storage.lastUpdate = now
        modules.game_textmessage.displayGameMessage('SENSE FIJO: ' .. checkMsg)
      end
    end
  end
end)

-- ============================================================
-- BOTONES UI
-- ============================================================
UI.Button('Resetar Sense', function()
  if lastSense.senseBox then
    lastSense.senseBox:destroy()
  end
  storage.sensePositions = nil
  lastSense.init()
end)

addIcon("Sense", {item = 12899, text = "Sense"}, senseMacro)