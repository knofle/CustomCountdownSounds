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
            { key = "tos_gust",                     label = "Gust",                             privateID = 1288457,                soundM = nil,                               advanced = true, desc = "Aspix blasts a target with wind." },
            { key = "tos_serrated_charge",          label = "Serrated Charge",                  privateID = 1291399,                soundM = "file:dot",                        advanced = true, desc = "Charge that leaves a bleed." },
            { key = "tos_arrow_barrage",            label = "Arrow Barrage",                    privateID = 1308113,                soundM = "file:targeted",                   advanced = true, desc = "Arrows rain on your location for a few seconds." },
            { key = "tos_tempest_winds",            label = "Tempest Winds",                    privateID = 1288885,                soundM = "file:silenced",                   advanced = true, desc = "Winds build on you, then coalesce into a knockback zone. Drop it away from the group." },
            --{ key = "tos_slither_strike",           label = "Slither Strike",                   privateID = 1295635,                soundM = "file:dot",                        advanced = true    }, -- REMOVED: Slither Strike no longer applies a DoT
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
            { key = "tos_knot_of_snakes_target",    label = "A Knot of Snakes (target)",        privateID = 1290030,                soundM = {"file:marked","file:4s"}, desc = "Snakes envelop a player and suffocate them. Kill or stun the snakes to free them." }, -- 4s targeted
            { key = "tos_knot_of_snakes_stun",      label = "A Knot of Snakes (stun)",          privateID = 263958,                 soundM = nil,                            advanced = true, desc = "The stun that frees someone from the Knot. Break them out." }, -- stun after
            { key = "tos_burrowquake",              label = "Burrowquake",                      privateID = 1300227,                soundM = nil,                            advanced = true, desc = "Ground-wide tick while she's burrowed." },
            { key = "tos_lightning_bite",           label = "Lightning Bite",                   privateID = 1308838,                soundM = nil,                            advanced = true, desc = "Tank bite with a dot." },
            { key = "tos_serpentstorm",             label = "Serpentstorm",                     privateID = 1293048,                soundM = nil,                            advanced = true, desc = "Raid-wide breath plus knockback and lightning." },
            { key = "tos_thunder_spit_dot",         label = "Thunder Spit (dot)",               privateID = 1289588,                soundM = nil,                            advanced = true, desc = "The lingering storm left by Thunder Spit. Don't stand in it." },
            { key = "tos_thunder_spit_target",      label = "Thunder Spit (target)",            privateID = 1289109,                soundM = "file:targeted", desc = "Lightning strikes your spot every second for a few seconds. Keep moving, leaves storms behind." }, -- 3s targeted
            { key = "tos_burrow",                   label = "Burrow",                           privateID = 264206,                 soundM = nil,                            advanced = true, desc = "Merektha burrows and charges across the room. Don't be in her path." },
            { key = "tos_electrified_ground",       label = "Electrified Ground",               privateID = 1297034,                soundM = nil,                            advanced = true, desc = "Charged ground left behind. Don't stand in it." },
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
            { key = "tos_galvanized",               label = "Galvanized",                       privateID = 266923,                 soundM = nil,                            advanced = true, desc = "Damage ramps the longer you body-block the spire beam. Rotate who soaks." },
            { key = "tos_induction_field",          label = "Induction Field",                  privateID = 1291815,                soundM = nil,                            advanced = true, desc = "Standing in the field ticks nature damage. Get out of it." },
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
            { key = "tos_corruption",               label = "Corruption",                       privateID = 1300877,                soundM = nil,                            advanced = true, desc = "Cleanse the Corrupted Lifeforce before it expires, or it bursts the group." },
            { key = "tos_shadowlash",               label = "Shadowlash",                       privateID = 1300714,                soundM = "file:debuff",                  advanced = true, desc = "Tormentor fixates the healer and cuts their healing per hit. Kill it or peel it." },
            { key = "tos_tainted_strike",           label = "Tainted Strike",                   privateID = 1303446,                soundM = nil,                            advanced = true, desc = "Tank knockback plus a stacking shadow dot." },
            { key = "tos_vile_charge",              label = "Vile Charge",                      privateID = 1302618,                soundM = "file:dot",                     advanced = true, desc = "Guardian charges the furthest player. Don't be the one it hits, dot after." },
            { key = "tos_latent_hex",               label = "Latent Hex",                       privateID = 1302153,                soundM = {"file:spread","file:5s"}, desc = "Debuff on you for 5s. When it drops it leaves Hex Muck. Move away first." },
            { key = "tos_flame_shock",              label = "Flame Shock",                      privateID = 1302158,                soundM = nil,                            advanced = true, desc = "Fire on a player with a dot." },
            { key = "tos_hex_muck",                 label = "Hex Muck",                         privateID = 1300684,                soundM = nil,                            advanced = true, desc = "Turns you into a frog and ticks damage. Get out of the muck." },
            { key = "fixate_tormentor",             label = "Fixate",                           privateID = 1300704,                soundM = "file:fixate",                            advanced = true, desc = "A Faithless Tormentor is fixating you. Kite it away from the healer." }, -- Fixated by a faithless tormentor            
        },
    },

    {
        raid    = "Temple of Sethraliss",
        boss    = "Trash mob abilities",
        bossKey = "tos_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "tos_cytotoxin",                label = "Cytotoxin",                        privateID = 1308148,                soundM = "file:dot",                     advanced = true    },
            { key = "tos_siphon_energy",            label = "Siphon Energy",                    privateID = 1303596,                soundM = nil,                            advanced = true    },
            { key = "tos_sunder_slam",              label = "Sunder Slam",                      privateID = 1291468,                soundM = nil,                            advanced = true    },
            { key = "tos_caustic_stomp",            label = "Caustic Stomp",                    privateID = 1303486,                soundM = nil,                            advanced = true    },
            { key = "tos_imbued_conduction",        label = "Imbued Conduction",                privateID = 1296052,                soundM = nil,                            advanced = true    },
            { key = "tos_conduct_lightning",        label = "Conduct Lightning",                privateID = 1296068,                soundM = "file:stun",                    advanced = true    },
            { key = "tos_venomous_slash",           label = "Venomous Slash",                   privateID = 1308546,                soundM = "file:dot",                     advanced = true    },
            { key = "tos_lingering_storm",          label = "Lingering Storm",                  privateID = 1293133,                soundM = nil,                            advanced = true    },
            { key = "tos_polarized_field",          label = "Polarized Field",                  privateID = 273274,                 soundM = nil,                            advanced = true    },
            { key = "tos_latent_hex_trash",         label = "Latent Hex (trash)",               privateID = 1300666,                soundM = {"file:spread","file:5s"},                         },
            { key = "tos_scouring_sand",            label = "Scouring Sand",                    privateID = 272655,                 soundM = nil,                            advanced = true    },
            { key = "tos_poisoned_cheap_shot",      label = "Poisoned Cheap Shot",              privateID = 1308100,                soundM = "file:dot",                     advanced = true    },
        },
    },
}