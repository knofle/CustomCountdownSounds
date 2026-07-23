-- data/m_voidscar_arena.lua

CCS_Spells_Mplus_VoidscarArena = {
    {
        raid    = "Voidscar Arena",
        boss    = "Taz'rah",
        bossKey = "va_tazrah",
        section = "Taz'rah",
        journalInstanceID = 1313,
        journalEncounterID = 2791,         
        abilities = {
            { key = "va_nether_dash",               label = "Nether Dash",                      privateID = 1222098,                soundM = "file:dash",                    desc = "An Ethereal Shade is about to dash through you in a line. Get out of the way." },
            { key = "va_nether_dash_dot",           label = "Nether Dash (dot)",                privateID = 1222103,                soundM = "file:dot",                     advanced = true, desc = "You got clipped by a dash. Shadow dot for 15s." },
            { key = "va_void_fissure",              label = "Void Fissure",                     privateID = 1296967,                soundM = nil,                            advanced = true, desc = "Void erupts under you from Dark Bloom. Move off it." },
            { key = "va_dark_rift_1",               label = "Dark Rift 1",                      privateID = 1262283,                soundM = nil,                            advanced = true    }, -- Private aura
            { key = "va_dark_rift_2",               label = "Dark Rift 2",                      privateID = 1222305,                soundM = nil,                            advanced = true    }, -- Private aura
        },
    },

    {
        raid    = "Voidscar Arena",
        boss    = "Atroxus",
        bossKey = "va_atroxus",
        section = "Atroxus",
        journalInstanceID = 1313,
        journalEncounterID = 2792,         
        abilities = {
            { key = "va_mind_numbing_poison",       label = "Mind-Numbing Poison",              privateID = 1263971,                soundM = nil,                            advanced = true,   desc = "Haste cut by 30% for 5s from Atroxus' poison pools. Get out of them." },
            { key = "va_hulking_claw",              label = "Hulking Claw",                     privateID = 1222642,                soundM = nil,                            advanced = true, desc = "Tank hit, heavy nature damage plus a dot." },
            { key = "va_toxic_aura",                label = "Toxic Aura",                       privateID = 1222692,                soundM = nil,                            advanced = true, desc = "Toxic Creeper's cloud. Stay away from the creeper." },
            { key = "va_poison_pool",               label = "Poison Pool",                      privateID = 1222484,                soundM = nil,                            advanced = true, desc = "Pool of venom on the ground. Don't stand in it." },
            { key = "va_poison_splash",             label = "Poison Splash",                    privateID = 1226031,                soundM = nil,                            advanced = true, desc = "Atroxus splashes poison and drops pools. Spread and dodge the globs." },
            { key = "va_sickening_bite",            label = "Sickening Bite",                   privateID = 1282892,                soundM = nil,                            advanced = true, desc = "Toxic Creeper bit you: 50% more nature damage taken, stacks. Kill the creeper." },
        },
    },

    {
        raid    = "Voidscar Arena",
        boss    = "Charonus",
        bossKey = "va_charonus",
        section = "Charonus",
        journalInstanceID = 1313,
        journalEncounterID = 2793,         
        abilities = {
            { key = "va_unstable_singularity",      label = "Unstable Singularity",             privateID = 1264188,                soundM = nil,                            advanced = true    },
            { key = "va_cosmic_crash",              label = "Cosmic Crash",                     privateID = 1300372,                soundM = nil,                            advanced = true, desc = "Comet lands on you, dot and knockback. Move away from others." },
            { key = "va_cosmic_crash_2",            label = "Cosmic Crash 2",                   privateID = 1227197,                soundM = nil,                            advanced = true    }, -- Private aura
            { key = "va_unstable_singularity_2",    label = "Unstable Singularity 2",           privateID = 1248130,                soundM = nil,                            advanced = true    }, -- Private aura
            { key = "va_condensed_mass",            label = "Condensed Mass",                   privateID = 1287450,                soundM = "file:mass",                    desc = "A Gravitic Orb is fixating you and stacking a slow. Kite it into an Unstable Singularity to kill it." }, -- Important one to track
            { key = "va_condensed_mass_stack",      label = "Condensed Mass (stack)",           privateID = 1263983,                soundM = nil,                            advanced = true    }, -- Maybe stacking variant
            { key = "va_void_cascade",              label = "Void Cascade",                     privateID = 1227247,                soundM = nil,                            advanced = true, desc = "Void energy shoots out from Charonus. Don't get clipped by it." },
            { key = "va_atomized",                  label = "Atomized",                         privateID = 1310026,                soundM = nil,                            advanced = true, desc = "A singularity locked you out for 15s. Nothing to do but wait to rematerialize." },
        },
    },

    {
        raid    = "Voidscar Arena",
        boss    = "Trash mob abilities",
        bossKey = "va_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "va_proof_of_mastery",          label = "Proof of Mastery",                 privateID = 1298902,                soundM = nil,                            advanced = true    }, -- Persistent kill buff
            { key = "va_dreadbellow",               label = "Dreadbellow",                      privateID = 1252406,                soundM = nil,                            advanced = true    },
            { key = "va_shred_defense",             label = "Shred Defense",                    privateID = 1233535,                soundM = nil,                            advanced = true    },
            { key = "va_melt_armor",                label = "Melt Armor",                       privateID = 1250043,                soundM = nil,                            advanced = true    },
            { key = "va_brutalize",                 label = "Brutalize",                        privateID = 1300243,                soundM = nil,                            advanced = true    },
            { key = "va_corrosive_essence",         label = "Corrosive Essence",                privateID = 1289258,                soundM = nil,                            advanced = true    },
            { key = "va_void_beam",                 label = "Void Beam",                        privateID = 1300138,                soundM = nil,                            advanced = true    },
            { key = "va_protected",                 label = "Protected",                        privateID = 1250023,                soundM = nil,                            advanced = true    },
            { key = "va_venomous_spit",             label = "Venomous Spit",                    privateID = 1249712,                soundM = nil,                            advanced = true, desc = "Spit lands on you. Move out of the pool it leaves." },
            { key = "va_null_eruption",             label = "Null Eruption",                    privateID = 1299913,                soundM = nil,                            advanced = true    },
            { key = "va_ravenous_swarm",            label = "Ravenous Swarm",                   privateID = 1234833,                soundM = nil,                            advanced = true    },
            { key = "va_savage_leap",               label = "Savage Leap",                      privateID = 1267894,                soundM = nil,                            advanced = true    },
            { key = "va_demoralizing_shout",        label = "Demoralizing Shout",               privateID = 1298899,                soundM = nil,                            advanced = true, desc = "Trash debuff, 25% less damage done for a bit." },
            { key = "va_macestorm",                 label = "Macestorm",                        privateID = 1310309,                soundM = "file:fixate",                  desc = "A trash mob is charging you and whirling for 6s. Move away from the group." },
        },
    },
}