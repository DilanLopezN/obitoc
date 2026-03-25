setDefaultTab("HP")

--Pots
local PainelPanelName = "listt"
  local ui = setupUI([[
Panel

  height: 30

  Button
    id: editPainel
    color: green
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 30
    text: - Potions -

  ]], parent)
  ui:setId(PaineltroPanelName)

  if not storage[PainelPanelName] then
    storage[PainelPanelName] = { 

    }
  end

rootWidget = g_ui.getRootWidget()
if rootWidget then
    PainelsWindow = UI.createWidget('PainelWindow', rootWidget)
    PainelsWindow:hide()
    TabBar = PainelsWindow.paTabBar
    TabBar:setContentWidget(PainelsWindow.paImagem)
   for v = 1, 1 do





hpPanel = g_ui.createWidget("hpPanel") -- Creates Panel
hpPanel:setId("panelButtons") -- sets ID

hpPanel2 = g_ui.createWidget("hpPanel") -- Creates Panel
hpPanel2:setId("2") -- sets ID


TabBar:addTab("Potion", hpPanel2)
        color= UI.Label("by: @Jeangz",hpPanel2)
        color:setColor("orange")
        UI.Separator(hpPanel2)
Panels.HealthItem(hpPanel2)
        UI.Separator(hpPanel2)
Panels.HealthItem(hpPanel2)
        UI.Separator(hpPanel2)
Panels.ManaItem(hpPanel2)
        UI.Separator(hpPanel2)
Panels.ManaItem(hpPanel2)

end
end
PainelsWindow.closeButton.onClick = function(widget)
  PainelsWindow:hide()
end  
ui.editPainel.onClick = function(widget)
  PainelsWindow:show()
  PainelsWindow:raise()
  PainelsWindow:focus()
end

--Pill
local CdPill = false
UsePill = macro(1000, function()
    if CdPill == false and g_game.isAttacking() and target():isPlayer() then
        usewith(11821, player)
    end
end)

onTextMessage(function(mode, text)
    if  text:lower():find("voce esta com o buff do kit pill") then
        CdPill = true
        schedule(30150, function() CdPill = false end)
    end
end)
addIcon("Pill", {item = 11821, text="Pill"},UsePill)

--JumpMouse
local gamePanel = modules.game_interface.gameMapPanel
gamePanel.onMouseWheel = function(widget, mousePos, scroll)
   -- 1 = scroll up  2 = scroll down
   if scroll == 1 then 
     stopCombo = now + 300;
     say ("jump up")
   end
   if scroll == 2 then 
     stopCombo = now + 300;
     say ("jump down")
   end
end

--PotSkill
CdPotSkill = false
CdPotNinjutsu = false
local usePotionSkills = macro(100, "PotSkill", function()
   local health = hppercent()
   local self = g_game.getLocalPlayer()
   local Skill = 11808
   local Ninujutsu = 11809
   if health <= 30 and CdPotSkill == false then
       if self then
           g_game.useInventoryItemWith(Skill, self, 0)
       end
   elseif health <= 30 and CdPotNinjutsu == false then
       if self then
           g_game.useInventoryItemWith(Ninujutsu, self, 0)
       end
   end
end)

--Nuibare
storage.widgetPos = storage.widgetPos or {}

-- Configurações do Widget
local timespellNuibari = setupUI([[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
]], g_ui.getRootWidget())

timespellNuibari.onDragEnter = function(widget, mousePos)
    if not (modules.corelib.g_keyboard.isCtrlPressed()) then
        return false
    end
    widget:breakAnchors()
    widget.movingReference = {x = mousePos.x - widget:getX(), y = mousePos.y - widget:getY()}
    return true
end

timespellNuibari.onDragMove = function(widget, mousePos, moved)
    local parentRect = widget:getParent():getRect()
    local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth())
    local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
    widget:move(x, y)
    storage.widgetPos["timespellNuibari"] = {x = x, y = y}
    return true
end

local name = "timespellNuibari"
storage.widgetPos[name] = storage.widgetPos[name] or {}
timespellNuibari:setPosition({x = storage.widgetPos[name].x or 50, y = storage.widgetPos[name].y or 50})

