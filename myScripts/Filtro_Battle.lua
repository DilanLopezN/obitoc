-- setDefaultTab('Main')
-- local PainelName = "FiltroBattles"
-- FiltroIcon = setupUI([[
-- Panel
--   height: 20
--   margin-top: 3
  
--   Panel
--     id: inicio
--     anchors.top: parent.top
--     anchors.left: parent.left
--     margin-left: 0
--     margin-top:
--     image-border: 2
--     text-align: center
--     text-align: left
--     width: 200
--     height: 20
--     image-source: 
--     font: verdana-11px-rounded
--     opacity: 0.80

--   Panel
--     id: buttons
--     anchors.top: parent.top
--     anchors.horizontalCenter: parent.horizontalCenter
--     height: 20
--     width: 15 0
--     layout:
--       type: horizontalBox
--       spacing: 20

--   BattlePlayers
--     id: players
--     border: 1 #778899
--     image-color: white
--     anchors.top: parent.top
--     anchors.left: parent.left
--     margin-left: 23
--     image-source: /images/game/battle/battle_players
--     !tooltip: tr('Filtrar players.')

--   BattleNPCs
--     id: npcs
--     border: 1 #778899
--     anchors.top: parent.top
--     anchors.left: parent.left
--     margin-left: 54
--     text-align: center
--     image-source: /images/game/battle/battle_npcs
--     !tooltip: tr('Filtrar Npcs.')
--     @onCheckChange: modules.game_battle.checkCreatures()

--   BattleMonsters
--     id: mobs
--     border: 1 #778899
--     anchors.top: parent.top
--     anchors.left: parent.left
--     margin-left: 86
--     text-align: center
--     image-source: /images/game/battle/battle_monsters
--     !tooltip: tr('Filtrar mobs.')
--     opacity: 0.85
--     @onCheckChange: modules.game_battle.checkCreatures()

--   BattleSkulls
--     id: sempk
--     border: 1 #778899
--     anchors.top: parent.top
--     anchors.left: parent.left
--     margin-left: 118
--     text-align: center
--     image-source: /images/game/battle/battle_skulls
--     !tooltip: tr('Filtrar Player sem PK.')
--     opacity: 0.85
--     @onCheckChange: modules.game_battle.checkCreatures()

--   BattleParty
--     id: party
--     border: 1 #778899
--     anchors.top: parent.top
--     anchors.left: parent.left
--     margin-left: 150
--     text-align: center
--     image-source: /images/game/battle/battle_party
--     !tooltip: tr('Filtrar Membros do Grupo.')
--     opacity: 0.85
--     @onCheckChange: modules.game_battle.checkCreatures()
-- ]], parent)

-- local FiltroPlayers = false
-- local FiltroNpcs = false
-- local FiltroMobs = false
-- local FiltroSkull = false
-- local FiltroParty = false


-- local function updateIconColors()
--   FiltroIcon.players:setImageColor(FiltroPlayers and '#696969' or '#FFFFFF') 
--   FiltroIcon.npcs:setImageColor(FiltroNpcs and '#696969' or '#FFFFFF')
--   FiltroIcon.mobs:setImageColor(FiltroMobs and '#696969' or '#FFFFFF')
--   FiltroIcon.sempk:setImageColor(FiltroSkull and '#696969' or '#FFFFFF')
--   FiltroIcon.party:setImageColor(FiltroParty and '#696969' or '#FFFFFF')
-- end


-- FiltroIcon.players.onClick = function(widget)
--   FiltroPlayers = not FiltroPlayers
--   updateIconColors() 
-- end


-- FiltroIcon.npcs.onClick = function(widget)
--   FiltroNpcs = not FiltroNpcs
--   updateIconColors()
-- end


-- FiltroIcon.mobs.onClick = function(widget)
--   FiltroMobs = not FiltroMobs
--   updateIconColors()
-- end


-- FiltroIcon.sempk.onClick = function(widget)
--   FiltroSkull = not FiltroSkull
--   updateIconColors()
-- end


