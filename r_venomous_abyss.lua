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
        journalInstanceID = 1320,
        journalEncounterID = 2888,
        abilities = {
            { key = "hungering_pyre",               label = "Hungering Pyre",               privateID = 1306666,                soundH = {"soak","file:7,5s"},              soundM = {"soak","file:7,5s"},                              }, -- Big stack, clears adds. Share
            { key = "cremation",                    label = "Cremation",                    privateID = 1289875,                soundH = "spread",                          soundM = "spread",                                          }, -- Aoe around people who stacked.            
            { key = "essence_rend",                 label = "Essence Rend",                 privateID = 1287434,                soundH = {"drop","file:5s"},                soundM = {"drop","file:5s"},                                },            
            { key = "slithering_flame",             label = "Slithering Flame",             privateID = 1294933,                soundH = "clear",                           soundM = "clear",                                           }, -- Goes on whoever didn't stack.            
            { key = "hollowed",                     label = "Hollowed",                     privateID = 1284109,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, healing nerfed. On tank Stacks
            { key = "soulcoil_rite",                label = "Soulcoil Rite",                privateID = 1288772,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, stacks when spirits are consumed
            { key = "corpse_blight",                label = "Corpse Blight",                privateID = 1307939,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 20 second dot after amani die.
            { key = "ritual_burn",                  label = "Ritual Burn",                  privateID = 1297624,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Increased damage from soulcoil rite, 1m. 
            { key = "residual_toll",                label = "Residual Toll",                privateID = 1298698,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, gives them hollowed after 12s
            { key = "soulcoil_well",                label = "Soulcoil Well",                privateID = 1285623,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "latent_cultist",               label = "Latent Cultist",               privateID = 1288554,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "possession_barrage",           label = "Possession Barrage",           privateID = 1284103,                soundH = nil,                               soundM = nil,                            advanced = true    },

        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Entombed Sentinels",
        bossKey = "entombed_sentinels",
        section = "|cffae3df5Entombed Sentinels|r",
        journalInstanceID = 1320,
        journalEncounterID = 2874,
        abilities = {
            { key = "unstable_miasma",          label = "Unstable Miasma",              privateID = 1288260,                soundH = {"stack","file:8s"},               soundM = {"stack","file:8s"},                               }, -- Upon expiration, damage split players 5 yards.
            { key = "clinging_murk",            label = "Clinging Murk",                privateID = 1288297,                soundH = {"drop","file:6s"},                soundM = {"drop","file:6s"},                                }, -- Unstable Miasma dot
            { key = "helical_toxins",           label = "Helical Toxins",               privateID = 1284590,                soundH = "clear",                           soundM = "clear",                                           }, -- Run into people, stack to exactly 4.    
            { key = "mark_of_acid",             label = "Mark of Acid",                 privateID = 1284500,                soundH = "file:acid",                       soundM = "file:acid",                    advanced = true    },
            { key = "mark_of_blood",            label = "Mark of Blood",                privateID = 1284506,                soundH = "file:blood",                      soundM = "file:blood",                   advanced = true    },            
            { key = "shifting_protovenom",      label = "Shifting Protovenom",          privateID = 1296880,                soundH = "clear",                           soundM = "clear",                        advanced = true    }, -- Hit other protovenoms, colliding - Protovenom Eruption                                             
            { key = "blood_venom",              label = "Blood Venom",                  privateID = 1284210,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Puddle damage
            { key = "blighted_blood",           label = "Blighted Blood",               privateID = 1284471,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 18s Magic Dot
            { key = "debilitating_miasma",      label = "Debilitating Miasma",          privateID = 1284477,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 10s dot, movement decrease, movement reduces stacks.
            { key = "bloodvenom_injection",     label = "Bloodvenom Injection",         privateID = 1284491,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Stacking dot on target (tank)
            { key = "cultivated_burst",         label = "Cultivated Burst",             privateID = 1284947,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Big dot if full duration of helical toxin.
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Vashnik the Malignant",
        bossKey = "vashnik_the_malignant",
        section = "|cffae3df5Vashnik the Malignant|r",
        journalInstanceID = 1320,
        journalEncounterID = 2882,        
        abilities = {
            --{ key = "plague_froth_incubate",        label = "Plague Froth (incubate)",      privateID = 1281910,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 2s incubate
            --{ key = "plague_froth_dot",             label = "Plague Froth (dot)",           privateID = 1281908,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 6s dot
            --{ key = "plague_froth_untooltipped",    label = "Plague Froth (untooltipped)",  privateID = 1282078,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- No tooltip
            { key = "plague_froth_mythic",          label = "Plague Froth",                 privateID = {1281908, 1281913},     soundH = {"spread","file:6s"},              soundM = {"spread","file:6s"},                              }, -- Mythic?
            { key = "exploding_infection",          label = "Exploding Infection",          privateID = 1295173,                soundH = {"file:exploding","file:10s"},     soundM = {"file:exploding","file:10s"},                     },
            { key = "siphoning_infection_target",   label = "Siphoning Infection",          privateID = 1295380,                soundH = "file:siphon",                     soundM = "file:siphon",                                     }, -- Being siphoned by main boss
            { key = "stygian_infection",            label = "Stygian Infection",            privateID = 1294994,                soundH = "drop",                            soundM = "drop",                                            },
            { key = "clotting_blood",               label = "Clotting Blood",               privateID = 1302517,                soundH = "absorb",                          soundM = "absorb",                       advanced = true    },                                                
            { key = "congealing_bolt",              label = "Congealing Bolt",              privateID = 1305833,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "dripping_fangs",               label = "Dripping Fangs",               privateID = 1280934,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "caustic_surge",                label = "Caustic Surge",                privateID = 1285979,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "virulent_fumes",               label = "Virulent Fumes",               privateID = 1291461,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "siphoning_infection_secondary",label = "Siphoning Secondary",          privateID = 1295224,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Target on you siphoning nearby
            { key = "adaptive_infection",           label = "Adaptive Infection",           privateID = 1282117,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Lost Explorers",
        bossKey = "the_lost_explorers",
        section = "|cffae3df5The Lost Explorers|r",
        journalInstanceID = 1320,
        journalEncounterID = 2894,        
        abilities = {
            { key = "steady_strikes",               label = "Steady Strikes",               privateID = 1291929,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "splinters",                    label = "Splinters",                    privateID = 1308853,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "shredding_shards",             label = "Shredding Shards",             privateID = 1295858,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "mighty_thud",                  label = "Mighty Thud",                  privateID = 1296133,                soundH = "targeted",                        soundM = "targeted",                                        },
            { key = "shell_spin",                   label = "Shell Spin",                   privateID = 1291918,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "burning_flames",               label = "Burning Flames",               privateID = 1295928,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "piercing_frost",               label = "Piercing Frost",               privateID = 1295954,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "frost_patch",                  label = "Frost Patch",                  privateID = 1297648,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "explosive_surprise",           label = "Explosive Surprise",           privateID = 1297625,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "bounce",                       label = "Bounce",                       privateID = 1299854,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "fire_patch",                   label = "Fire Patch",                   privateID = 1297649,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "blast_wave",                   label = "Blast Wave",                   privateID = 1305844,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "icebound_flames",              label = "Icebound Flames",              privateID = 1286922,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "spooky_mask",                  label = "Spooky Mask",                  privateID = 1310032,                soundH = "file:buff",                       soundM = "file:buff",                                       },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Sszorak",
        bossKey = "sszorak",
        section = "|cffae3df5Sszorak|r",
        journalInstanceID = 1320,
        journalEncounterID = 2871,        
        abilities = {
            { key = "corroding_venom",              label = "Corroding Venom",              privateID = 1282873,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "mutilate",                     label = "Mutilate",                     privateID = 1277051,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tempest",                      label = "Tempest",                      privateID = 1287083,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "venomous_surge",               label = "Venomous Surge",               privateID = 1305963,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "debilitating_venom",           label = "Debilitating Venom",           privateID = 1295123,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "raging_crosswinds_1",          label = "Raging Crosswinds 1",          privateID = 1285425,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "raging_crosswinds_2",          label = "Raging Crosswinds 2",          privateID = 1285453,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "caustic_residue",              label = "Caustic Residue",              privateID = 1296667,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "viscous_cyst",                 label = "Viscous Cyst",                 privateID = 1287205,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "turbulent_gusts",              label = "Turbulent Gusts",              privateID = 1285447,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Twin Fangs",
        bossKey = "the_twin_fangs",
        section = "|cffae3df5The Twin Fangs|r",
        journalInstanceID = 1320,
        journalEncounterID = 2887,        
        abilities = {
            { key = "eternal_venom",                label = "Eternal Venom",                privateID = 1290336,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "fractured",                    label = "Fractured",                    privateID = 1289092,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "coiling_ichor",                label = "Coiling Ichor",                privateID = 1290814,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "corrosive_spit",               label = "Corrosive Spit",               privateID = 1293979,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "caustic_deluge",               label = "Caustic Deluge",               privateID = 1289192,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "congealed_gore_1",             label = "Congealed Gore 1",             privateID = 1306925,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "congealed_gore_2",             label = "Congealed Gore 2",             privateID = 1292552,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tf_deadly_venom",              label = "Deadly Venom",                 privateID = 1297338,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "stir_the_depths",              label = "Stir the Depths",              privateID = 1292807,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "noxious_slick",                label = "Noxious Slick",                privateID = 1309471,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "vile_flood",                   label = "Vile Flood",                   privateID = 1294605,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Coiled Altar",
        bossKey = "the_bargained_crown",
        section = "|cffae3df5The Coiled Altar|r",
        journalInstanceID = 1320,
        journalEncounterID = 2883,        
        abilities = {
            { key = "twinfang_toxin",               label = "Twinfang Toxin",               privateID = 1283345,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Tank Debuff, expires into Twinfang Rupture
            { key = "axegrinder",                   label = "Axegrinder",                   privateID = 1285017,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot when in an axe
            { key = "dreadmarch",                   label = "Dreadmarch",                   privateID = 1285640,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal absorb, turns into adds.
            { key = "dreadmarch_alt",               label = "Dreadmarch Alt",               privateID = 1285647,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal absorb, turns into adds. Alt
            { key = "dreadmarch_confirmed",         label = "Dreadmarch (confirmed)",       privateID = 1297445,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- WCL-observed Dreadmarch
            { key = "unnerving_fixation",           label = "Unnerving Fixation",           privateID = 1285911,                soundH = nil,                               soundM = nil,                                               }, -- Fixate by dreadmarch adds
            { key = "shadowfang",                   label = "Shadowfang",                   privateID = 1286326,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},                              }, -- Axe Marks, 15 yard explode after 5s
            { key = "wail_of_terror",               label = "Wail of Terror",               privateID = 1286399,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Fear for 5s
            { key = "gloombomb",                    label = "Gloombomb",                    privateID = 1286901,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},           advanced = true    }, -- Bomb marks, 15 yard damage after 5s. Also Gravebound.
            { key = "defilement_of_the_crucible",   label = "Defilement of the Crucible",   privateID = 1298594,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal Absorb, auto attack to apply toxin
            { key = "blighted_toxin",               label = "Blighted Toxin",               privateID = 1287227,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Snake Statues spit venom. Dot-ish
            { key = "spirit_erasure",               label = "Spirit Erasure",               privateID = 1300665,                soundH = {"debuff","file:4s"},              soundM = {"debuff","file:4s"},           advanced = true    }, -- Soak, increasing on stacks, 4 sec dur
            { key = "soul_sever",                   label = "Soul Sever",                   privateID = 1307959,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "sever",                        label = "Sever",                        privateID = 1301690,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "gravebound",                   label = "Gravebound",                   privateID = 1286837,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "volatile_venom",               label = "Volatile Venom",               privateID = 1282419,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "venom_rupture",                label = "Venom Rupture",                privateID = 1299838,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "guillotined",                  label = "Guillotined",                  privateID = 1307425,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "venomfang",                    label = "Venomfang",                    privateID = 1306906,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "noxious_ground",               label = "Noxious Ground",               privateID = 1283290,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "suffocating_darkness",         label = "Suffocating Darkness",         privateID = 1286947,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "guillotine",                   label = "Guillotine",                   privateID = 1283485,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "corrupted_toxin",              label = "Corrupted Toxin",              privateID = 1298795,                soundH = nil,                               soundM = nil,                            advanced = true    },
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Ula'tek",
        bossKey = "ulatek",
        section = "|cffae3df5Ula'tek|r",
        journalInstanceID = 1320,
        journalEncounterID = 2895,
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
            { key = "serpents_bite_1",              label = "Serpent's Bite 1",             privateID = 1295840,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some bite
            { key = "serpents_bite_2",              label = "Serpent's Bite 2",             privateID = 1295844,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some bite 2
            { key = "toxic_wounds",                 label = "Toxic Wounds",                 privateID = 1296203,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Stacking dot            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Uncategorized",
        bossKey = "uncategorized",
        section = "|cffae3df5Uncategorized|r",
        abilities = {
            { key = "gnashing_extraction",          label = "Gnashing Extraction",          privateID = 1287551,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Pulling a fang 15 yards
            { key = "petrified",                    label = "Petrified",                    privateID = 1288891,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Viper Venom turn to stone, heal fully
            { key = "caustic_venom",                label = "Caustic Venom",                privateID = 1290036,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, if 5 stacks big 50yd boom
            { key = "fixate_12.1.0_1",              label = "Fixate",                       privateID = 1292782,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some fixate somewhere
            { key = "noxious_poison",               label = "Noxious Poison",               privateID = 1295701,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some poison puddle


            
            { key = "dunduns_strange_shape",        label = "Dundun's Strange Shape",       privateID = 1297815,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- dunno
            { key = "necrotic_anguish",             label = "Necrotic Anguish",             privateID = 1299467,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, heal absorb

            { key = "unstable_venom",               label = "Unstable Venom",               privateID = 1301478,                soundH = "spread",                          soundM = "spread",                       advanced = true    }, -- Dot, spread 14s
            { key = "corrosive_tempest",            label = "Corrosive Tempest",            privateID = 1305386,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dunno, dot and movement speed or something
            { key = "toxic_beam",                   label = "Toxic Beam",                   privateID = 1306856,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Beam, does damage when hit
            
        },
    },
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid[#CCS_Spells_Raid + 1] = e
end