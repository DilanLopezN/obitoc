-----------------------*******@Jeangz*********------------------------  
local configName = modules.game_bot.contentsPanel.config:getCurrentOption().text

local configFiles = g_resources.listDirectoryFiles("/bot/" .. configName .. "/myScripts", true, false)
for i, file in ipairs(configFiles) do
  local ext = file:split(".")
  if ext[#ext]:lower() == "ui" or ext[#ext]:lower() == "otui" then
    g_ui.importStyle(file)
  end
end

local function loadScript(name)
  return dofile("/myScripts/" .. name .. ".lua")
end

local luaFiles = {
"Main",
"Cura",
"Macros",
"Alarms",
"Filtro_Battle",
"Combo_Fuga_Key_SpellEnemy",
"TimeSpell",
"Especiais",
"BugMap",
"Escadas",
"Jump",
"Sense",
"Follow",
"Travel",
"Volta_Target",
"PK_Time",
}

for i, file in ipairs(luaFiles) do
  loadScript(file)
end
-----------------------*******@Jeangz*********------------------------
applyMacrosBorder()
