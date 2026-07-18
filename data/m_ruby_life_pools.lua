-- data/m_ruby_life_pools.lua

CCS_Spells_Mplus_RubyLifePools = {
    {
        raid    = "Ruby Life Pools",
        boss    = "Melidrussa Chillworn",
        bossKey = "rlp_melidrussa",
        section = "Melidrussa Chillworn",
        journalInstanceID = 1202,
        journalEncounterID = 2488,          
        abilities = {
            { key = "rlp_hailbombs",                label = "Hailbombs",                        privateID = 384024,                 soundM = nil,                               advanced = true    },
            { key = "rlp_chillstorm_target",        label = "Chillstorm (Target)",              privateID = 385518,                 soundM = {"file:marked","file:4,5s"},                          },
            { key = "rlp_chillstorm_dot",           label = "Chillstorm (Dot)",                 privateID = 397077,                 soundM = "file:dot",                        advanced = true    },
            { key = "rlp_cold_claws",               label = "Cold Claws",                       privateID = 1305234,                soundM = nil,                               advanced = true    },
            { key = "rlp_frost_overload",           label = "Frost Overload",                   privateID = 373688,                 soundM = "file:break",                      advanced = true    },
            { key = "rlp_storms_eye",               label = "Storm's Eye",                      privateID = 372963,                 soundM = nil,                               advanced = true    },
        },
    },

    {
        raid    = "Ruby Life Pools",
        boss    = "Kokia Blazehoof",
        bossKey = "rlp_kokia",
        section = "Kokia Blazehoof",
        journalInstanceID = 1202,
        journalEncounterID = 2485,         
        abilities = {
            { key = "rlp_searing_wounds",           label = "Searing Wounds",                   privateID = 372860,                 soundM = nil,                            advanced = true    },
            { key = "rlp_inferno",                  label = "Inferno",                          privateID = 384823,                 soundM = nil,                            advanced = true    },
            { key = "rlp_ritual_of_blazebinding",   label = "Ritual of Blazebinding",           privateID = 372865,                 soundM = {"file:drop","file:5s",}                           },
            { key = "rlp_searing_blows",            label = "Searing Blows",                    privateID = 372858,                 soundM = nil,                            advanced = true    },
            { key = "rlp_scorched_earth",           label = "Scorched Earth",                   privateID = 372820,                 soundM = nil,                            advanced = true    },
            { key = "rlp_fiery_demise",             label = "Fiery Demise",                     privateID = 1307372,                soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Ruby Life Pools",
        boss    = "Kyrakka and Erkhart Stormvein",
        bossKey = "rlp_kyrakka",
        section = "Kyrakka and Erkhart Stormvein",
        journalInstanceID = 1202,
        journalEncounterID = 2503,         
        abilities = {
            { key = "rlp_winds_of_change",          label = "Winds of Change",                  privateID = 381518,                 soundM = nil,                            advanced = true    },
            { key = "rlp_inferno_spit",             label = "Inferno Spit",                     privateID = 381862,                 soundM = {"file:drop","file:6s"},                           },
            { key = "rlp_stormslam",                label = "Stormslam",                        privateID = 381515,                 soundM = nil,                            advanced = true    },
            { key = "rlp_roaring_firebreath",       label = "Roaring Firebreath",               privateID = 381526,                 soundM = nil,                            advanced = true    },
            { key = "rlp_flaming_embers",           label = "Flaming Embers",                   privateID = 384773,                 soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "Ruby Life Pools",
        boss    = "Trash mob abilities",
        bossKey = "rlp_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "rlp_living_bomb",              label = "Living Bomb",                      privateID = 373693,                 soundM = {"file:spread","file:6s"},                         },
            { key = "rlp_earthbounds_imprint",      label = "Earthbound's Imprint",             privateID = 1307205,                soundM = "file:dot",                     advanced = true    },
            { key = "rlp_tectonic_strike",          label = "Tectonic Strike",                  privateID = 1305225,                soundM = nil,                            advanced = true    },
            { key = "rlp_lightning_torrent",        label = "Lightning Torrent",                privateID = 1306366,                soundM = "file:dot",                            advanced = true    },
            { key = "rlp_flaming_barrage",          label = "Flaming Barrage",                  privateID = 385536,                 soundM = "file:dot",                            advanced = true    },
            { key = "rlp_electrical_discharge",     label = "Electrical Discharge",             privateID = 1310599,                soundM = "file:dot",                            advanced = true    },
            { key = "rlp_inferno_trash",            label = "Inferno (trash)",                  privateID = 373692,                 soundM = nil,                            advanced = true    },
            { key = "rlp_excavating_blast",         label = "Excavating Blast",                 privateID = 1305201,                soundM = nil,                            advanced = true    },
            { key = "rlp_lightning_rod",            label = "Lightning Rod",                    privateID = 385313,                 soundM = "file:dot",                            advanced = true    },
            { key = "rlp_rolling_thunder",          label = "Rolling Thunder",                  privateID = 392641,                 soundM = "file:marked",                                     },
            { key = "rlp_steel_barrage",            label = "Steel Barrage",                    privateID = 372047,                 soundM = nil,                            advanced = true    },
        },
    },
}