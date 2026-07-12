-- data/m_blinding_vale.lua

CCS_Spells_Mplus_BlindingVale = {
    {
        raid    = "Blinding Vale",
        boss    = "Ikuzz the Light Hunter",
        bossKey = "bv_ikuzz",
        section = "Ikuzz the Light Hunter",
        journalInstanceID = 1309,
        journalEncounterID = 2769, 
        abilities = {
            { key = "bv_bloodthirsty_gaze",         label = "Bloodthirsty Gaze",                privateID = 1237091,                soundM = "targeted"                                                     },
            { key = "bv_bloodthorn_roots",          label = "Bloodthorn Roots",                 privateID = 1259365,                soundM = "file:root",                                       },
            { key = "bv_verdant_stomp",             label = "Verdant Stomp",                    privateID = 1236747,                soundM = nil,                            advanced = true    },
            { key = "bv_incise",                    label = "Incise",                           privateID = 1237267,                soundM = "file:bleed",                   advanced = true    }, -- Private aura
            { key = "bv_crunched",                  label = "Crunched",                         privateID = 1272290,                soundM = "file:stun",                    advanced = true    }, -- Private aura
        },
    },

    {
        raid    = "Blinding Vale",
        boss    = "Lightblossom Trinity",
        bossKey = "bv_trinity",
        section = "Lightblossom Trinity",
        journalInstanceID = 1309,
        journalEncounterID = 2770,        
        abilities = {
            { key = "bv_thornblade",                label = "Thornblade (Short)",               privateID = 1261276,                soundM = "file:bleed",                            advanced = true    },
            { key = "bv_thornblade_2",              label = "Thornblade (Long)",                privateID = 1235865,                soundM = "file:bleed",                            advanced = true    },
            { key = "bv_bedrock_surge",             label = "Bedrock Surge",                    privateID = 1276586,                soundM = "file:dot",                            advanced = true    },
            { key = "bv_lightblossom_beam",         label = "Lightblossom Beam",                privateID = 1235574,                soundM = nil,                            advanced = true    },
            { key = "bv_fertile_loam",              label = "Fertile Loam",                     privateID = 1234802,                soundM = nil,                            advanced = true    },
            { key = "bv_light_scorched_earth",      label = "Light-Scorched Earth",             privateID = 1235828,                soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Blinding Vale",
        boss    = "Lightwarden Ruia",
        bossKey = "bv_ruia",
        section = "Lightwarden Ruia",
        journalInstanceID = 1309,
        journalEncounterID = 2771,       
        abilities = {
            { key = "bv_pulverizing_strikes",       label = "Pulverizing Strikes",              privateID = 1240222,                soundM = "targeted"                                                     },
            { key = "bv_grievous_thrash",           label = "Grievous Thrash",                  privateID = 1241058,                soundM = nil,                            advanced = true    },
            { key = "bv_pulverized",                label = "Pulverized",                       privateID = 1257094,                soundM = nil,                            advanced = true    },
            { key = "bv_lightfire",                 label = "Lightfire",                        privateID = 1239825,                soundM = {"file:drop","file:6s"}                            },
            { key = "bv_lightfire_beams",           label = "Lightfire Beams",                  privateID = 1239919,                soundM = nil,                            advanced = true    }, -- Private aura
            { key = "bv_hunting_leap",              label = "Hunting Leap",                     privateID = 1303039,                soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Blinding Vale",
        boss    = "Ziekket",
        bossKey = "bv_ziekket",
        section = "Ziekket",
        journalInstanceID = 1309,
        journalEncounterID = 2772,        
        abilities = {
            { key = "bv_lightblooms_might",         label = "Lightbloom's Might",               privateID = 1247052,                soundM = nil,                            advanced = true    },
            { key = "bv_thornspike",                label = "Thornspike",                       privateID = 1247746,                soundM = nil,                            advanced = true    },
            { key = "bv_lightsap",                  label = "Lightsap",                         privateID = 1246753,                soundM = nil,                            advanced = true    },
            --{ key = "bv_concentrated_lightbeam",    label = "Concentrated Lightbeam",           privateID = 1246751,                soundM = nil,                            advanced = true    }, used on boss
        },
    },

    {
        raid    = "Blinding Vale",
        boss    = "Trash mob abilities",
        bossKey = "bv_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "bv_spore_spines",              label = "Spore Spines",                     privateID = 1238084,                soundM = nil,                            advanced = true    },
            { key = "bv_blight_resin",              label = "Blight Resin",                     privateID = 1251345,                soundM = nil,                            advanced = true    },
            { key = "bv_lightmaw_beams",            label = "Lightmaw Beams",                   privateID = 1238368,                soundM = nil,                            advanced = true    },
            { key = "bv_grievous_gash",             label = "Grievous Gash",                    privateID = 1242135,                soundM = nil,                            advanced = true    },
            { key = "bv_ruptured_earth",            label = "Ruptured Earth",                   privateID = 1237858,                soundM = nil,                            advanced = true    },
            { key = "bv_toxic_spew",                label = "Toxic Spew",                       privateID = 1250937,                soundM = nil,                            advanced = true    },
            { key = "bv_thornblade_trash",          label = "Thornblade",                       privateID = 1238076,                soundM = nil,                            advanced = true    },            
        },
    },
}