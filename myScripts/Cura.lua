-- em algum lugar do seu código, defina:
storage.outfitBijuu = {158, 161, 303, 269, 162, 301, 302, 268, 531}
local function inTable(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end
cdYaba = false 
CONFIG = {
    regen = {
        {spell = 'big regeneration', cooldown = 250},
    },
    regenBju = {
        {spell = 'bijuu regeneration', cooldown = 250},
    },
    pot = {
        {id = 107, orangeText = 'i feel better!', cooldown = 500},
    },
    pot2 = {
        {id = 11813, orangeText = 'i feel better!', cooldown = 500},
    }
  }

macro(1, function()
    if isInPz() then return; end
    if hppercent() >= 100 then return; end
    if inTable(storage.outfitBijuu, player:getOutfit().type) then 
        if outfit().type == 301 and cdYaba == false then 
            say('bijuu yaiba')            
        end
        for index, value in ipairs(CONFIG.regenBju) do
            if (not value.exhaust or value.exhaust <= now) then
                say(value.spell)
            end
        end
    else
        for index, value in ipairs(CONFIG.regen) do
            if (not value.exhaust or value.exhaust <= now) then
                say(value.spell)
            end
        end
    end
  end)

onTalk(function(name, level, mode, text)
    if name ~= player:getName() then return end
    if not (text:lower():find("bijuu yaiba")) then return end
    if text:lower():find("bijuu yaiba") then       
        cdYaba = true
        schedule(15250, function() cdYaba = false end)
    end
end)