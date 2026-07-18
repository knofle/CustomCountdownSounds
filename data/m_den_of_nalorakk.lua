-- data/m_den_of_nalorakk.lua

CCS_Spells_Mplus_DenOfNalorakk = {
    {
        raid    = "Den of Nalorakk",
        boss    = "The Hoardmonger",
        bossKey = "dn_hoardmonger",
        section = "The Hoardmonger",
        journalInstanceID = 1311,
        journalEncounterID = 2776,        
        abilities = {
            { key = "dn_toxic_spores",              label = "Toxic Spores",                     privateID = 1234846,                soundM = "dot",                          advanced = true, desc = "Stacking poison from touching a mushroom. Soak the mushrooms so they don't burst on everyone. Cleansable." },
            { key = "dn_hearty_bellow",             label = "Hearty Bellow",                    privateID = 1235125,                soundM = "dot",                          advanced = true, desc = "Raid-wide hit plus a 10s dot with knockback. Heal through it." },
            { key = "dn_ravenous_bellow",           label = "Ravenous Bellow",                  privateID = 1234681,                soundM = "dot",                          advanced = true, desc = "Raid-wide hit plus a 10s dot. Heal through it." },
            { key = "dn_bonespiked",                label = "Bonespiked",                       privateID = 1235405,                soundM = nil,                            advanced = true, desc = "Standing in bone spikes. Slows you and ticks hard. Get off them." },
        },
    },

    {
        raid    = "Den of Nalorakk",
        boss    = "Sentinel of Winter",
        bossKey = "dn_sentinel_of_winter",
        section = "Sentinel of Winter",
        journalInstanceID = 1311,
        journalEncounterID = 2777,          
        abilities = {
            { key = "dn_glacial_torment",           label = "Glacial Torment",                  privateID = 1235549,                soundM = nil,                            advanced = true, desc = "Heavy stacking frost damage on you. Cleansable (Magic)." },
            { key = "dn_snowdrift_boss",            label = "Snowdrift",                        privateID = 1235841,                soundM = "file:safe",                    advanced = true, desc = "Slowing snow left where a core died. Don't stand in it (but it blocks knockbacks)." },
            { key = "dn_blizzards_wrath",           label = "Blizzard's Wrath",                 privateID = 1236289,                soundM = nil,                            advanced = true    },
            { key = "dn_frozen_tempest",            label = "Frozen Tempest",                   privateID = 1297749,                soundM = nil,                            advanced = true    },
            { key = "dn_winters_shroud",            label = "Winter's Shroud",                  privateID = 1235829,                soundM = nil,                            advanced = true, desc = "Raid-wide frost hit that raises your frost damage taken. Kill the Shivercores fast." },
            { key = "dn_raging_squall",             label = "Raging Squall",                    privateID = 1235641,                soundM = nil,                            advanced = true, desc = "Wandering storm that knocks you back. Stay out of its path." },
        },
    },

    {
        raid    = "Den of Nalorakk",
        boss    = "Nalorakk",
        bossKey = "dn_nalorakk",
        section = "Nalorakk",
        journalInstanceID = 1311,
        journalEncounterID = 2778,          
        abilities = {
            { key = "dn_echoing_maul",              label = "Echoing Maul",                     privateID = 1242869,                soundM = {"spread","file:4s" }, desc = "You're marked, an echo drops on you in 4s. Spread out so only you get hit." },
            { key = "dn_forceful_slam",             label = "Forceful Slam",                    privateID = 1297797,                soundM = nil,                            advanced = true, desc = "Nalorakk slams Zul'jarra. Stack near her to soak it, or she screams at the raid." },
            { key = "dn_spectral_slash",            label = "Spectral Slash",                   privateID = 1255577,                soundM = nil,                            advanced = true, desc = "Stacking bleed from an echo that hit you. Avoid getting clipped." },
            { key = "dn_overwhelming_onslaught",    label = "Overwhelming Onslaught",           privateID = 1297792,                soundM = nil,                            advanced = true, desc = "Heavy raid-wide burst. Get behind Zul'jarra's barrier to cut the damage." },
            { key = "dn_overwhelming_onslaught_2",  label = "Overwhelming Onslaught 2",         privateID = 1243590,                soundM = nil,                            advanced = true    }, -- possibly newer/older 
            { key = "dn_demoralizing_scream",       label = "Demoralizing Scream",              privateID = 1262253,                soundM = nil,                            advanced = true, desc = "Raid-wide hit that raises your damage taken. Intercept the slam so she doesn't scream." },
            { key = "dn_defensive_stance",          label = "Defensive Stance",                 privateID = 1261781,                soundM = nil,                            advanced = true, desc = "Zul'jarra's barrier. Stand behind her during Overwhelming Onslaught." },
        },
    },

    {
        raid    = "Den of Nalorakk",
        boss    = "Trash mob abilities",
        bossKey = "dn_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "dn_insatiable_hunger",         label = "Insatiable Hunger",                privateID = 1238801,                soundM = "debuff",                       advanced = true    },
            { key = "dn_carrying_supplies",         label = "Carrying Supplies",                privateID = 1239428,                soundM = "file:buff",                    advanced = true    },
            { key = "dn_sheltered",                 label = "Sheltered",                        privateID = 1233904,                soundM = "file:safe",                    advanced = true    },
            { key = "dn_shredding_claws",           label = "Shredding Claws",                  privateID = 1238247,                soundM = "debuff",                       advanced = true    },
            { key = "dn_razor_dive",                label = "Razor Dive",                       privateID = 1238439,                soundM = "bleed",                        advanced = true    },
            { key = "dn_glacial_tomb",              label = "Glacial Tomb",                     privateID = 1241464,                soundM = "file:stun",                    advanced = true    },
            { key = "dn_fixate",                    label = "Fixate",                           privateID = 1246882,                soundM = "fixate",                                          },
            { key = "dn_primal_echo",               label = "Primal Echo",                      privateID = 1246957,                soundM = "dot",                          advanced = true    },
            { key = "dn_cryo_surge",                label = "Cryo Surge",                       privateID = 1239860,                soundM = "spread",                                          },
            { key = "dn_feast_of_misery",           label = "Feast of Misery",                  privateID = 1238687,                soundM = "debuff",                       advanced = true    },
            { key = "dn_rotten_ground",             label = "Rotten Ground",                    privateID = 1297701,                soundM = nil,                            advanced = true    },
            { key = "dn_harsh_winter",              label = "Harsh Winter",                     privateID = 1309964,                soundM = nil,                            advanced = true    },
            { key = "dn_harsh_winds",               label = "Harsh Winds",                      privateID = 1252825,                soundM = nil,                            advanced = true    },
            { key = "dn_earthquake",                label = "Earthquake",                       privateID = 1247367,                soundM = nil,                            advanced = true    },
            { key = "dn_snowdrift_trash",           label = "Snowdrift",                        privateID = 1266193,                soundM = nil,                            advanced = true    },            
        },
    },
}