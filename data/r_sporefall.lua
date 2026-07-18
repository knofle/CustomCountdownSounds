-- data/r_sporefall.lua
-- Sporefall raid (12.0.7 – 12.0.x).

local _, _, _, tocVersion = GetBuildInfo()
if tocVersion < 120007 or tocVersion >= 120100 then return end

local sporefall = {

    {
        raid    = "Sporefall",
        boss    = "Rotmire",
        bossKey = "rotmire",
        section = "|cffb8c777Rotmire|r",
        abilities = {
            { key = "shroomling_fixate",    label = "Shroomling Fixate",    privateID = 1221639, soundH = "file:shroomling",        soundM = "file:shroomling", desc = "Purple adds that fixate you. Do not kill Shroomlings and Funglings in the same place!"     }, 
            { key = "fungling_fixate",      label = "Fungling Fixate",      privateID = 1299508, soundH = "file:fungling",          soundM = "file:fungling", desc = "Blueish adds that fixate you. Do not kill Shroomlings and Funglings in the same place!"       }, 
            { key = "festering_vines",      label = "Festering Vines",      privateID = 1222088, soundH = {"drop","file:8s"},       soundM = {"drop","file:8s"}, desc = "Circle around you that pops and leaves a puddle after 8 seconds. Run out with this"    }, -- 8 Second dot/slow, leaves Writhing Vines
            { key = "poison_burst",         label = "Poison Burst",         privateID = 1221714, soundH = nil,                      soundM = nil,                   advanced = true }, -- AoE Cast
            { key = "bursting_pustules",    label = "Bursting Pustules",    privateID = 1221787, soundH = nil,                      soundM = nil,                   advanced = true }, -- Stacking raid wide AoE damage
            { key = "writhing_vines",       label = "Writhing Vines",       privateID = 1222129, soundH = nil,                      soundM = nil,                   advanced = true }, -- Damage Puddle tick
            { key = "bursting_doom_shroom", label = "Bursting Doom Shroom", privateID = 1222495, soundH = nil,                      soundM = nil,                   advanced = true }, -- AoE Damage, you fucked up stacking small shitters
            { key = "mystery_mushroom",     label = "Mystery Mushroom",     privateID = 1296517, soundH = nil,                      soundM = nil,                   advanced = true }, -- Knockback debuff of some sort?
        },
    },

}

for _, entry in ipairs(sporefall) do
    CCS_Spells_Raid[#CCS_Spells_Raid + 1] = entry
end