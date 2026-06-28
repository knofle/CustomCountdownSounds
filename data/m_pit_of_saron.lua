-- data/spells_mplus_pit_of_saron.lua

CCS_Spells_Mplus_PitOfSaron = {
    {
        raid    = "Pit of Saron",
        boss    = "Forgemaster Garfrost",
        section = "Forgemaster Garfrost",
        abilities = {
            { key = "pos_throw_saronite",       label = "Throw Saronite",       privateID = 1261286, soundM = {"drop","file:5s"}  },
            { key = "pos_orebreaker",           label = "Orebreaker",           privateID = 1261540, soundM = nil  },
            { key = "pos_saronite_sludge",      label = "Saronite Sludge",      privateID = 1261799, soundM = nil  },
        },
    },
    {
        raid    = "Pit of Saron",
        boss    = "Ick and Krick",
        section = "Ick and Krick",
        abilities = {
            { key = "pos_lumbering_fixation",   label = "Lumbering Fixation",   privateID = 1264453, soundM = "fixate"  },
            { key = "pos_shade_shift",          label = "Shade Shift",          privateID = 1264246, soundM = nil  },
            { key = "pos_blight",               label = "Blight",               privateID = 1264299, soundM = nil  },
            
        },
    },
    {
        raid    = "Pit of Saron",
        boss    = "Scourgelord Tyrannus",
        section = "Scourgelord Tyrannus",
        abilities = {
            { key = "pos_rime_blast",                   label = "Rime Blast",                   privateID = 1262772, soundM = {"break","file:7s"}  },
            { key = "pos_frostbite",                    label = "Frostbite",                    privateID = 1263716, soundM = nil  },
            { key = "pos_scourgelords_brand",           label = "Scourgelord's Brand",          privateID = 1262596, soundM = nil  },
            { key = "pos_bone_infusion",                label = "Bone Infusion",                privateID = 1276648, soundM = nil  },
            
        },
    },
    --{
    --    raid    = "Pit of Saron",
    --    boss    = "Trash",
    --    section = "Trash",
    --    abilities = {
            --{ key = "pos_plungegrip",                   label = "Plungegrip",                   privateID = 1262772, soundM = "pull"  },
            --{ key = "pos_cryoburst",                    label = "Cryoburst",                    privateID = 1259187, soundM = "spread"  }, --not private
            
    --    },
    --},
}


            