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
            { key = "rlp_hailbombs",                label = "Hailbombs",                        privateID = 384024,                 soundM = nil,                               advanced = true, desc = "Frost mines spawn from Hailburst. Don't walk into them." },
            { key = "rlp_chillstorm_target",        label = "Chillstorm (Target)",              privateID = 385518,                 soundM = {"file:marked","file:4,5s"}, desc = "A storm spawns on you and pulls everyone in. Drop it away from the group." },
            { key = "rlp_chillstorm_dot",           label = "Chillstorm (Dot)",                 privateID = 397077,                 soundM = nil,                               advanced = true, desc = "Frost tick while the storm is up." },
            { key = "rlp_cold_claws",               label = "Cold Claws",                       privateID = 1305234,                soundM = nil,                               advanced = true, desc = "Whelp stacks on its target. Freezes you solid at 20 stacks." },
            { key = "rlp_frost_overload",           label = "Frost Overload",                   privateID = 373688,                 soundM = "file:break", desc = "Boss shields up and ramps raid damage. Break the Ice Bulwark fast." },
            { key = "rlp_storms_eye",               label = "Storm's Eye",                      privateID = 372963,                 soundM = nil,                               advanced = true, desc = "Center of the Chillstorm: 100% more frost damage. Stay out of the eye." },
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
            { key = "rlp_searing_wounds",           label = "Searing Wounds",                   privateID = 372860,                 soundM = nil,                            advanced = true, desc = "Stacking burn from Searing Blows." },
            { key = "rlp_inferno",                  label = "Inferno",                          privateID = 384823,                 soundM = nil,                            advanced = true, desc = "Firestorm's stacking raid burn." },
            { key = "rlp_ritual_of_blazebinding",   label = "Ritual of Blazebinding",           privateID = 372865,                 soundM = {"file:drop","file:5s",},                        desc = "A Firestorm spawns on a player. Move out of the 12y before it lands." },
            { key = "rlp_searing_blows",            label = "Searing Blows",                    privateID = 372858,                 soundM = nil,                            advanced = true, desc = "Tank combo, 4 hits stacking a burn." },
            { key = "rlp_scorched_earth",           label = "Scorched Earth",                   privateID = 372820,                 soundM = nil,                            advanced = true, desc = "Fire left on the ground (Mythic). Don't stand in it." },
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
            { key = "rlp_winds_of_change",          label = "Winds of Change",                  privateID = 381518,                 soundM = nil,                            advanced = true, desc = "Hurricane pushes you and the embers around. Watch where it shoves you." },
            { key = "rlp_inferno_spit",             label = "Inferno Spit",                     privateID = 381862,                 soundM = {"file:drop","file:6s"}, desc = "Fire lands on you and leaves embers when it drops. Move out of the group." },
            { key = "rlp_stormslam",                label = "Stormslam",                        privateID = 381515,                 soundM = nil,                            advanced = true, desc = "Tank hit, stacks 100% nature vuln." },
            { key = "rlp_roaring_firebreath",       label = "Roaring Firebreath",               privateID = 381526,                 soundM = nil,                            advanced = true, desc = "Frontal breath from Kyrakka. Get out of the cone." },
            { key = "rlp_flaming_embers",           label = "Flaming Embers",                   privateID = 384773,                 soundM = nil,                            advanced = true, desc = "Burning ground from Inferno Spit. Don't stand in it." },
        },
    },

    {
        raid    = "Ruby Life Pools",
        boss    = "Trash mob abilities",
        bossKey = "rlp_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "rlp_excavating_blast",         label = "Excavating Blast",                 privateID = 1305201,                soundM = nil,                               advanced = true, desc = "Primal Juggernaught: Unavoidable damage and a dot. Dodge the blast chunks."    },            
            { key = "rlp_earthbounds_imprint",      label = "Earthbound's Imprint",             privateID = 1307205,                soundM = nil,                               advanced = true, desc = "Earthbound Guardian: Random target damage and dot."    },
            { key = "rlp_tectonic_strike",          label = "Tectonic Strike",                  privateID = 1305225,                soundM = nil,                               advanced = true, desc = "Deepstone Earthshaper: Stacking damage taken debuff on the tank."    },            
            { key = "rlp_steel_barrage",            label = "Steel Barrage",                    privateID = 372047,                 soundM = nil,                               advanced = true, desc = "Defier Draghar: Channeled tank buster. Creates puddles to dodge."    },            
            { key = "rlp_inferno_trash",            label = "Inferno (trash)",                  privateID = 373692,                 soundM = nil,                               advanced = true, desc = "Blazebound Destroyer: Big aoe damage and 5s lingering dot after the cast."    },            
            { key = "rlp_living_bomb",              label = "Living Bomb",                      privateID = 373693,                 soundM = {"file:spread","file:6s"},                          desc = "Primalist Cinderweaver: Dot with a damage on expiration, that also and knocks close friends and enemies in the air after 6 seconds."  },
            { key = "rlp_flaming_barrage",          label = "Flaming Barrage",                  privateID = 385536,                 soundM = nil,                               advanced = true, desc = "Ashseer Flamelasher: Damage to the current target (tank). Can be stunned or knocked by living bomb."    },
            { key = "rlp_fire_maw",                 label = "Fire Maw",                         privateID = 395292,                 soundM = nil,                               advanced = true, desc = "Flamegullet: Tank buster with a 6 second dot."    },
            { key = "rlp_rolling_thunder",          label = "Rolling Thunder",                  privateID = 392641,                 soundM = "file:marked",                                      desc = "Thunderhead: 2 dots on your party at the same time. Dispel one, stagger the other. On removal they do a 10 second group dot."},
            { key = "rlp_lightning_torrent",        label = "Lightning Torrent",                privateID = 1306366,                soundM = nil,                               advanced = true, desc = "Tempest Channeler: Random target 7 second damage channel."   },
            { key = "rlp_electrical_discharge",     label = "Electrical Discharge",             privateID = 1310599,                soundM = nil,                               advanced = true    },
            { key = "rlp_lightning_rod",            label = "Lightning Rod",                    privateID = 385313,                 soundM = nil,                               advanced = true, desc = "Ruinous Stormbringer"    },

        },
    },
}