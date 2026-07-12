-- data/m_temple_of_sethraliss.lua

CCS_Spells_Mplus_TempleOfSethraliss = {
    {
        raid    = "Temple of Sethraliss",
        boss    = "Adderis and Aspix",
        bossKey = "tos_adderis_aspix",
        section = "Adderis and Aspix",
        journalInstanceID = 1030,
        journalEncounterID = 2142,          
        abilities = {
            { key = "tos_gust",                     label = "Gust",                             privateID = 1288457,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_serrated_charge",          label = "Serrated Charge",                  privateID = 1291399,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_arrow_barrage",            label = "Arrow Barrage",                    privateID = 1308113,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Temple of Sethraliss",
        boss    = "Merektha",
        bossKey = "tos_merektha",
        section = "Merektha",
        journalInstanceID = 1030,
        journalEncounterID = 2143,         
        abilities = {
            { key = "tos_knot_of_snakes_target",    label = "A Knot of Snakes (target)",        privateID = 1290030,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 4s targeted
            { key = "tos_knot_of_snakes_stun",      label = "A Knot of Snakes (stun)",          privateID = 263958,                 soundH = nil,                               soundM = nil,                            advanced = true    }, -- stun after
            { key = "tos_burrowquake",              label = "Burrowquake",                      privateID = 1300227,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_lightning_bite",           label = "Lightning Bite",                   privateID = 1308838,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_serpentstorm",             label = "Serpentstorm",                     privateID = 1293048,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_thunder_spit_dot",         label = "Thunder Spit (dot)",               privateID = 1289588,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_thunder_spit_target",      label = "Thunder Spit (target)",            privateID = 1289109,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 3s targeted
            { key = "tos_burrow",                   label = "Burrow",                           privateID = 264206,                 soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Temple of Sethraliss",
        boss    = "Galvazzt",
        bossKey = "tos_galvazzt",
        section = "Galvazzt",
        journalInstanceID = 1030,
        journalEncounterID = 2144,         
        abilities = {
            { key = "tos_galvanized",               label = "Galvanized",                       privateID = 266923,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_induction_field",          label = "Induction Field",                  privateID = 1291815,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Temple of Sethraliss",
        boss    = "Avatar of Sethraliss",
        bossKey = "tos_avatar",
        section = "Avatar of Sethraliss",
        journalInstanceID = 1030,
        journalEncounterID = 2145,         
        abilities = {
            { key = "tos_corruption",               label = "Corruption",                       privateID = 1300877,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_fixate",                   label = "Fixate",                           privateID = 1300704,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_shadowlash",               label = "Shadowlash",                       privateID = 1300714,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_tainted_strike",           label = "Tainted Strike",                   privateID = 1303446,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_vile_charge",              label = "Vile Charge",                      privateID = 1302618,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_latent_hex",               label = "Latent Hex",                       privateID = 1302153,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_flame_shock",              label = "Flame Shock",                      privateID = 1302158,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_hex_muck",                 label = "Hex Muck",                         privateID = 1300684,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "fixate_tormentor",             label = "Fixate",                           privateID = 1300704,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Fixated by a faithless tormentor            
        },
    },

    {
        raid    = "Temple of Sethraliss",
        boss    = "Trash mob abilities",
        bossKey = "tos_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "tos_cytotoxin",                label = "Cytotoxin",                        privateID = 1308148,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_slither_strike",           label = "Slither Strike",                   privateID = 1295635,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_siphon_energy",            label = "Siphon Energy",                    privateID = 1303596,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_sunder_slam",              label = "Sunder Slam",                      privateID = 1291468,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_caustic_stomp",            label = "Caustic Stomp",                    privateID = 1303486,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_imbued_conduction",        label = "Imbued Conduction",                privateID = 1296052,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_venomous_slash",           label = "Venomous Slash",                   privateID = 1308546,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_lingering_storm",          label = "Lingering Storm",                  privateID = 1293133,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_polarized_field",          label = "Polarized Field",                  privateID = 273274,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_latent_hex_trash",         label = "Latent Hex (trash)",               privateID = 1300666,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_scouring_sand",            label = "Scouring Sand",                    privateID = 272655,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tos_poisoned_cheap_shot",      label = "Poisoned Cheap Shot",              privateID = 1308100,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },
}