-- FiltroIcon.party.onClick = function(widget)
--   FiltroParty = not FiltroParty
--   updateIconColors()
-- end

-- FiltrarBattle = macro(1, function() end)
-- modules.game_battle.doCreatureFitFilters = function(creature)
--   if creature:isLocalPlayer() or creature:getHealthPercent() <= 0 then
--     return false
--   end
--   local pos = creature:getPosition()
--   if not pos or pos.z ~= posz() or not creature:canBeSeen() then return false end

--   if creature:isMonster() and FiltrarBattle.isOn() and FiltroMobs then
--     return false
--   elseif creature:isPlayer() and FiltrarBattle.isOn() and FiltroPlayers then
--     return false
--   elseif creature:isNpc() and FiltrarBattle.isOn() and FiltroNpcs then
--     return false
--     --Alterar ==1 para 10 para não filtrar a Guild
--   elseif creature:isPlayer() and (creature:getEmblem() == 1 or creature:getShield() == 3 or creature:getShield() == 4) and FiltrarBattle.isOn() and FiltroParty then
--     return false
--   elseif creature:isPlayer() and creature:getSkull() == 0 and FiltroSkull then
--     return false
--   end
--   return true
-- end


-- Certifique-se de que o painel de batalha já está visível
modules.game_battle.battleWindow:show()
local filterPanel = modules.game_battle.filterPanel

-- Caso queira armazenar estados entre sessões, utilize storage:
if not storage.customBattleFilters then
  storage.customBattleFilters = {
    filterPlayers = false,
    filterNpcs = false,
    filterMobs = false,
    filterSkull = false,
    filterParty = false
  }
end

-- Criação dos botões de filtro no painel existente
-- Exemplo de criação de um botão similar aos outros (hidePlayers, etc.)
-- Você pode customizar o nome do widget no .otui do battle ou criar no Lua dinamicamente:

local filterPlayersBtn = UI.createWidget('BattlePlayers', filterPanel.buttons)
filterPlayersBtn:setTooltip('Filtrar Players')
filterPlayersBtn:setChecked(storage.customBattleFilters.filterPlayers)
filterPlayersBtn.onCheckChange = function(widget)
  storage.customBattleFilters.filterPlayers = widget:isChecked()
  modules.game_battle.checkCreatures()
end

local filterNpcsBtn = UI.createWidget('BattleNPCs', filterPanel.buttons)
filterNpcsBtn:setTooltip('Filtrar Npcs')
filterNpcsBtn:setChecked(storage.customBattleFilters.filterNpcs)
filterNpcsBtn.onCheckChange = function(widget)
  storage.customBattleFilters.filterNpcs = widget:isChecked()
  modules.game_battle.checkCreatures()
end

local filterMobsBtn = UI.createWidget('BattleMonsters', filterPanel.buttons)
filterMobsBtn:setTooltip('Filtrar Mobs')
filterMobsBtn:setImageSource("/images/game/battle/battle_monsters")
filterMobsBtn:setChecked(storage.customBattleFilters.filterMobs)
filterMobsBtn.onCheckChange = function(widget)
  storage.customBattleFilters.filterMobs = widget:isChecked()
  modules.game_battle.checkCreatures()
end
local filterSkullBtn = UI.createWidget('BattleSkulls', filterPanel.buttons)
filterSkullBtn:setTooltip('Filtrar Player sem PK (sem skull)')
filterSkullBtn:setChecked(storage.customBattleFilters.filterSkull)
filterSkullBtn.onCheckChange = function(widget)
  storage.customBattleFilters.filterSkull = widget:isChecked()
  modules.game_battle.checkCreatures()
end

local filterPartyBtn = UI.createWidget('BattleParty', filterPanel.buttons)
filterPartyBtn:setTooltip('Filtrar Membros do Grupo')
filterPartyBtn:setChecked(storage.customBattleFilters.filterParty)
filterPartyBtn.onCheckChange = function(widget)
  storage.customBattleFilters.filterParty = widget:isChecked()
  modules.game_battle.checkCreatures()
