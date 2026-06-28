-- data/r_venomous_abyss.lua
-- The Venomous Abyss (12.1.0 raid).

local _, _, _, tocVersion = GetBuildInfo()
if tocVersion < 120100 then return end

local entries = {
    {
        raid    = "The Venomous Abyss",
        boss    = "Nek'zali the Soulcoiler",
        bossKey = "nekzali_the_soulcoiler",
        section = "|cffae3df5Nek'zali the Soulcoiler|r",
        abilities = {
            { key = "hollowed",             label = "Hollowed",                     privateID = 1284109,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, healing nerfed. Stacks
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Entombed Sentinels",
        bossKey = "entombed_sentinels",
        section = "|cffae3df5Entombed Sentinels|r",
        abilities = {
            { key = "blood_venom",              label = "Blood Venom",                  privateID = 1284210,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Puddle damage
            { key = "blighted_blood",           label = "Blighted Blood",               privateID = 1284471,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 18s Magic Dot
            { key = "debilitating_miasma",      label = "Debilitating Miasma",          privateID = 1284477,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 10s dot, movement decrease, movement reduces stacks.
            { key = "bloodvenom_injection",     label = "Bloodvenom Injection",         privateID = 1284491,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Stacking dot on target (tank)
            { key = "helical_toxins",           label = "Helical Toxins",               privateID = 1284590,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Run into people, stack to exactly 4. 
            { key = "cultivated_burst",         label = "Cultivated Burst",             privateID = 1284947,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Big dot if full duration of helical toxin.
            { key = "unstable_miasma",          label = "Unstable Miasma",              privateID = 1288260,                soundH = {"stack","file:8s"},               soundM = {"stack","file:8s"},                               }, -- Upon expiration, damage split players 5 yards.
            { key = "clinging_murk",            label = "Clinging Murk",                privateID = 1288297,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Unstable Miasma dot
            { key = "shifting_protovenom",      label = "Shifting Protovenom",          privateID = 1296880,                soundH = "marked",                          soundM = "marked",                                          }, -- Hit other protovenoms, colliding - Protovenom Eruption
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Vashnik the Malignant",
        bossKey = "vashnik_the_malignant",
        section = "|cffae3df5Vashnik the Malignant|r",
        abilities = {
            -- TBD
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Lost Explorers",
        bossKey = "the_lost_explorers",
        section = "|cffae3df5The Lost Explorers|r",
        abilities = {
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Sszorak",
        bossKey = "sszorak",
        section = "|cffae3df5Sszorak|r",
        abilities = {
            -- TBD
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Twin Fangs",
        bossKey = "the_twin_fangs",
        section = "|cffae3df5The Twin Fangs|r",
        abilities = {
            -- TBD
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Bargained Crown",
        bossKey = "the_bargained_crown",
        section = "|cffae3df5The Bargained Crown|r",
        abilities = {
            { key = "twinfang_toxin",               label = "Twinfang Toxin",               privateID = 1283345,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Tank Debuff, expires into Twinfang Rupture
            { key = "axegrinder",                   label = "Axegrinder",                   privateID = 1285017,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot when in an axe
            { key = "dreadmarch",                   label = "Dreadmarch",                   privateID = 1285640,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal absorb, turns into adds.
            { key = "dreadmarch_alt",               label = "Dreadmarch Alt",               privateID = 1285647,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal absorb, turns into adds. Alt
            { key = "unnerving_fixation",           label = "Unnerving Fixation",           privateID = 1285911,                soundH = nil,                               soundM = nil,                                               }, -- Fixate by dreadmarch adds
            { key = "shadowfang",                   label = "Shadowfang",                   privateID = 1286326,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},                              }, -- Axe Marks, 15 yard explode after 5s
            { key = "wail_of_terror",               label = "Wail of Terror",               privateID = 1286399,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Fear for 5s
            { key = "gloombomb",                    label = "Gloombomb",                    privateID = 1286901,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},           advanced = true    }, -- Bomb marks, 15 yard damage after 5s. Also Gravebound.
            { key = "defilement_of_the_crucible",   label = "Defilement of the Crucible",   privateID = 1298594,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal Absorb, auto attack to apply toxin
            { key = "blighted_toxin",               label = "Blighted Toxin",               privateID = 1287227,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Snake Statues spit venom. Dot-ish
            { key = "spirit_erasure",               label = "Spirit Erasure",               privateID = 1300665,                soundH = {"debuff","file:4s"},              soundM = {"debuff","file:4s"},           advanced = true    }, -- Soak, increasing on stacks, 4 sec dur
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Ula'tek",
        bossKey = "ulatek",
        section = "|cffae3df5Ula'tek|r",
        abilities = {
            { key = "poisonous_bite",               label = "Poisonous Bite",               privateID = 1287036,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, stacks.
            { key = "mothers_wrath",                label = "Mother's Wrath",               privateID = 1287248,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Probably some egg fuckup
            { key = "mothers_wrath_2",              label = "Mother's Wrath",               privateID = 1302365,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Probably some egg fuckup 2
            { key = "malignant_shell",              label = "Malignant Shell",              privateID = 1295360,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot while carrying egg
            { key = "stone_venom",                  label = "Stone Venom",                  privateID = 1298417,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, movement slow, stacks
            { key = "doomscale_shell",              label = "Doomscale Shell",              privateID = 1300312,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Aoe dam on egg carry unless, pheromones
            { key = "calcified_corpse",             label = "Calcified Corpse",             privateID = 1306119,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Petrifies, big dot. Immunity stopper?
            { key = "greasy_hatchling",             label = "Greasy Hatchling",             privateID = 1306388,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, losing grip in 20.
            { key = "butter_fingers",               label = "Butter Fingers",               privateID = 1306393,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Can't pick up egg, 1min
            { key = "noxious_shell",                label = "Noxious Shell",                privateID = 1307612,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Holding shell debuff. Causing noxious Splash
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Uncategorized",
        bossKey = "uncategorized",
        section = "|cffae3df5Uncategorized|r",
        abilities = {
            { key = "gnashing_extraction",          label = "Gnashing Extraction",          privateID = 1287551,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Pulling a fang 15 yards
            { key = "vine_grip",                    label = "Vine Grip",                    privateID = 1287797,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Make vines, 13 people pull
            { key = "petrified",                    label = "Petrified",                    privateID = 1288891,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Viper Venom turn to stone, heal fully
            { key = "caustic_venom",                label = "Caustic Venom",                privateID = 1290036,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, if 5 stacks big 50yd boom
            { key = "fixate_12.1.0_1",              label = "Fixate",                       privateID = 1292782,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some fixate somewhere
            { key = "noxious_poison",               label = "Noxious Poison",               privateID = 1295701,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some poison puddle
            { key = "serpents_bite_1",              label = "Serpent's Bite 1",             privateID = 1295840,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some bite
            { key = "serpents_bite_2",              label = "Serpent's Bite 2",             privateID = 1295844,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some bite 2
            { key = "toxic_wounds",                 label = "Toxic Wounds",                 privateID = 1296203,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Stacking dot
            { key = "tide_wave",                    label = "Tide Wave",                    privateID = 1298157,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dunno
            { key = "dunduns_strange_shape",        label = "Dundun's Strange Shape",       privateID = 1297815,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- dunno
            { key = "necrotic_anguish",             label = "Necrotic Anguish",             privateID = 1299467,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, heal absorb
            { key = "fixate_tormentor",             label = "Fixate",                       privateID = 1300704,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Fixated by a faithless tormentor
            { key = "unstable_venom",               label = "Unstable Venom",               privateID = 1301478,                soundH = "spread",                          soundM = "spread",                       advanced = true    }, -- Dot, spread 14s
            { key = "corrosive_tempest",            label = "Corrosive Tempest",            privateID = 1305386,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dunno, dot and movement speed or something
            { key = "toxic_beam",                   label = "Toxic Beam",                   privateID = 1306856,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Beam, does damage when hit
            
        },
    },
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid[#CCS_Spells_Raid + 1] = e
end




