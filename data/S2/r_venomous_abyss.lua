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
            { key = "hungering_pyre",               label = "Hungering Pyre",               privateID = 1306666,                soundH = {"soak","file:7,5s" },              soundM = {"soak","file:7,5s" } }, -- Big stack, clears adds. Share
            { key = "cremation",                    label = "Cremation",                    privateID = 1289875,                soundH = "spread",                          soundM = "spread" }, -- Aoe around people who stacked.
            { key = "essence_rend_dispel",          label = "Essence Rend",                 privateID = 1287434,                soundH = {"drop"},                          soundM = {"drop"} },
            { key = "essence_rend_target",          label = "Essence Rend (Target)",        privateID = 1287427,                soundH = {"targeted","file:5s"},            soundM = {"targeted","file:5s"}, },      
            { key = "slithering_flame",             label = "Slithering Flame",             privateID = 1294933,                soundH = "clear",                           soundM = "clear" }, -- Goes on whoever didn't stack.
            { key = "hollowed",                     label = "Hollowed",                     privateID = 1284109,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Dot, healing nerfed. On tank Stacks
            { key = "soulcoil_rite",                label = "Soulcoil Rite",                privateID = 1288772,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Dot, stacks when spirits are consumed
            { key = "corpse_blight",                label = "Corpse Blight",                privateID = 1307939,                soundH = nil,                               soundM = nil,                            advanced = true }, -- 20 second dot after amani die.
            { key = "ritual_burn",                  label = "Ritual Burn",                  privateID = 1297624,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Increased damage from soulcoil rite, 1m.
            { key = "residual_toll",                label = "Residual Toll",                privateID = 1298698,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Dot, gives them hollowed after 12s
            { key = "soulcoil_well",                label = "Soulcoil Well",                privateID = 1285623,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "latent_cultist",               label = "Latent Cultist",               privateID = 1288554,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "possession_barrage",           label = "Possession Barrage",           privateID = 1284103,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tether_of_awakening",          label = "Tether of Awakening",          privateID = 1289696,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss1",   },
            { key = "uncoiling",                    label = "Uncoiling",                    privateID = 1290003,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss1",   },

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
            { key = "unstable_miasma",          label = "Unstable Miasma",              privateID = 1288260,                soundH = {"file:miasma","file:8s" },               soundM = {"file:miasma","file:8s" } }, -- Upon expiration, damage split players 5 yards.
            { key = "clinging_murk",            label = "Clinging Murk",                privateID = 1288297,                soundH = {"drop","file:6s" },                soundM = {"drop","file:6s" } },
            { key = "helical_toxins",           label = "Helical Toxins",               privateID = 1284590,                soundH = "clear",                           soundM = "clear" }, -- Run into people, stack to exactly 4.
            { key = "mark_of_acid_debuff",      label = "Mark of Acid",                 privateID = 1284500,                soundH = "file:acid",                       soundM = "file:acid",                    advanced = true },
            { key = "mark_of_blood_debuff",     label = "Mark of Blood",                privateID = 1284506,                soundH = "file:blood",                      soundM = "file:blood",                   advanced = true },
            { key = "shifting_protovenom",      label = "Shifting Protovenom",          privateID = 1296880,                soundH = "file:venom",                           soundM = "file:venom",                              }, -- Hit other protovenoms, colliding - Protovenom Eruption
            { key = "blood_venom",              label = "Blood Venom",                  privateID = 1284210,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Puddle damage
            { key = "blighted_blood",           label = "Blighted Blood",               privateID = 1284471,                soundH = nil,                               soundM = nil,                            advanced = true }, -- 18s Magic Dot
            { key = "debilitating_miasma",      label = "Debilitating Miasma",          privateID = 1284477,                soundH = nil,                               soundM = nil,                            advanced = true }, -- 10s dot, movement decrease, movement reduces stacks.
            { key = "bloodvenom_injection",     label = "Bloodvenom Injection",         privateID = 1284491,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Stacking dot on target (tank)
            { key = "cultivated_burst",         label = "Cultivated Burst",             privateID = 1284947,                soundH = nil,                               soundM = nil,                            advanced = true }, -- Big dot if full duration of helical toxin.
            { key = "mark_of_acid_buff",        label = "Mark of Acid",                 privateID = 1284494,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss1",   },
            { key = "mark_of_blood_buff",       label = "Mark of Blood",                privateID = 1284503,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss2",   },
            { key = "vitriolic_stasis_g",       label = "Vitriolic Stasis",             privateID = 1284606,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss1",   },
            { key = "vitriolic_stasis_r",       label = "Vitriolic Stasis",             privateID = 1284588,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss2",   },
            { key = "contaminate",              label = "Contaminate",                  privateID = 1284257,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss3",   },
            
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
            { key = "mighty_thud",                  label = "Mighty Thud",                  privateID = 1296092,                soundH = "targeted",                        soundM = "targeted" },
            { key = "burning_flames",               label = "Burning Flames",               privateID = 1295928,                soundH = "file:fire",                       soundM = "file:fire" },
            { key = "piercing_frost",               label = "Piercing Frost",               privateID = 1295954,                soundH = "file:frost",                      soundM = "file:frost" },
            { key = "frostfire_volley_fire",        label = "Frostfire Volley (Fire)",      privateID = 1295886,                soundH = "file:fire_volley",                soundM = "file:fire_volley" },
            { key = "frostfire_volley_frost",       label = "Frostfire Volley (Frost)",     privateID = 1295935,                soundH = "file:frost_volley",               soundM = "file:frost_volley" },
            { key = "explosive_surprise",           label = "Explosive Surprise",           privateID = 1297625,                soundH = {"file:bomb","file10s"},           soundM = {"file:bomb","file:10s"},                             },            
            { key = "fire_patch",                   label = "Fire Patch",                   privateID = 1297649,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "frost_patch",                  label = "Frost Patch",                  privateID = 1297648,                soundH = nil,                               soundM = nil,                            advanced = true },            
            { key = "steady_strikes",               label = "Steady Strikes",               privateID = 1291929,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "splinters",                    label = "Splinters",                    privateID = 1308853,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "shredding_shards",             label = "Shredding Shards",             privateID = 1295858,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "shell_spin",                   label = "Shell Spin",                   privateID = 1291918,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "bounce",                       label = "Bounce",                       privateID = 1299854,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "blast_wave",                   label = "Blast Wave",                   privateID = 1305844,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "icebound_flames",              label = "Icebound Flames",              privateID = 1286922,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "spooky_mask",                  label = "Spooky Mask",                  privateID = 1310032,                soundH = nil,                               soundM = nil,                            advanced = true,    },
            { key = "united_defense",               label = "United Defense",               privateID = 1297646,                soundH = nil,                               soundM = nil,                            advanced = true, unit="boss3",    },

            -- likely cast IDs, so verify against logs before enabling.
            --{ key = "fungal_burst",                 label = "Fungal Burst",                 privateID = 1292292,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Huge hit plus a 10s dot from a mushroom." },
            --{ key = "concussive_blast",             label = "Concussive Blast",             privateID = 1296247,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Knockback plus a 12s fire dot from Gebbo's bomb." },
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
            --{ key = "plague_froth_incubate",        label = "Plague Froth (incubate)",      privateID = 1281910,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 2s incubate
            --{ key = "plague_froth_dot",             label = "Plague Froth (dot)",           privateID = 1281908,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 6s dot
            --{ key = "plague_froth_untooltipped",    label = "Plague Froth (untooltipped)",  privateID = 1282078,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- No tooltip
            { key = "plague_froth_mythic",          label = "Plague Froth",                 privateID = {1281908, 1281913 },     soundH = {"spread","file:6s" },              soundM = {"spread","file:6s" } }, -- Mythic?
            { key = "exploding_infection",          label = "Exploding Infection",          privateID = 1295173,                soundH = {"file:exploding","file:10s" },     soundM = {"file:exploding","file:10s" } },
            { key = "siphoning_infection",          label = "Siphoning Infection",          privateID = 1295224,                soundH = "file:siphon",                     soundM = "file:siphon" },
            { key = "being_siphoned",               label = "Being Siphoned",               privateID = 1295380,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "stygian_infection",            label = "Stygian Infection",            privateID = 1294994,                soundH = "file:heal",                       soundM = "drop",  soundRemove = "file:clear",            },
            { key = "clotting_blood",               label = "Clotting Blood",               privateID = 1302517,                soundH = "absorb",                          soundM = "absorb",                       advanced = true },
            { key = "congealing_bolt",              label = "Congealing Bolt",              privateID = 1305833,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "dripping_fangs",               label = "Dripping Fangs",               privateID = 1280934,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "caustic_surge",                label = "Caustic Surge",                privateID = 1285979,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "virulent_fumes",               label = "Virulent Fumes",               privateID = 1291461,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "adaptive_infection",           label = "Adaptive Infection",           privateID = 1282117,                soundH = nil,                               soundM = nil,                            advanced = true },
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
            { key = "venomous_surge",               label = "Venomous Surge",               privateID = 1305963,                soundH = {"file:surge","file:10s" },         soundM = {"file:surge","file:10s" } },
            { key = "serpents_fury",                label = "Serpent's Fury",               privateID = 1305621,                soundH = "file:serpents_fury",              soundM = "file:serpents_fury" },
            { key = "virulence_1",                  label = "Virulence (Cardinal Directions)", privateID = 1297707,                soundH = {"file:spread","file:5s" },         soundM = {"file:spread","file:5s" }, },
            { key = "virulence_2",                  label = "Virulence (45 degree)",        privateID = 1299899,                soundH = {"file:spread","file:5s" },         soundM = {"file:spread","file:5s" } },
            { key = "raging_crosswinds_north",      label = "Raging Crosswinds (North)",    privateID = 1285425,                soundH = {"file:winds","file:8s" },          soundM = {"file:winds","file:8s"  }, suggest={"file:north","file:east","file:south","file:west"}, },
            { key = "raging_crosswinds_east",       label = "Raging Crosswinds (East)",     privateID = 1297096,                soundH = {"file:winds","file:8s" },          soundM = {"file:winds","file:8s" }, suggest={"file:north","file:east","file:south","file:west"}, },
            { key = "raging_crosswinds_south",      label = "Raging Crosswinds (South)",    privateID = 1285453,                soundH = {"file:winds","file:8s" },          soundM = {"file:winds","file:8s" }, suggest={"file:north","file:east","file:south","file:west"}, },
            { key = "raging_crosswinds_west",       label = "Raging Crosswinds (West)",     privateID = 1297111,                soundH = {"file:winds","file:8s" },          soundM = {"file:winds","file:8s" }, suggest={"file:north","file:east","file:south","file:west"}, },
            { key = "turbulent_gusts",              label = "Turbulent Gusts",              privateID = 1285447,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "corroding_venom",              label = "Corroding Venom",              privateID = 1282873,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "mutilated_gash",               label = "Mutilated Gash",               privateID = 1277051,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tva_ravage",                   label = "Ravage",                       privateID = 1277105,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tempest",                      label = "Tempest",                      privateID = 1287083,                soundH = nil,                               soundM = nil,                            advanced = true    },       
            { key = "caustic_residue",              label = "Caustic Residue",              privateID = 1296667,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "viscous_cyst",                 label = "Viscous Cyst",                 privateID = 1287205,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tva_deadly_venom",             label = "Deadly Venom",                 privateID = 1297338,                soundH = nil,                               soundM = nil,                            advanced = true },

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
            { key = "coiling_ichor",                label = "Coiling Ichor",                privateID = 1290814,                soundH = {"file:drop","file:12s" },          soundM = {"file:drop","file:12s" } },
            { key = "corrosive_spit",               label = "Corrosive Spit",               privateID = 1293979,                soundH = {"file:line","file:5s" },           soundM = {"file:line","file:5s" } },
            { key = "eternal_venom",                label = "Eternal Venom",                privateID = 1290336,                soundH = "file:venom",                      soundM = "file:venom",                   advanced = true },
            { key = "tva_tainted_blood",            label = "Tainted Blood",                privateID = 1310102,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "congealed_gore_1",             label = "Congealed Gore (Intermission)",  privateID = 1306925,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "congealed_gore_2",             label = "Congealed Gore (Coiling Ichor)", privateID = 1292552,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "stir_the_depths",              label = "Stir the Depths",              privateID = 1292807,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "noxious_slick",                label = "Noxious Slick",                privateID = 1309471,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "vile_flood",                   label = "Vile Flood",                   privateID = 1294605,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "caustic_deluge",               label = "Caustic Deluge",               privateID = 1289192,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "tva_blood_torrent",            label = "Blood Torrent",                privateID = 1303230,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "fractured",                    label = "Fractured",                    privateID = 1289092,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "tva_visceral_burst",           label = "Visceral Burst",               privateID = 1308386,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "tf_deadly_venom",              label = "Deadly Venom",                 privateID = 1297338,                soundH = nil,                               soundM = nil,                            advanced = true },
      
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
            { key = "dreadmarch",                   label = "Dreadmarch",                   privateID = {1285640,1285647,1297445 }, soundH = "file:dreadmarch",              soundM = "file:dreadmarch" },
            { key = "unnerving_fixation",           label = "Unnerving Fixation",           privateID = 1285911,                soundH = "fixate",                          soundM = "fixate" },
            { key = "gravebound",                   label = "Gravebound",                   privateID = 1286837,                soundH = "file:gravebound",                 soundM = "file:gravebound" },
            { key = "shadowfang",                   label = "Shadowfang",                   privateID = 1286326,                soundH = {"spread","file:5s" },              soundM = {"spread","file:5s" },                              }, -- Axe Marks, 15 yard explode after 5s
            { key = "gloombomb",                    label = "Gloombomb",                    privateID = 1286901,                soundH = {"file:bomb","file:5s" },              soundM = {"file:bomb","file:5s" },                              }, -- Bomb marks, 15 yard damage after 5s. Also Gravebound.
            { key = "volatile_venom",               label = "Volatile Venom",               privateID = 1282419,                soundH = {"drop","file:5s" },               soundM = {"drop","file:5s" } },
            { key = "mutagenic_venom",              label = "Mutagenic Venom",              privateID = 1310498,                soundH = {"spread","file:5s" },              soundM = {"spread","file:5s" } },
            { key = "guillotine",                   label = "Guillotine",                   privateID = 1283485,                soundH = {"stack","file:5s"},               soundM = nil,                                },
            { key = "guillotined",                  label = "Guillotined",                  privateID = 1307425,                soundH = nil,                               soundM = nil,                            advanced = true    },            
            { key = "noxious_ground",               label = "Noxious Ground",               privateID = 1283290,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "venomfang",                    label = "Venomfang",                    privateID = 1306906,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "venom_rupture",                label = "Venom Rupture",                privateID = 1299838,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "sever",                        label = "Sever",                        privateID = 1301690,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "axegrinder",                   label = "Axegrinder",                   privateID = 1285017,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot when in an axe
            

            { key = "twinfang_toxin",               label = "Twinfang Toxin",               privateID = 1283345,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Tank Debuff, expires into Twinfang Rupture
            { key = "wail_of_terror",               label = "Wail of Terror",               privateID = 1286399,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Fear for 5s
            { key = "defilement_of_tca",            label = "Defilement of the Coiled Altar",   privateID = 1298594,            soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal Absorb, auto attack to apply toxin
            { key = "blighted_toxin",               label = "Blighted Toxin",               privateID = 1287227,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "soul_sever",                   label = "Soul Sever",                   privateID = 1307959,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "suffocating_darkness",         label = "Suffocating Darkness",         privateID = 1286947,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "spirit_erasure",               label = "Spirit Erasure",               privateID = 1300665,                soundH = {"debuff","file:4s" },              soundM = {"debuff","file:4s" },           advanced = true    }, -- Soak, increasing on stacks, 4 sec dur                        
            { key = "corrupted_toxin",              label = "Corrupted Toxin",              privateID = 1298795,                soundH = nil,                               soundM = nil,                            advanced = true    },
            
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
            { key = "surging_fang",                 label = "Surging Fang",                 privateID = {1288879,1295876,1293146 }, soundH = "file:fang",                    soundM = "file:fang" },
            { key = "volatile_purge",               label = "Volatile Purge",               privateID = 1306086,                soundH = {"file:purge","file:6s" },          soundM = {"file:purge","file:6s" } },
            { key = "doomscale_pheromones",         label = "Doomscale Pheromones",         privateID = 1300265,                soundH = "file:pheromones",                 soundM = "file:pheromones" },

            -- Marks (short fuse, then something lands on you)
            { key = "serpents_bite_mark",           label = "Serpent's Bite (mark)",        privateID = 1293046,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "serpents_bite",                label = "Serpent's Bite",               privateID = 1295905,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "serpents_bite_impact",         label = "Serpent's Bite (impact)",      privateID = 1295838,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "petrifying_sting_mark",        label = "Petrifying Sting (mark)",      privateID = 1305163,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "petrifying_sting",             label = "Petrifying Sting",             privateID = 1303414,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "grasping_fangs_mark",          label = "Grasping Fangs (mark)",        privateID = 1301118,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "grasping_fangs",               label = "Grasping Fangs",               privateID = 1311611,                soundH = nil,                               soundM = nil,                            advanced = true },

            -- Eggs
            { key = "malignant_shell",              label = "Malignant Shell",              privateID = 1295360,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "noxious_shell",                label = "Noxious Shell",                privateID = 1307612,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "doomscale_shell",              label = "Doomscale Shell",              privateID = 1300312,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "greasy_hatchling",             label = "Greasy Hatchling",             privateID = 1306388,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "butter_fingers",               label = "Butter Fingers",               privateID = 1306393,                soundH = nil,                               soundM = nil,                            advanced = true },

            -- Dots and tank stacks
            { key = "putrid_membrane",              label = "Putrid Membrane",              privateID = {1301268,1308275 },      soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "mothers_wrath",                label = "Mother's Wrath",               privateID = 1298367,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "stone_venom",                  label = "Stone Venom",                  privateID = 1298417,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "mephitic_thrash",              label = "Mephitic Thrash",              privateID = 1296301,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "acidic_burst",                 label = "Acidic Burst",                 privateID = 1301800,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "toxic_wounds",                 label = "Toxic Wounds",                 privateID = 1296203,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "poisonous_bite",               label = "Poisonous Bite",               privateID = 1287036,                soundH = nil,                               soundM = nil,                            advanced = true },
            { key = "calcified_corpse",             label = "Calcified Corpse",             privateID = 1306119,                soundH = nil,                               soundM = nil,                            advanced = true },
        },
    },
    --{
        --raid    = "The Venomous Abyss",
        --boss    = "Uncategorized",
        --bossKey = "uncategorized",
        --section = "|cff7fbf3fUncategorized|r",
        --abilities = {
            --{ key = "gnashing_extraction",          label = "Gnashing Extraction",          privateID = 1287551,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Pulling a fang 15 yards
            --{ key = "petrified",                    label = "Petrified",                    privateID = 1288891,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Viper Venom turn to stone, heal fully
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