end

-- Agora ajustamos a função doCreatureFitFilters
-- Vamos integrar sua lógica de filtro nesta função já existente.

local originalDoCreatureFitFilters = modules.game_battle.doCreatureFitFilters
modules.game_battle.doCreatureFitFilters = function(creature)
    -- Mantenha a lógica base já existente se necessário
    if creature:isLocalPlayer() then
      return false
    end
    if creature:getHealthPercent() <= 0 then
      return false
    end

    local pos = creature:getPosition()
    if not pos then return false end

    local localPlayer = g_game.getLocalPlayer()
    if pos.z ~= localPlayer:getPosition().z or not creature:canBeSeen() then return false end

    -- Filtros padrões do OTC (se você já os possui)
    local hidePlayers = filterPanel.buttons.hidePlayers and filterPanel.buttons.hidePlayers:isChecked()
    local hideNPCs = filterPanel.buttons.hideNPCs and filterPanel.buttons.hideNPCs:isChecked()
    local hideMonsters = filterPanel.buttons.hideMonsters and filterPanel.buttons.hideMonsters:isChecked()
    local hideSkulls = filterPanel.buttons.hideSkulls and filterPanel.buttons.hideSkulls:isChecked()
    local hideParty = filterPanel.buttons.hideParty and filterPanel.buttons.hideParty:isChecked()

    if hidePlayers and creature:isPlayer() then
      return false
    elseif hideNPCs and creature:isNpc() then
      return false
    elseif hideMonsters and creature:isMonster() then
      return false
    elseif hideSkulls and creature:isPlayer() and creature:getSkull() == 0 then
      return false
    elseif hideParty and creature:isPlayer() and (creature:getEmblem() == 1 or creature:getShield() == 3 or creature:getShield() == 4) then
      return false
    end

    -- Aqui entram os novos filtros que criamos:
    -- Checamos se estão ativos e se a criatura se enquadra

    -- Filtro Players
    if storage.customBattleFilters.filterPlayers and creature:isPlayer() then
      return false
    end

    -- Filtro Npcs
    if storage.customBattleFilters.filterNpcs and creature:isNpc() then
      return false
    end

    -- Filtro Mobs
    if storage.customBattleFilters.filterMobs and creature:isMonster() then
      return false
    end

    -- Filtro Skull (player sem skull)
    if storage.customBattleFilters.filterSkull and creature:isPlayer() and creature:getSkull() == 0 then
      return false
    end

    -- Filtro Party (membros do grupo)
    if storage.customBattleFilters.filterParty and creature:isPlayer() and (creature:getEmblem() == 1 or creature:getShield() == 3 or creature:getShield() == 4) then
      return false
    end

    -- Retorno final se passar por todos os filtros
    return true
end

-- Se necessário, você pode chamar modules.game_battle.checkCreatures() para atualizar a lista
modules.game_battle.checkCreatures()

for _, i in pairs(modules.game_battle.battleWindow.filterPanel.buttons:getChildren()) do
  if i:getId() == "hideMonsters" then
    i:setImageSource("/images/game/battle/battle_monsters")
    i:setTooltip("Hide monsters")
    i.onCheckChange = function(self, checkd)
      battleUpdated.hideMonsters = checkd
      self:setChecked(battleUpdated.hideMonsters)
      modules.game_battle.doCreatureFitFilters = filter
      modules.game_battle.checkCreatures()
    end
  elseif i:getId() == "hideSkulls" then
    i:setImageSource("/images/game/battle/battle_skulls")
    i:setTooltip("Hide non-skulls")
    i.onCheckChange = function(self, checkd)
      battleUpdated.hideNonSkulls = checkd
      self:setChecked(battleUpdated.hideNonSkulls)
      modules.game_battle.doCreatureFitFilters = filter
      modules.game_battle.checkCreatures()
    end
  end   
end