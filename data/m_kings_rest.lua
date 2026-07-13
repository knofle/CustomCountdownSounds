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
            { key = "kr_spit_gold_target",          label = "Spit Gold (target)",               privateID = 1306736,                soundH = nil,                               soundM = {nil, "file:2s"},               advanced = true    },
            { key = "kr_spit_gold_drop",            label = "Spit Gold (drop)",                 privateID = 265773,                 soundH = nil,                               soundM = {nil, "file:6s"},               advanced = true    },
            { key = "kr_molten_gold",               label = "Molten Gold",                      privateID = 265914,                 soundH = nil,                               soundM = nil,                            advanced = true    },
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
            { key = "kr_drain_fluids",              label = "Drain Fluids",                     privateID = 267618,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_desiccation",               label = "Desiccation",                      privateID = 267626,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_entomb",                    label = "Entomb",                           privateID = 267702,                 soundH = nil,                               soundM = nil,                            advanced = true    },
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
            { key = "kr_whirling_axe",              label = "Whirling Axe",                     privateID = 266191,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_barrel_through",            label = "Barrel Through",                   privateID = 267494,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_severing_axe",              label = "Severing Axe",                     privateID = 266231,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_shattered_defenses",        label = "Shattered Defenses",               privateID = 266238,                 soundH = nil,                               soundM = nil,                            advanced = true    },
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
            { key = "kr_gilded_destruction",        label = "Gilded Destruction",               privateID = 1303267,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_savage_maul",               label = "Savage Maul",                      privateID = 1303490,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_hunting_leap",              label = "Hunting Leap",                     privateID = 1303039,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_impaling_spear",            label = "Impaling Spear",                   privateID = 1302945,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_liquid_gold",               label = "Liquid Gold",                      privateID = 1303399,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Kings' Rest",
        boss    = "Trash mob abilities",
        bossKey = "kr_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "kr_shadow_barrage",            label = "Shadow Barrage",                   privateID = 272388,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_entomb_trash",              label = "Entomb (trash)",                   privateID = 271555,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_soul_crush",                label = "Soul Crush",                       privateID = 1302028,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_frost_shock",               label = "Frost Shock",                      privateID = 270499,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_bloodthirsty_axe",          label = "Bloodthirsty Axe",                 privateID = 1301851,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_sudden_rupture",            label = "Sudden Rupture",                   privateID = 1297781,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_absorbed_in_darkness",      label = "Absorbed in Darkness",             privateID = 274387,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_fixate",                    label = "Fixate",                           privateID = 269936,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_mortal_bleed",              label = "Mortal Bleed",                     privateID = 1297918,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_dark_revelation",           label = "Dark Revelation",                  privateID = 1298304,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_healing_tide",              label = "Healing Tide",                     privateID = 270495,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_putrid_seekers",            label = "Putrid Seekers",                   privateID = 1298104,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_pit_of_despair",            label = "Pit of Despair",                   privateID = 276031,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_bladestorm",                label = "Bladestorm",                       privateID = 270927,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_lingering_fluid",           label = "Lingering Fluid",                  privateID = 271564,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_shadow_volley",             label = "Shadow Volley",                    privateID = 270931,                 soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_serpent_strike",            label = "Serpent Strike",                   privateID = 1306763,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "kr_shadowfrost_bolt",          label = "Shadowfrost Bolt",                 privateID = 1294815,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },
}