-- Configurações iniciais de tempo
if type(storage.timeNuibari) ~= 'table' or (storage.timeNuibari.t - now) > 120000 then
    storage.timeNuibari = {t = 0}
end

-- Macro para atualizar o widget
macro(100, function()
    if not storage.timeNuibari.t or storage.timeNuibari.t < now then
        timespellNuibari:setText('Nuibari: OK! ')
        timespellNuibari:setColor('green')
    else
        local remainingTime = math.ceil((storage.timeNuibari.t - now) / 1000)
        timespellNuibari:setColor('red')
        timespellNuibari:setText("Nuibari: ".. remainingTime .. "s ")
    end
end)

-- Detectar mensagem de cooldown e ajustar o tempo
onTextMessage(function(mode, text)
    local match = text:match("Aguarde (%d+) segundos para usar a espada novamente")
    if match then
        local cooldownTime = tonumber(match) * 1000 -- Convertendo segundos para milissegundos
        storage.timeNuibari.t = now + cooldownTime
    end
end)

CdNuibare = false
hotkey("t", "Nuibare", function()  
 local target = g_game.getAttackingCreature()
 if CdNuibare == false and g_game.isAttacking() then
   g_game.setChaseMode(1)
   usewith(3072, target)
 end
end)

onTextMessage(function(mode, text)
   if  text:lower():find("perdera skills se morrer") then
       CdPotSkill = true
       schedule(1800000, function() CdPotSkill = false end)
   end
   if  text:lower():find("perdera ninjutsu se morrer") then
       CdPotNinjutsu = true
       schedule(1800000, function() CdPotNinjutsu = false end)
   end
   if  text:lower():find("segundos para usar a espada novamente") then
     CdNuibare = true
     schedule(120000, function() CdNuibare = false end)
 end
end)
addIcon("usePotionSkills", {item = 11808, text="PotSkill"},usePotionSkills)



--AntiLize trap
setDefaultTab("HP")
local MsgDetected = "Seu jutsu foi selado"

local isJutsuSealed = false  

onTextMessage(function(mode, text)
  if text:find(MsgDetected) then
    isJutsuSealed = true  -- Marca como selado inicialmente
    local time = tonumber(text:match("(%d+) segundos"))  
    warn(time)
    if time and time > 0 then
      -- Agenda para desativar após o tempo especificado
      schedule(time * 1100, function()  
        isJutsuSealed = false
      end)
    else
      -- Define imediatamente como não selado para casos de "0 segundos"
      isJutsuSealed = false
    end
  end
end)

macro(100, "Anti-Lyze", function() 
  if not isParalyzed() then return end
  if not isJutsuSealed then
    saySpell("Kai") 
  end
end)

macro(1000, "AutoBigSpeed", function()
  local speed = player:getSpeed()   
  if speed <= 1400 then
    if (not isParalyzed() or not hasHaste()) and not isJutsuSealed then
      say("concentrate chakra feet")
    end
  end
end)
--SelarBijuu
macro(200, "Selar Bijuu",  function()
  if g_game.isAttacking() and target() and target():canShoot() and target():getHealthPercent() <= 19 then
  say("Kekkai Shihou Fuujin")
end
end)

macro(2500, "Ver%Target", function()
  local attackingCreature = g_game.getAttackingCreature()
  if attackingCreature then
      hpTarget = attackingCreature:getHealthPercent()
      warn(hpTarget)
  end
end)

UI.Label("Food Items:")
if type(storage.foodItems) ~= "table" then
	storage.foodItems = {3582,3577}
end

local foodContainer = UI.Container(function(widget, items)
  storage.foodItems = items
end, true)
foodContainer:setHeight(35)
foodContainer:setItems(storage.foodItems)

macro(500, "Comer Food", function()
	if (isFull and isFull >= now) then return end
	tryingToEat = tryingToEat or now
	for i, item in ipairs(storage.foodItems) do
		use(item.id)
	end
end)

onTextMessage(function(mode, text)
	if text == 'You are full.' then
		isFull = now + 30000
		tryingToEat = nil
	end
  
end)
