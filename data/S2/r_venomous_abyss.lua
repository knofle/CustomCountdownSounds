-- data/r_venomous_abyss.lua
-- The Venomous Abyss (12.1.0 raid).
-- soundH = Heroic, soundM = Mythic, soundStack = Aura Stack, soundRemove = Aura Remove


local entries = {
    {
        raid    = "The Venomous Abyss",
        boss    = "Nek'zali the Soulcoiler",
        bossKey = "nekzali_the_soulcoiler",
        section = "|cff7fbf3fNek'zali the Soulcoiler|r",
        journalInstanceID = 1320,
        journalEncounterID = 2888,
        abilities = {
            { key = "hungering_pyre",               label = "Hungering Pyre",               privateID = 1306666,                soundH = {"soak","file:7,5s" },             soundM = {"soak","file:7,5s" }                                          }, -- Aura is hidden
            { key = "essence_rend_target",          label = "Essence Rend (Target)",        privateID = 1287427,                soundH = {"targeted","file:5s"},            soundM = {"targeted","file:5s"},                                        }, -- ok     
            { key = "essence_rend_dispel",          label = "Essence Rend",                 privateID = 1287434,                soundH = {"drop"},                          soundM = {"drop"}                                                       }, -- ok          
            { key = "slithering_flame",             label = "Slithering Flame",             privateID = 1294933,                soundH = "clear",                           soundM = "clear"                                                        }, -- ok
            { key = "cremation",                    label = "Cremation",                    privateID = 1289875,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok               }
            { key = "hollowed",                     label = "Hollowed",                     privateID = 1284109,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "soulcoil_rite",                label = "Soulcoil Rite",                privateID = 1288772,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "corpse_blight",                label = "Corpse Blight",                privateID = 1307939,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "ritual_burn",                  label = "Ritual Burn",                  privateID = 1297624,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "residual_toll",                label = "Residual Toll",                privateID = 1298698,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "soulcoil_well",                label = "Soulcoil Well",                privateID = 1285623,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "latent_cultist",               label = "Latent Cultist",               privateID = 1288554,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "possession_barrage",           label = "Possession Barrage",           privateID = 1284103,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "tether_of_awakening",          label = "Tether of Awakening",          privateID = 1289696,                soundH = nil,                               soundM = nil,                       advanced = true, unit="boss1",      }, -- ok
            { key = "uncoiling",                    label = "Uncoiling",                    privateID = 1290003,                soundH = nil,                               soundM = nil,                       advanced = true, unit="boss1",      }, -- ok

        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Entombed Sentinels",
        bossKey = "entombed_sentinels",
        section = "|cff7fbf3fEntombed Sentinels|r",
        journalInstanceID = 1320,
        journalEncounterID = 2874,
        abilities = {
            { key = "unstable_miasma",          label = "Unstable Miasma",              privateID = 1288260,                    soundH = {"file:miasma","file:8s" },        soundM = {"file:miasma","file:8s" }                                     }, -- ok
            { key = "clinging_murk",            label = "Clinging Murk",                privateID = 1288297,                    soundH = {"drop","file:6s" },               soundM = {"drop","file:6s" }                                            }, -- ok
            { key = "helical_toxins",           label = "Helical Toxins",               privateID = 1284590,                    soundH = "file:match",                      soundM = "file:match"                                                        }, -- ok
            { key = "mark_of_acid_debuff",      label = "Mark of Acid",                 privateID = 1284500,                    soundH = "file:acid",                       soundM = "file:acid",               advanced = true                     }, -- ok
            { key = "mark_of_blood_debuff",     label = "Mark of Blood",                privateID = 1284506,                    soundH = "file:blood",                      soundM = "file:blood",              advanced = true                     }, -- ok
            { key = "shifting_protovenom",      label = "Shifting Protovenom",          privateID = 1296880,                    soundH = "file:venom",                      soundM = "file:venom",                                                  }, -- ok
            { key = "blood_venom",              label = "Blood Venom",                  privateID = 1284210,                    soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "blighted_blood",           label = "Blighted Blood",               privateID = 1284471,                    soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "debilitating_miasma",      label = "Debilitating Miasma",          privateID = 1284477,                    soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "bloodvenom_injection",     label = "Bloodvenom Injection",         privateID = 1284491,                    soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "cultivated_burst",         label = "Cultivated Burst",             privateID = 1284947,                    soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "mark_of_acid_buff",        label = "Mark of Acid",                 privateID = 1284494,                    soundH = nil,                               soundM = nil,                       advanced = true, unit="boss1",      }, -- ok
            { key = "mark_of_blood_buff",       label = "Mark of Blood",                privateID = 1284503,                    soundH = nil,                               soundM = nil,                       advanced = true, unit="boss2",      }, -- ok
            { key = "vitriolic_stasis_g",       label = "Vitriolic Stasis",             privateID = 1284606,                    soundH = nil,                               soundM = nil,                       advanced = true, unit="boss1",      }, -- ok
            { key = "vitriolic_stasis_r",       label = "Vitriolic Stasis",             privateID = 1284588,                    soundH = nil,                               soundM = nil,                       advanced = true, unit="boss2",      }, -- ok
            { key = "contaminate",              label = "Contaminate",                  privateID = 1284257,                    soundH = nil,                               soundM = nil,                       advanced = true, unit="boss3",      }, -- ok
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Lost Explorers",
        bossKey = "the_lost_explorers",
        section = "|cff7fbf3fThe Lost Explorers|r",
        journalInstanceID = 1320,
        journalEncounterID = 2894,        
        abilities = {
            { key = "mighty_thud",                  label = "Mighty Thud",                  privateID = 1296092,                soundH = "targeted",                        soundM = "targeted"                                                     }, -- ok
            { key = "blink_nova",                   label = "Blink Nova",                   privateID = 1296025,                soundH = {"file:blink","file:9s"},          soundM = {"file:blink","file:9s"},                                      }, -- ok, does not show on logs            
            { key = "frostfire_volley_fire",        label = "Frostfire Volley (Fire)",      privateID = 1295886,                soundH = {"file:fire_volley","file:7s"},    soundM = {"file:fire_volley","file:7s"},    suggest = {"file:fire"},    }, -- ok, tooltip says 8s, but might be 7s based on testing?
            { key = "frostfire_volley_frost",       label = "Frostfire Volley (Frost)",     privateID = 1295935,                soundH = {"file:frost_volley","file:7s"},   soundM = {"file:frost_volley","file:7s"},   suggest = {"file:frost"},   }, -- ok, tooltip says 8s, but might be 7s based on testing?          
            { key = "burning_flames",               label = "Burning Flames",               privateID = 1295928,                soundH = nil,                               soundM = nil,                               soundRemove = "file:clear", }, -- ok
            { key = "piercing_frost",               label = "Piercing Frost",               privateID = 1295954,                soundH = nil,                               soundM = nil,                               soundRemove = "file:clear", }, -- ok
            { key = "explosive_surprise",           label = "Explosive Surprise",           privateID = 1297625,                soundH = {"file:bomb","file:10s"},          soundM = {"file:bomb","file:10s"},                                      }, -- ok            
            { key = "fire_patch",                   label = "Fire Patch",                   privateID = 1297649,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "frost_patch",                  label = "Frost Patch",                  privateID = 1297648,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok            
            { key = "steady_strikes",               label = "Steady Strikes",               privateID = 1291929,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "splinters",                    label = "Splinters",                    privateID = 1308853,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "shredding_shards",             label = "Shredding Shards",             privateID = 1295858,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "shell_spin",                   label = "Shell Spin",                   privateID = 1291918,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "bounce",                       label = "Bounce",                       privateID = 1299854,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "blast_wave",                   label = "Blast Wave",                   privateID = 1305844,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "icebound_flames",              label = "Icebound Flames",              privateID = 1286922,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "spooky_mask",                  label = "Spooky Mask",                  privateID = 1310032,                soundH = nil,                               soundM = nil,                       advanced = true,                    }, -- ok
            { key = "fungal_burst",                 label = "Fungal Burst",                 privateID = 1292292,                soundH = nil,                               soundM = nil,                       advanced = true,                    }, -- ok
            { key = "united_defense",               label = "United Defense",               privateID = 1297646,                soundH = nil,                               soundM = nil,                       advanced = true, unit="boss3",      }, -- ok
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Vashnik the Malignant",
        bossKey = "vashnik_the_malignant",
        section = "|cff7fbf3fVashnik the Malignant|r",
        journalInstanceID = 1320,
        journalEncounterID = 2882,        
        abilities = {
            --{ key = "plague_froth_incubate",        label = "Plague Froth (Incubate)",      privateID = 1281910,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- 2s incubate, starts at the same time as 1281913
            --{ key = "plague_froth_dot",             label = "Plague Froth (Dot)",           privateID = 1281908,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- 6s dot, 1281913 is used instead?
            { key = "plague_froth_mythic",          label = "Plague Froth",                 privateID = {H=1281908, M=1281913}, soundH = {"spread","file:6s" },             soundM = {"spread","file:6s" }                                          }, -- ok
            { key = "exploding_infection",          label = "Exploding Infection",          privateID = 1295173,                soundH = {"file:exploding" },               soundM = {"file:exploding" }                                            }, -- ok
            { key = "siphoning_infection",          label = "Siphoning Infection",          privateID = 1295224,                soundH = "file:siphon",                     soundM = "file:siphon"                                                  }, -- ok
            { key = "being_siphoned",               label = "Being Siphoned",               privateID = 1295380,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "stygian_infection",            label = "Stygian Infection",            privateID = 1294994,                soundH = "file:heal",                       soundM = "drop",                            soundRemove = "file:clear", }, -- ok
            { key = "clotting_blood",               label = "Clotting Blood",               privateID = 1302517,                soundH = "absorb",                          soundM = "absorb",                  advanced = true                     }, -- ok
            { key = "congealing_bolt",              label = "Congealing Bolt",              privateID = 1305833,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "dripping_fangs",               label = "Dripping Fangs",               privateID = 1280934,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "caustic_surge",                label = "Caustic Surge",                privateID = 1285979,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "virulent_fumes",               label = "Virulent Fumes",               privateID = 1291461,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "adaptive_infection",           label = "Adaptive Infection",           privateID = 1282117,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Sszorak",
        bossKey = "sszorak",
        section = "|cff7fbf3fSszorak|r",
        journalInstanceID = 1320,
        journalEncounterID = 2871,        
        abilities = {
            { key = "venomous_surge",               label = "Venomous Surge",               privateID = 1305963,                soundH = {"file:surge","file:10s" },        soundM = {"file:surge","file:10s"}                                      }, -- ok
            { key = "serpents_fury",                label = "Serpent's Fury",               privateID = 1305621,                soundH = "file:serpents_fury",              soundM = "file:serpents_fury"                                           }, -- ok
            { key = "virulence_1",                  label = "Virulence (Cardinal Directions)", privateID = 1297707,             soundH = {"file:spread","file:5s" },        soundM = {"file:spread","file:5s"},                                     }, -- ok
            { key = "virulence_2",                  label = "Virulence (45 degree)",        privateID = 1299899,                soundH = {"file:spread","file:5s" },        soundM = {"file:spread","file:5s"}                                      }, -- ok
            { key = "raging_crosswinds_north",      label = "Raging Crosswinds (North)",    privateID = 1285425,                soundH = {"file:winds","file:8s" },         soundM = {"file:winds","file:8s" }, suggest={"file:north","file:east","file:south","file:west"}, }, -- ok
            { key = "raging_crosswinds_east",       label = "Raging Crosswinds (East)",     privateID = 1297096,                soundH = {"file:winds","file:8s" },         soundM = {"file:winds","file:8s" }, suggest={"file:north","file:east","file:south","file:west"}, }, -- ok
            { key = "raging_crosswinds_south",      label = "Raging Crosswinds (South)",    privateID = 1285453,                soundH = {"file:winds","file:8s" },         soundM = {"file:winds","file:8s" }, suggest={"file:north","file:east","file:south","file:west"}, }, -- ok
            { key = "raging_crosswinds_west",       label = "Raging Crosswinds (West)",     privateID = 1297111,                soundH = {"file:winds","file:8s" },         soundM = {"file:winds","file:8s" }, suggest={"file:north","file:east","file:south","file:west"}, }, -- ok
            { key = "turbulent_gusts",              label = "Turbulent Gusts",              privateID = 1285447,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "corroding_venom",              label = "Corroding Venom",              privateID = 1282873,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "mutilated_gash",               label = "Mutilated Gash",               privateID = 1277051,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "tva_ravage",                   label = "Ravage",                       privateID = 1277105,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "tempest",                      label = "Tempest",                      privateID = 1287083,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok       
            { key = "caustic_residue",              label = "Caustic Residue",              privateID = 1296667,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "viscous_cyst",                 label = "Viscous Cyst",                 privateID = 1287205,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "va_dig_in",                    label = "Dig In",                       privateID = 1286033,                soundH = nil,                               soundM = nil,                       advanced = true, unit="boss1",      }, -- unsure

        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Twin Fangs",
        bossKey = "the_twin_fangs",
        section = "|cff7fbf3fThe Twin Fangs|r",
        journalInstanceID = 1320,
        journalEncounterID = 2887,        
        abilities = {
            { key = "coiling_ichor",                label = "Coiling Ichor",                privateID = 1290814,                soundH = {"file:drop","file:12s" },         soundM = {"file:drop","file:12s" } },
            { key = "corrosive_spit",               label = "Corrosive Spit",               privateID = 1293979,                soundH = {"file:targeted"},                 soundM = {"file:targeted"} },
            { key = "eternal_venom",                label = "Eternal Venom",                privateID = 1290336,                soundH = "file:venom",                      soundM = "file:venom",              advanced = true                     }, -- ok
            { key = "tva_tainted_blood",            label = "Tainted Blood",                privateID = 1310102,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "congealed_gore_1",             label = "Congealed Gore (Intermission)",  privateID = 1306925,              soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "congealed_gore_2",             label = "Congealed Gore (Coiling Ichor)", privateID = 1292552,              soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "stir_the_depths",              label = "Stir the Depths",              privateID = 1292807,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "noxious_slick",                label = "Noxious Slick",                privateID = 1309471,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "vile_flood",                   label = "Vile Flood",                   privateID = 1294605,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "caustic_deluge",               label = "Caustic Deluge",               privateID = 1289192,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "tva_blood_torrent",            label = "Blood Torrent",                privateID = 1303230,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "fractured",                    label = "Fractured",                    privateID = 1289092,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "tva_visceral_burst",           label = "Visceral Burst",               privateID = 1308386,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok      
            { key = "tva_feasted",                  label = "Feasted",                      privateID = 1310096,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok      

        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Coiled Altar",
        bossKey = "the_bargained_crown",
        section = "|cff7fbf3fThe Coiled Altar|r",
        journalInstanceID = 1320,
        journalEncounterID = 2883,        
        abilities = {
            { key = "dreadmarch",                   label = "Dreadmarch",                   privateID = 1297445,                soundH = "file:dreadmarch",                 soundM = "file:dreadmarch"                                              }, -- ok
            { key = "unnerving_fixation",           label = "Unnerving Fixation",           privateID = 1285911,                soundH = "fixate",                          soundM = "fixate"                                                       }, -- ok
            { key = "gloombomb",                    label = "Gloombomb",                    privateID = 1286901,                soundH = {"file:bomb","file:5s" },          soundM = {"file:bomb","file:5s" },                                      }, -- ok            
            { key = "gravebound",                   label = "Gravebound",                   privateID = 1286837,                soundH = "file:gravebound",                 soundM = "file:gravebound"                                              }, -- ok
            { key = "shadowfang",                   label = "Shadowfang",                   privateID = 1286326,                soundH = {"spread","file:5s" },             soundM = {"spread","file:5s" },                                         }, -- ok
            { key = "volatile_venom",               label = "Volatile Venom",               privateID = 1282419,                soundH = {"drop","file:5s" },               soundM = {"drop","file:5s" }, soundRemove="file:pop"                    }, -- ok
            { key = "mutagenic_venom",              label = "Mutagenic Venom",              privateID = 1310498,                soundH = {"spread","file:5s" },             soundM = {"spread","file:5s" }, soundRemove="file:pop"                  }, -- ok
            { key = "guillotine",                   label = "Guillotine",                   privateID = 1283485,                soundH = {"stack","file:5s"},               soundM = {"stack","file:5s"},                                           }, -- ok
            { key = "guillotined",                  label = "Guillotined",                  privateID = 1307425,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok            
            { key = "noxious_ground",               label = "Noxious Ground",               privateID = 1283290,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "venomfang",                    label = "Venomfang",                    privateID = 1306906,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "venom_rupture",                label = "Venom Rupture",                privateID = 1299838,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "sever",                        label = "Sever",                        privateID = 1301690,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "axegrinder",                   label = "Axegrinder",                   privateID = 1285017,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "twinfang_toxin",               label = "Twinfang Toxin",               privateID = 1283345,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "wail_of_terror",               label = "Wail of Terror",               privateID = 1286399,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "defilement_of_tca",            label = "Defilement of the Coiled Altar",   privateID = 1298594,            soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "blighted_toxin",               label = "Blighted Toxin",               privateID = 1287227,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "soul_sever",                   label = "Soul Sever",                   privateID = 1307959,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "suffocating_darkness",         label = "Suffocating Darkness",         privateID = 1286947,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "spirit_erasure",               label = "Spirit Erasure",               privateID = 1300665,                soundH = {"debuff","file:4s" },             soundM = {"debuff","file:4s" },     advanced = true                     }, -- ok                 
            { key = "corrupted_toxin",              label = "Corrupted Toxin",              privateID = 1298795,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Ula'tek",
        bossKey = "ulatek",
        section = "|cff7fbf3fUla'tek|r",
        journalInstanceID = 1320,
        journalEncounterID = 2895,
        abilities = {
            -- Default-on: the three things a player has to act on.
            { key = "serpents_bite_1",              label = "Serpent's Bite (Debuff)",      privateID = 1288879,                soundH = "file:fang",                       soundM = "file:fang",               advanced = true                     }, -- ok
            { key = "gnashing_extraction",          label = "Gnashing Extraction",          privateID = 1287551,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok   
            { key = "volatile_purge",               label = "Volatile Purge",               privateID = {1306086, 1312967},     soundH = {"file:purge","file:6s" },         soundM = {"file:purge","file:6s" }, advanced = true                     }, -- ok
            { key = "doomscale_pheromones",         label = "Doomscale Pheromones",         privateID = 1300265,                soundH = "file:pheromones",                 soundM = "file:pheromones",         advanced = true                     }, -- ok

            -- Marks (short fuse, then something lands on you)
            { key = "serpents_bite_target",         label = "Serpent's Bite (Target)",      privateID = 1293046,                soundH = {"targeted","file:5s"},            soundM = {"targeted","file:5s"},    advanced = true                     }, -- ok
            { key = "petrifying_sting_mark",        label = "Petrifying Sting (Target)",    privateID = 1305163,                soundH = {"targeted","file:5s"},            soundM = {"targeted","file:5s"},    advanced = true                     }, -- ok
            { key = "petrifying_sting",             label = "Petrifying Sting (Debuff)",    privateID = 1303414,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "grasping_fangs_mark",          label = "Grasping Fangs (Target)",      privateID = 1301118,                soundH = {"targeted","file:8s"},            soundM = {"targeted","file:8s"},    advanced = true                     }, -- ok
            { key = "grasping_fangs",               label = "Grasping Fangs",               privateID = 1311611,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok

            -- Eggs
            { key = "malignant_shell",              label = "Malignant Shell",              privateID = 1295360,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "noxious_shell",                label = "Noxious Shell",                privateID = 1307612,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "doomscale_shell",              label = "Doomscale Shell",              privateID = 1300312,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "greasy_hatchling",             label = "Greasy Hatchling",             privateID = 1306388,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "butter_fingers",               label = "Butter Fingers",               privateID = 1306393,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok

            -- Dots and tank stacks
            { key = "blight_vein_player",           label = "Blight Vein (Player)",         privateID = 1311600,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "blight_vein_raid",             label = "Blight Vein (Raid)",           privateID = 1311609,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok

            { key = "putrid_membrane",              label = "Putrid Membrane",              privateID = 1301268,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "mothers_wrath",                label = "Mother's Wrath",               privateID = 1298367,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "stone_venom",                  label = "Stone Venom",                  privateID = 1298417,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "mephitic_thrash",              label = "Mephitic Thrash",              privateID = 1296301,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "acidic_burst",                 label = "Acidic Burst",                 privateID = 1301800,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "toxic_wounds",                 label = "Toxic Wounds",                 privateID = 1296203,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "poisonous_bite",               label = "Poisonous Bite",               privateID = 1287036,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "calcified_corpse",             label = "Calcified Corpse",             privateID = 1306119,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok
            { key = "petrified",                    label = "Petrified",                    privateID = 1288891,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- ok 

        },
    },
    --{
        --raid    = "The Venomous Abyss",
        --boss    = "Uncategorized",
        --bossKey = "uncategorized",
        --section = "|cff7fbf3fUncategorized|r",
        --abilities = {
            --{ key = "caustic_venom",                label = "Caustic Venom",                privateID = 1290036,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, if 5 stacks big 50yd boom
            --{ key = "fixate_12.1.0_1",              label = "Fixate",                       privateID = 1292782,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some fixate somewhere
            --{ key = "noxious_poison",               label = "Noxious Poison",               privateID = 1295701,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some poison puddle


            
            --{ key = "dunduns_strange_shape",        label = "Dundun's Strange Shape",       privateID = 1297815,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- dunno
            --{ key = "necrotic_anguish",             label = "Necrotic Anguish",             privateID = 1299467,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, heal absorb

            --{ key = "unstable_venom",               label = "Unstable Venom",               privateID = 1301478,                soundH = "spread",                          soundM = "spread",                       advanced = true    }, -- Dot, spread 14s
            --{ key = "corrosive_tempest",            label = "Corrosive Tempest",            privateID = 1305386,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dunno, dot and movement speed or something
            --{ key = "toxic_beam",                   label = "Toxic Beam",                   privateID = 1306856,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Beam, does damage when hit
            
        -- },
    -- },
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid_S2[#CCS_Spells_Raid_S2 + 1] = e
end