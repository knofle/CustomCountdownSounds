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
            { key = "kr_spit_gold_target",          label = "Spit Gold ",                       privateID = 1306736,                soundM = {"file:targeted","file:8s"},    desc = "Gold targets you, then drops a pool. Drop it away from the group and the boss." },
            { key = "kr_spit_gold_drop",            label = "Spit Gold (dot)",                  privateID = 265773,                 soundM = nil,                            advanced = true, desc = "The actual dot debuff" },
            { key = "kr_molten_gold",               label = "Molten Gold",                      privateID = 265914,                 soundM = nil,                            advanced = true, desc = "Fire pool from Spit Gold. Don't touch it." },
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
            { key = "kr_drain_fluids",              label = "Drain Fluids",                     privateID = 267618,                 soundM = "file:targeted",                                   desc = "Ramping damage that applies Desiccation if it finishes. Immunity cancels it." },
            { key = "kr_desiccation",               label = "Desiccation",                      privateID = 267626,                 soundM = "file:debuff",                  advanced = true,   desc = "Lowers your damage and speed. Get healed above 90% to clear it." },
            { key = "kr_entomb",                    label = "Entomb",                           privateID = 267702,                 soundM = "file:marked",                  advanced = true,   desc = "You're locked in a crypt. Struggle to show which one, wait for a free." },
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
            { key = "kr_whirling_axe",              label = "Whirling Axe",                     privateID = 266191,                 soundM = nil,                            advanced = true,   desc = "Spinning knockback around Kula, then lingering axes. Move out of melee to dodge them." },
            { key = "kr_barrel_through",            label = "Barrel Through",                   privateID = 267494,                 soundM = {"file:targeted","file:6s"},                       desc = "Aka'ali charges you for huge damage. Stack players in the path to split it." },
            { key = "kr_severing_axe",              label = "Severing Axe",                     privateID = 266231,                 soundM = "file:dot",                     advanced = true,   desc = "Heavy bleed on a random player. Just heal through it." },
            { key = "kr_bloodthirsty_axe",          label = "Bloodthirsty Axe",                 privateID = 1301851,                soundM = "file:dot",                     advanced = true,   desc = "Heavy bleed on two random players. Just heal through it." },
            { key = "kr_shattered_defenses",        label = "Shattered Defenses",               privateID = 266238,                 soundM = "debuff",                       advanced = true,   desc = "You take 200% more physical damage. Tanks, stay away from the boss while it's up." },
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
            { key = "kr_gilded_destruction",        label = "Gilded Destruction",               privateID = 1303267,                soundM = nil,                            advanced = true, desc = "Raid-wide fire hit plus a 15s dot. Heal through it." },
            { key = "kr_savage_maul",               label = "Savage Maul",                      privateID = 1303490,                soundM = nil,                            advanced = true, desc = "T'zala charges and mauls you: bleed plus you take more physical damage." },
            { key = "kr_hunting_leap",              label = "Hunting Leap",                     privateID = 1303039,                soundM = nil,                            advanced = true, desc = "Reban jumps on you for a bleed. Just heal through it." },
            { key = "kr_impaling_spear",            label = "Impaling Spear",                   privateID = 1302945,                soundM = nil,                            advanced = true, desc = "Spears from the ceiling. Don't stand under the impacts." },
            --{ key = "kr_liquid_gold",               label = "Liquid Gold",                      privateID = 1303399,                soundM = nil,                            advanced = true, desc = "Fire drips leaving pools. Don't stand in them." }, -- REMOVED: Liquid Gold on T'zala removed
        },
    },

    {
        raid    = "Kings' Rest",
        boss    = "Trash mob abilities",
        bossKey = "kr_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "kr_shadow_barrage",            label = "Shadow Barrage",                   privateID = 272388,                 soundM = nil,                            advanced = true    },
            { key = "kr_entomb_trash",              label = "Entomb (trash)",                   privateID = 271555,                 soundM = "file:marked",                                     },
            { key = "kr_soul_crush",                label = "Soul Crush",                       privateID = 1302028,                soundM = nil,                            advanced = true    },
            { key = "kr_frost_shock",               label = "Frost Shock",                      privateID = 270499,                 soundM = nil,                            advanced = true    },
            { key = "kr_sudden_rupture",            label = "Sudden Rupture",                   privateID = 1297781,                soundM = "file:dot",                     advanced = true    },
            { key = "kr_absorbed_in_darkness",      label = "Absorbed in Darkness",             privateID = 274387,                 soundM = nil,                            advanced = true    },
            { key = "kr_fixate",                    label = "Fixate",                           privateID = 269936,                 soundM = "file:fixate",                  advanced = true    },
            { key = "kr_mortal_bleed",              label = "Mortal Bleed",                     privateID = 1297918,                soundM = nil,                            advanced = true    },
            { key = "kr_dark_revelation",           label = "Dark Revelation",                  privateID = 1298304,                soundM = {"file:debuff","file:5s"},      advanced = true    },
            { key = "kr_healing_tide",              label = "Healing Tide",                     privateID = 270495,                 soundM = nil,                            advanced = true    },
            { key = "kr_putrid_seekers",            label = "Putrid Seekers",                   privateID = 1298104,                soundM = nil,                            advanced = true    },
            { key = "kr_pit_of_despair",            label = "Pit of Despair",                   privateID = 276031,                 soundM = nil,                            advanced = true    },
            { key = "kr_bladestorm",                label = "Bladestorm",                       privateID = 270927,                 soundM = {"file:fixate","file:6s"},                         },
            { key = "kr_lingering_fluid",           label = "Lingering Fluid",                  privateID = 271564,                 soundM = nil,                            advanced = true    },
            { key = "kr_shadow_volley",             label = "Shadow Volley",                    privateID = 270931,                 soundM = nil,                            advanced = true    },
            { key = "kr_serpent_strike",            label = "Serpent Strike",                   privateID = 1306763,                soundM = "file:dot",                     advanced = true    },
            { key = "kr_shadowfrost_bolt",          label = "Shadowfrost Bolt",                 privateID = 1294815,                soundM = nil,                            advanced = true    },
        },
    },
}