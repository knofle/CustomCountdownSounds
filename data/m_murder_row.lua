-- data/m_murder_row.lua

CCS_Spells_Mplus_MurderRow = {
    {
        raid    = "Murder Row",
        boss    = "Kystia Manaheart",
        bossKey = "mr_kystia",
        section = "Kystia Manaheart",
        journalInstanceID = 1304,
        journalEncounterID = 2679,        
        abilities = {
            { key = "mr_corroding_spittle_boss",    label = "Corroding Spittle",                privateID = 1228198,                soundM = "dot",                            advanced = true, desc = "Stacking fire dot from Nibbles." },
        },
    },

    {
        raid    = "Murder Row",
        boss    = "Zaen Bladesorrow",
        bossKey = "mr_zaen",
        section = "Zaen Bladesorrow",
        journalInstanceID = 1304,
        journalEncounterID = 2680,         
        abilities = {
            { key = "mr_murder_in_row",             label = "Murder in a Row (target)",         privateID = 474545,                 soundM = "targeted", desc = "Zaen aims at everyone. Get behind Forbidden Freight before he fires." },
            { key = "mr_fire_bomb",                 label = "Fire Bomb",                        privateID = 1214352,                soundM = {"break","file:6s"}, desc = "Bomb on you, explodes in 6s. Drop it away from the group and off any cover you need." },
            { key = "mr_murder_in_row_bleed",       label = "Murder in a Row (dot)",            privateID = 474740,                 soundM = nil,                           advanced = true, desc = "Bleed from getting caught by Murder in a Row. Take cover next time." },
            { key = "mr_fel_infused_freight",       label = "Fel-Infused Freight",              privateID = 1219631,                soundM = nil,                           advanced = true, desc = "Fel crates tick raid-wide damage." },
            { key = "mr_heartstop_poison_boss",     label = "Heartstop Poison",                 privateID = 474515,                 soundM = nil,                           advanced = true, desc = "Cuts your max health and hits hard over 15s." },
            { key = "mr_workplace_accident",        label = "Workplace Accident",               privateID = 1217992,                soundM = nil,                           advanced = true     },
        },
    },

    {
        raid    = "Murder Row",
        boss    = "Xathuux the Annihilator",
        bossKey = "mr_xathuux",
        section = "Xathuux the Annihilator",
        journalInstanceID = 1304,
        journalEncounterID = 2681, 
        abilities = {
            { key = "mr_axe_toss",                  label = "Axe Toss",                         privateID = 1214637,                soundM = {"targeted","file:3,5s"}, desc = "Axe lands near a player and beams everyone with Fel Lightning. Kill the axe fast." },
            { key = "mr_fel_lightning",             label = "Fel Lightning",                    privateID = 1214650,                soundM = nil,                            advanced = true, desc = "Stacking raid damage from the thrown axe. Kill the axe to stop it." },
            { key = "mr_infernal_crush",            label = "Infernal Crush",                   privateID = 1295455,                soundM = nil,                            advanced = true, desc = "Fire erupts under you, then a dot. Move out of the pool." },
            { key = "mr_burning_steps",             label = "Burning Steps",                    privateID = 474234,                 soundM = nil,                            advanced = true, desc = "Fel pools spread from Xathuux and linger. Don't stand in them." },
            { key = "mr_legion_strike",             label = "Legion Strike",                    privateID = 473898,                 soundM = nil,                            advanced = true, desc = "Heavy tank hit that cuts your healing received. Use a cooldown." },
        },
    },

    {
        raid    = "Murder Row",
        boss    = "Lithiel Cinderfury",
        bossKey = "mr_lithiel",
        section = "Lithiel Cinderfury",
        journalInstanceID = 1304,
        journalEncounterID = 2682, 
        abilities = {
            { key = "mr_demonic_gateway_travel",    label = "Demonic Gateway (travel)",         privateID = 1214730,                soundM = nil,                            advanced = true, desc = "Use Lithiel's gateway to pass through Malefic Wave safely." }, -- 3s travel
            { key = "mr_demonic_gateway_cd",        label = "Demonic Gateway (cooldown)",       privateID = 1214740,                soundM = nil,                            advanced = true, desc = "You just used the gateway, can't use it again for 30s." }, -- 30s cannot use
            { key = "mr_malefic_wave",              label = "Malefic Wave",                     privateID = 1217384,                soundM = nil,                            advanced = true, desc = "Expanding fel wave. Take the Demonic Gateway through it, or eat stacking fire damage." },
        },
    },

    {
        raid    = "Murder Row",
        boss    = "Trash mob abilities",
        bossKey = "mr_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "mr_fel_missiles",              label = "Fel Missiles",                     privateID = 1216571,                soundM = "dot",                          advanced = true    },          
            { key = "mr_heartstop_poison_trash",    label = "Heartstop Poison",                 privateID = 1216590,                soundM = "dot",                          advanced = true    },
            { key = "mr_corroding_spittle_trash",   label = "Corroding Spittle",                privateID = 1217633,                soundM = "dot",                          advanced = true    },
            { key = "mr_shield_bash",               label = "Shield Bash",                      privateID = 1216529,                soundM = "debuff",                       advanced = true    },
            { key = "mr_cutpurse",                  label = "Cutpurse",                         privateID = 1216300,                soundM = "bleed",                        advanced = true    },
            { key = "mr_blade_dance",               label = "Blade Dance",                      privateID = 1302010,                soundM = nil,                            advanced = true    },
            { key = "mr_glaive_toss",               label = "Glaive Toss",                      privateID = 1295035,                soundM = "file:bleed",                   advanced = true    },
            { key = "mr_flay",                      label = "Flay",                             privateID = 1295427,                soundM = nil,                            advanced = true    },
            { key = "mr_curse_of_doom",             label = "Curse of Doom",                    privateID = 1217973,                soundM = "file:curse",                                      },
            { key = "mr_drain_life",                label = "Drain Life",                       privateID = 1297682,                soundM = "file:drain",                   advanced = true    }, --Cast by Corrupted Warlock
            { key = "mr_eye_beam",                  label = "Eye Beam",                         privateID = 1216954,                soundM = nil,                            advanced = true    },
            { key = "mr_scathing_review",           label = "Scathing Review",                  privateID = 1257877,                soundM = "targeted",                     advanced = true    },
            { key = "mr_fel_scarred_earth",         label = "Fel-Scarred Earth",                privateID = 1294870,                soundM = nil,                            advanced = true    },
            { key = "mr_spill_zone",                label = "Spill Zone",                       privateID = 1216074,                soundM = nil,                            advanced = true    },
            { key = "mr_seduction",                 label = "Seduction",                        privateID = 1201554,                soundM = "file:stun",                    advanced = true    },
            { key = "mr_fel_beam_damage",           label = "Fel Beam (damage)",                privateID = 1215985,                soundM = nil,                            advanced = true    },
            { key = "mr_fel_beam_target",           label = "Fel Beam",                         privateID = 1218187,                soundM = {"fixate","file:8s"},                                          },
            { key = "mr_server",                    label = "Server",                           privateID = 1218465,                soundM = "file:serve",                   advanced = true    },
            { key = "mr_cleaner",                   label = "Cleaner",                          privateID = 1218466,                soundM = "file:clean",                   advanced = true    },
            { key = "mr_entertainer",               label = "Entertainer",                      privateID = 1218467,                soundM = "file:collect",                 advanced = true    },
            { key = "mr_bouncer",                   label = "Bouncer",                          privateID = 1218468,                soundM = "file:bounce",                  advanced = true    },  
        },
    },
}