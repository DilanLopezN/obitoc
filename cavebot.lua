-- Cavebot by otclient@otclient.ovh
-- visit http://bot.otclient.ovh/

local cavebotTab = "Cave"
--local targetingTab = "Target"
CaveBot = CaveBot or {}
setDefaultTab(cavebotTab)
UI.Separator()
UI.Label("---Cave_Bot---")
UI.Separator()
CaveBot.Extensions = {}
importStyle("/cavebot/cavebot.otui")
importStyle("/cavebot/config.otui")
importStyle("/cavebot/editor.otui")
dofile("/cavebot/actions.lua")
dofile("/cavebot/config.lua")
dofile("/cavebot/editor.lua")
dofile("/cavebot/example_functions.lua")
dofile("/cavebot/recorder.lua")
dofile("/cavebot/walking.lua")
-- in this section you can add extensions, check extension_template.lua
--dofile("/cavebot/extension_template.lua")
dofile("/cavebot/sell_all.lua")
dofile("/cavebot/depositor.lua")
dofile("/cavebot/buy_supplies.lua")
dofile("/cavebot/d_withdraw.lua")
dofile("/cavebot/supply_check.lua")
dofile("/cavebot/travel.lua")
dofile("/cavebot/doors.lua")
dofile("/cavebot/pos_check.lua")
dofile("/cavebot/withdraw.lua")
dofile("/cavebot/inbox_withdraw.lua")
dofile("/cavebot/lure.lua")
dofile("/cavebot/bank.lua")
dofile("/cavebot/clear_tile.lua")
dofile("/cavebot/tasker.lua")
-- main cavebot file, must be last
dofile("/cavebot/cavebot.lua")

setDefaultTab(cavebotTab)
UI.Separator()
UI.Label("---Target_Bot---")
UI.Separator()
TargetBot = {} -- global namespace
importStyle("/targetbot/looting.otui")
importStyle("/targetbot/target.otui")
importStyle("/targetbot/creature_editor.otui")
dofile("/targetbot/creature.lua")
dofile("/targetbot/creature_attack.lua")
dofile("/targetbot/creature_editor.lua")
dofile("/targetbot/creature_priority.lua")
dofile("/targetbot/looting.lua")
dofile("/targetbot/walking.lua")
-- main targetbot file, must be last
dofile("/targetbot/target.lua")


local cIcon = addIcon("cI",{text="Cave\nBot",switchable=false,moveable=true}, function()
    if CaveBot.isOff() then 
      CaveBot.setOn()
    else 
      CaveBot.setOff()
    end
  end)
  cIcon:setSize({height=30,width=50})
  cIcon.text:setFont('verdana-11px-rounded')
  
  local tIcon = addIcon("tI",{text="Target\nBot",switchable=false,moveable=true}, function()
    if TargetBot.isOff() then 
      TargetBot.setOn()
    else 
      TargetBot.setOff()
    end
  end)
  tIcon:setSize({height=30,width=50})
  tIcon.text:setFont('verdana-11px-rounded')
  
  macro(50,function()
    if CaveBot.isOn() then
      cIcon.text:setColoredText({"CaveBot\n","white","ON","green"})
    else
      cIcon.text:setColoredText({"CaveBot\n","white","OFF","red"})
    end
    if TargetBot.isOn() then
      tIcon.text:setColoredText({"Target\n","white","ON","green"})
    else
      tIcon.text:setColoredText({"Target\n","white","OFF","red"})
    end
  end)
  