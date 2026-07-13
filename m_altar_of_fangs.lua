-- data/m_altar_of_fangs.lua

CCS_Spells_Mplus_AltarOfFangs = {
    {
        raid    = "Altar of Fangs",
        boss    = "Rav'i",
        bossKey = "af_ravi",
        section = "Rav'i",
        journalInstanceID = 1322,
        journalEncounterID = 2878,
        abilities = {
            { key = "carrion_burst",                label = "Carrion Burst",                    privateID = 1307700,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "triple_shot",                  label = "Triple Shot",                      privateID = 1297876,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Altar of Fangs",
        boss    = "The Writhing Coil",
        bossKey = "af_writhing_coil",
        section = "The Writhing Coil",
        journalInstanceID = 1322,
        journalEncounterID = 2879,        
        abilities = {
            { key = "spiteful_hunt",                label = "Spiteful Hunt",                    privateID = 1300503,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Fixate 15s
            { key = "synchronized_venom",           label = "Synchronized Venom",               privateID = 1299189,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "spiteful_venom",               label = "Spiteful Venom",                   privateID = 1305368,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "death_rattle",                 label = "Death Rattle",                     privateID = 1299080,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Stacking dot
            { key = "corrosive_fangs",              label = "Corrosive Fangs",                  privateID = 1294845,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "vine_grip",                    label = "Vine Grip",                        privateID = {1300328,1287798,1287797},  soundH = nil,                          soundM = nil,                            advanced = true    }, -- Make vines, 13 people pull
        },
    },

    {
        raid    = "Altar of Fangs",
        boss    = "Zul'jan",
        bossKey = "af_zuljan",
        section = "Zul'jan",
        journalInstanceID = 1322,
        journalEncounterID = 2880,
        abilities = {
            { key = "ritual_venom",                 label = "Ritual Venom",                     privateID = 1300894,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 48s dot, big nature damage boom after
            { key = "boneslicer",                   label = "Boneslicer",                       privateID = 1301508,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "ritual_of_the_fang",           label = "Ritual of the Fang",               privateID = 1300885,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "bloodletting",                 label = "Bloodletting",                     privateID = 1301231,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Zul'jan-specific Bloodletting
            { key = "blood_sacrifice",              label = "Blood Sacrifice",                  privateID = 1306550,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Altar of Fangs",
        boss    = "Trash mob abilities",
        bossKey = "af_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "laced_edge",                   label = "Laced Edge",                       privateID = 1308518,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "envenom",                      label = "Envenom",                          privateID = 1307571,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "bloodletting_trash",           label = "Bloodletting (trash)",             privateID = 1307531,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "septic_spatter",               label = "Septic Spatter",                   privateID = 1306232,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "paralyzing_shots",             label = "Paralyzing Shots",                 privateID = 1294569,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "deadly_venom",                 label = "Deadly Venom",                     privateID = 1297422,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "toxic_breath",                 label = "Toxic Breath",                     privateID = 1306669,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "infest",                       label = "Infest",                           privateID = 1308865,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Private aura, confirmed by BigWigs
        },
    },
}