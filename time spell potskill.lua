storage.widgetPos = storage.widgetPos or {}

-- widget
local potionSkill = setupUI([[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
]], g_ui.getRootWidget())

potionSkill.onDragEnter = function(widget, mousePos)
    if not (modules.corelib.g_keyboard.isCtrlPressed()) then
        return false
    end
    widget:breakAnchors()
    widget.movingReference = {x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY()}
    return true
end

potionSkill.onDragMove = function(widget, mousePos, moved)
    local parentRect = widget:getParent():getRect()
    local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
    local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
    widget:move(x, y)
    storage.widgetPos["PotionSkill"] = {x = x, y = y}
    return true
end

storage.widgetPos["PotionSkill"] = storage.widgetPos["PotionSkill"] or {}
potionSkill:setPosition({x = storage.widgetPos["PotionSkill"].x or 150, y = storage.widgetPos["PotionSkill"].y or 150})

-- cd
if type(storage.timePotionSkill) ~= 'table' or (storage.timePotionSkill.t - now) > 1800000 then
    storage.timePotionSkill = {t = 0}
end

-- att widget
macro(100, function()
    if not storage.timePotionSkill.t or storage.timePotionSkill.t < now then
        potionSkill:setText('PotionSkill: OK! ')
        potionSkill:setColor('green')
    else
        local remainingTime = math.ceil((storage.timePotionSkill.t - now) / 60000) -- Converte para minutos
        potionSkill:setColor('red')
        potionSkill:setText("PotionSkill: ".. remainingTime .. " min")
    end
end)

-- detectar msg e att
onTextMessage(function(mode, text)
    if text:find("perdera skills se morrer") then
        storage.timePotionSkill.t = now + 1800000 -- 30 minutos em milissegundos
    end
end)