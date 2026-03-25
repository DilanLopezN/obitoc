----Criar tabs que irei utilizar-----
setDefaultTab("HP")
setDefaultTab("Tools")
setDefaultTab("Macros")
setDefaultTab("Cave")
----In game scripts-----
setDefaultTab("Tools")
corText = '#FFFFFF'
Img = 'CodeMaster.png'
-- allows to test/edit bot lua scripts ingame, you can have multiple scripts like this, just change storage.ingame_lua
UI.Button("Ingame script editor", function(newText)
    UI.MultilineEditorWindow(storage.ingame_hotkeys or "-----Cor da custom-----\n corText = '#00FFFF'\n-----Imagem-----\n Img = 'CodeMaster.png'\n----------------------------------------------------------Nao apagar acima---------\n", 
    {title="Hotkeys editor", description="You can add your custom scripts here"}, function(text)
      storage.ingame_hotkeys = text
      reload()
    end)
  end)
    
  for _, scripts in pairs({storage.ingame_hotkeys}) do
    if type(scripts) == "string" and scripts:len() > 3 then
      local status, result = pcall(function()
        assert(load(scripts, "ingame_editor"))()
      end)
      if not status then 
        error("Ingame edior error:\n" .. result)
      end
    end
  end
-------Import styles----------
setDefaultTab("Main")
importStyle("/myScripts/Tabs.otui")
----------------Cor dos OTUIs - text -----------------------------------
--color: ]] .. corText .. [[
modules.game_bot.botWindow:setColor(corText) -- Cor do texto
-------------------------------------------------------------------
-----------------------Config imagem---------------------------------------------------------------------------------------------------------------------------------
local configName = modules.game_bot.contentsPanel.config:getCurrentOption().text;
local Imgs = "/bot/" .. configName .. "/Img/";
----Set imagem no bot panel----
modules.game_bot.contentsPanel.botPanel:setImageSource(Imgs .. Img)
modules.game_bot.contentsPanel.botPanel:setImageColor("#FFFFFF99")
---------Bot inteiro------
modules.game_bot.botWindow:setImageSource(Imgs .. Img)
modules.game_bot.botWindow:setImageColor("#FFFFFF99")
----BotWindow------
modules.game_bot.botWindow:setBackgroundColor("#000000") -- Preto
modules.game_bot.botWindow:setText("Jeangz") -- Nome do bot
modules.game_bot.botWindow:setColor(corText) -- Cor do texto
modules.game_bot.botWindow:setWidth(200)--Largura
modules.game_bot.botWindow:setHeight(400)--Altura
----Botao config------
modules.game_bot.contentsPanel.config:setColor(corText)
modules.game_bot.contentsPanel.config:setImageSource("") -- Limpa a imagem de fundo
modules.game_bot.contentsPanel.config:setBackgroundColor("alpha") --Tira plano de fundo do botao Edit
modules.game_bot.contentsPanel.config:setBorderColor(corText) -- Poem borda botao Edit
----Botao edit------
modules.game_bot.contentsPanel.editConfig:setImageSource("") -- Limpa a imagem de fundo
modules.game_bot.contentsPanel.editConfig:setColor(corText) -- Limpa a imagem de fundo
modules.game_bot.contentsPanel.editConfig:setBorderColor(corText) -- Limpa a imagem de fundo
----Botao Enable----
modules.game_bot.contentsPanel.enableButton:setImageSource("") -- Limpa a imagem de fundo
----Separadores-----
-- modules.game_bot.contentsPanel.widget1319:hide()
-- modules.game_bot.contentsPanel.widget1321:hide()
--------------------------------------------------------------------------------------------------------------------------------------------------------
------------------Tirar scroll das tabs e aplica o estilo novo-----------------
-- Função para aplicar estilo, esconder scroll e atualizar widgets em todas as tabs
local botTabs = modules.game_bot.contentsPanel and modules.game_bot.contentsPanel.botTabs
if botTabs and botTabs.tabs then
    for _, tab in pairs(botTabs.tabs) do
        local widget = tab.tabPanel and tab.tabPanel:recursiveGetChildById("botPanelScroll")
        if widget then 
            tab:setStyle("CustomTabBarButton")
            tab:setColor(corText)
            tab:setBorderColor(corText)
        end
    end
end

-- Escondendo widgets com IDs correspondentes
if modules.game_bot.contentsPanel then
    for _, child in pairs(modules.game_bot.contentsPanel:getChildren()) do
        if child:getId():match("^widget%d+$") then
            child:hide()
        end
    end
end
-----------------Atualiza botoes------------------------------------
function applyMacrosBorder()
  for _, rootW in pairs(modules.game_bot.botWindow.contentsPanel.botPanel:recursiveGetChildById("content"):getChildren()) do
    -- Verifica se o widget NÃO é um checkBox
    if rootW:getClassName() ~= "UICheckBox" then
      rootW:setImageSource()
      rootW:setColor(rootW:isOn() and corText or "white")
        -- Ajustando margens:
      rootW.onMousePress = function(widget, mousePos, mouseButton)
        macro(200, function()
          widget:setColor(widget:isOn() and corText or "white")
        end)
      end
    end
  end
end

