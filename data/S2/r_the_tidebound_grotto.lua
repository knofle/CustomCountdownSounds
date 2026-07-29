-- data/r_the_tidebound_grotto.lua
-- The Tidebound Grotto (12.1.0 single boss raid).

local _, _, _, tocVersion = GetBuildInfo()
if tocVersion < 120100 then return end

local entries = {
    {
        raid    = "The Tidebound Grotto",
        boss    = "Nymrissa Wavecaller",
        bossKey = "nymrissa_wavecaller",
        section = "|cff4dabd7Nymrissa Wavecaller|r",
        journalInstanceID = 1317,
        journalEncounterID = 2849,         
        abilities = {
            { key = "lingering_frost",              label = "Lingering Frost",              privateID = 1257654,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Dot and sliding debuff.
            { key = "tidepiercers_rush",            label = "Tidepiercer's Rush",           privateID = 1258677,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Dot
            --{ key = "tide_wave",                    label = "Tide Wave",                    privateID = 1298157,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dunno           
            { key = "drifting_globules",            label = "Drifting Globules",            privateID = {1257651, 1282537 },     soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "water_jet_tank",              label = "Water Jet (tank)",             privateID = 1258901,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "water_jet",                    label = "Water Jet",                    privateID = 1260637,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "water_flurry",                 label = "Water Flurry",                 privateID = 1282937,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Journal ID, verify aura
            { key = "drenched",                     label = "Drenched",                     privateID = 1282404,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Journal ID, verify aura
            { key = "frost_barrage",                label = "Frost Barrage",                privateID = 1257608,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "frost_barrage_dot",            label = "Frost Barrage (dot)",          privateID = 1257644,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "wild_bite",                    label = "Wild Bite",                    privateID = 1265425,                soundH = nil,                               soundM = nil,                            advanced = true },
        },
    },
    
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid[#CCS_Spells_Raid + 1] = e
end