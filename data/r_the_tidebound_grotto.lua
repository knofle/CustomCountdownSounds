-- data/r_the_tidebound_grotto.lua
-- The Tidebound Grotto (12.1.0 single boss raid).

local _, _, _, tocVersion = GetBuildInfo()
if tocVersion < 120100 then return end

local entries = {
    {
        raid    = "The Tidebound Grotto",
        boss    = "Nymrissa Wavecaller",
        bossKey = "nymrissa_wavecaller",
        section = "|cffae3df5Nymrissa Wavecaller|r",
        journalInstanceID = 1317,
        journalEncounterID = 2849,         
        abilities = {
            { key = "lingering_frost",              label = "Lingering Frost",              privateID = 1257654,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot and sliding debuff.
            { key = "tidepiercers_rush",            label = "Tidepiercer's Rush",           privateID = 1258677,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot 
            { key = "tide_wave",                    label = "Tide Wave",                    privateID = 1298157,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dunno           
        },
    },
    
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid[#CCS_Spells_Raid + 1] = e
end
