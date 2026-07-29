-- data/spells_mplus_seat_of_the_triumvirate.lua

CCS_Spells_Mplus_SeatOfTheTriumvirate = {
    
    {
        raid    = "Seat of the Triumvirate",
        boss    = "Zuraal the Ascended",
        section = "Zuraal the Ascended",
        abilities = {
            { key = "sot_void_sludge",       label = "Void Sludge",        privateID = 244588, soundM = nil  },
            { key = "sot_dark_expulsion",    label = "Dark Expulsion",     privateID = 244599, soundM = nil  },
        },
    },
    {
        raid    = "Seat of the Triumvirate",
        boss    = "Saprish",
        section = "Saprish",
        abilities = {
            { key = "sot_phase_dash",       label = "Phase Dash",        privateID = 1280064, soundM = {"spread","file:6s"}  },
            --{ key = "sot_shadow_pounce",    label = "Shadow Pounce",     privateID = 245742, soundM = nil  },
            { key = "sot_void_bomb",        label = "Void Bomb",         privateID = 246026, soundM = nil  },
            --{ key = "sot_overload",         label = "Overload",          privateID = 1263523, soundM = nil  },
        },
    },
    {
        raid    = "Seat of the Triumvirate",
        boss    = "Viceroy Nezhar",
        section = "Viceroy Nezhar",
        abilities = {
            { key = "sot_void_storm",               label = "Void Storm",               privateID = 1263532, soundM = nil  },
            { key = "sot_mass_void_infusion",       label = "Mass Void Infusion",       privateID = 1263542, soundM = nil  },
            { key = "sot_mind_flay",                label = "Mind Flay",                privateID = 1268733, soundM = nil  },
        },
    },
    {
        raid    = "Seat of the Triumvirate",
        boss    = "L'ura",
        section = "L'ura",
        abilities = {
            { key = "sot_discordant_beam",  label = "Discordant Beam",  privateID = 1265426, soundM = {"break","file:7,5s"}  },
            --{ key = "sot_anguish",          label = "Anguish",          privateID = 1265650, soundM = nil  },
        },
    }, 
    --{
    --    raid    = "Seat of the Triumvirate",
    --    boss    = "Trash",
    --    section = "Trash",
    --    abilities = {
    --        --{ key = "sot_chains_of_subjugation",    label = "Chains of Subjugation",    privateID = 1262509, soundM = "spread"  }, --not private
    --        --{ key = "sot_backstab",                 label = "Backstab",                 privateID = 1262519, soundM = nil  }, --not private
    --        --{ key = "sot_eruption",                 label = "Eruption",                 privateID = 1262441, soundM = "spread"  }, --not private
    --    },
    --},
}