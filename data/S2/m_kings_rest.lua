-- data/m_kings_rest.lua

CCS_Spells_Mplus_KingsRest = {
    {
        raid    = "Kings' Rest",
        boss    = "The Golden Serpent",
        bossKey = "kr_golden_serpent",
        section = "The Golden Serpent",
        journalInstanceID = 1041,
        journalEncounterID = 2165,         
        abilities = {
            { key = "kr_spit_gold_target",          label = "Spit Gold ",                       privateID = 1306736,                soundM = {"file:targeted","file:8s" } },
            { key = "kr_spit_gold_drop",            label = "Spit Gold (dot)",                  privateID = 265773,                 soundM = nil,                            advanced = true },
            { key = "kr_molten_gold",               label = "Molten Gold",                      privateID = 265914,                 soundM = nil,                            advanced = true },
        },
    },

    {
        raid    = "Kings' Rest",
        boss    = "Mchimba the Embalmer",
        bossKey = "kr_mchimba",
        section = "Mchimba the Embalmer",
        journalInstanceID = 1041,
        journalEncounterID = 2171,          
        abilities = {
            { key = "kr_drain_fluids",              label = "Drain Fluids",                     privateID = 267618,                 soundM = "file:targeted" },
            { key = "kr_desiccation",               label = "Desiccation",                      privateID = 267626,                 soundM = "file:heal",                                   },
            { key = "kr_entomb",                    label = "Entomb",                           privateID = 267702,                 soundM = nil,                           advanced = true },
            { key = "kr_wretched_discharge",        label = "Wretched Discharge",               privateID = 267763,                 soundM = nil,                           advanced = true },
            { key = "kr_burning_ground",            label = "Burning Ground",                   privateID = 267874,                 soundM = nil,                           advanced = true },


        },
    },

    {
        raid    = "Kings' Rest",
        boss    = "The Council of Tribes",
        bossKey = "kr_council_of_tribes",
        section = "The Council of Tribes",
        journalInstanceID = 1041,
        journalEncounterID = 2170,          
        abilities = {
            { key = "kr_whirling_axe",              label = "Whirling Axe",                     privateID = 266191,                 soundM = nil,                               advanced = true },
            { key = "kr_barrel_through",            label = "Barrel Through",                   privateID = 267494,                 soundM = {"file:soak","file:6s" } },
            { key = "kr_severing_axe",              label = "Severing Axe",                     privateID = 266231,                 soundM = nil,                               advanced = true },
            { key = "kr_bloodthirsty_axe",          label = "Bloodthirsty Axe",                 privateID = 1301851,                soundM = nil,                               advanced = true },
            { key = "kr_shattered_defenses",        label = "Shattered Defenses",               privateID = 266238,                 soundM = nil,                               advanced = true },
        },
    },

    {
        raid    = "Kings' Rest",
        boss    = "King Dazar",
        bossKey = "kr_dazar",
        section = "King Dazar",
        journalInstanceID = 1041,
        journalEncounterID = 2172,          
        abilities = {
            { key = "kr_gilded_destruction",        label = "Gilded Destruction",               privateID = 1303267,                soundM = nil,                               advanced = true },
            { key = "kr_savage_maul",               label = "Savage Maul",                      privateID = 1303490,                soundM = nil,                               advanced = true },
            { key = "kr_hunting_leap",              label = "Hunting Leap",                     privateID = 1303039,                soundM = "file:move",                                       },
            { key = "kr_impaling_spear",            label = "Impaling Spear",                   privateID = 1302945,                soundM = nil,                               advanced = true },
            --{ key = "kr_liquid_gold",               label = "Liquid Gold",                      privateID = 1303399,                soundM = nil,                            advanced = true, desc = "Fire drips leaving pools. Don't stand in them." }, -- REMOVED: Liquid Gold on T'zala removed
            { key = "kr_deathly_roar",              label = "Deathly Roar",                     privateID = 269369,                 soundM = nil,                               advanced = true },
        
        },
    },

    {
        raid    = "Kings' Rest",
        boss    = "Trash mob abilities",
        bossKey = "kr_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "kr_fixate",                    label = "Fixate",                           privateID = 269936,                 soundM = "file:fixate",                     advanced = true     },
            { key = "kr_suppression_slam",          label = "Suppression Slam",                 privateID = 270003,                 soundM = nil,                               advanced = true     },
            
            { key = "kr_shadowfrost_bolt",          label = "Shadowfrost Bolt",                 privateID = 1294815,                soundM = nil,                               advanced = true     },
            { key = "kr_hex_volley",                label = "Hex Volley",                       privateID = 269972,                 soundM = nil,                               advanced = true     },
            { key = "kr_hex",                       label = "Hex",                              privateID = 270492,                 soundM = nil,                               advanced = true     },            
            { key = "kr_pit_of_despair",            label = "Pit of Despair",                   privateID = 276031,                 soundM = nil,                               advanced = true     },
            
            { key = "kr_sudden_rupture",            label = "Sudden Rupture",                   privateID = 1297781,                soundM = nil,                               advanced = true     },
            { key = "kr_mortal_bleed",              label = "Mortal Bleed",                     privateID = 1297918,                soundM = nil,                               advanced = true     },
            { key = "kr_bladestorm",                label = "Bladestorm",                       privateID = 270927,                 soundM = {"file:fixate"},                                       },
            { key = "kr_bind_soul",                 label = "Bind Soul",                        privateID = 270920,                 soundM = nil,                               advanced = true     },        

            { key = "kr_purifying_flame",           label = "Purifying Flame",                  privateID = 270292,                 soundM = nil,                               advanced = true     },            
            { key = "kr_entomb_trash",              label = "Entomb (trash)",                   privateID = 271555,                 soundM = nil,                               advanced = true     },
            
            { key = "kr_soul_crush",                label = "Soul Crush",                       privateID = 1302028,                soundM = nil,                               advanced = true     },
            { key = "kr_frost_shock",               label = "Frost Shock",                      privateID = 270499,                 soundM = nil,                               advanced = true     },
            { key = "kr_healing_tide",              label = "Healing Tide",                     privateID = 270495,                 soundM = nil,                               advanced = true     },
            { key = "kr_putrid_seekers",            label = "Putrid Seekers",                   privateID = 1298104,                soundM = nil,                               advanced = true     },
            { key = "kr_lingering_fluid",           label = "Lingering Fluid",                  privateID = 271564,                 soundM = nil,                               advanced = true     },
            { key = "kr_shadow_volley",             label = "Shadow Volley",                    privateID = 270931,                 soundM = nil,                               advanced = true     },
            { key = "kr_serpent_strike",            label = "Serpent Strike",                   privateID = 1306763,                soundM = nil,                               advanced = true     },
            { key = "kr_erupting_darkness",         label = "Erupting Darkness",                privateID = 272021,                 soundM = nil,                               advanced = true     },
            { key = "kr_shadow_barrage",            label = "Shadow Barrage",                   privateID = 272388,                 soundM = nil,                               advanced = true     },
            { key = "kr_absorbed_in_darkness",      label = "Absorbed in Darkness",             privateID = 274387,                 soundM = nil,                               advanced = true     },
            { key = "kr_dark_revelation",           label = "Dark Revelation",                  privateID = 1298304,                soundM = {"file:out","file:5s" },                               },
            




            

        },
    },
}