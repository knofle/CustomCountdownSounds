-- data/m_altar_of_fangs.lua

CCS_Spells_Mplus_AltarOfFangs = {
    {
        raid    = "Altar of Fangs",
        boss    = "Rav'i",
        section = "Rav'i",
        abilities = {
            
        },
    },
        
    {
        raid    = "Altar of Fangs",
        boss    = "The Writhging Coil",
        section = "The Writhging Coil",
        abilities = {
            { key = "death_rattle",                 label = "Death Rattle",                     privateID = 1299080,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Stacking Dot. The Writhing Coil
            { key = "spiteful_bite",                label = "Spiteful Bite",                    privateID = 1300503,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- fixate 15s, if hit, spiteful venom 
            
        },
        
    },
    {
    
    raid    = "Altar of Fangs",
        boss    = "Zul'jan",
        section = "Zul'jan",
        abilities = {
            { key = "ritual_venom",                 label = "Ritual Venom",                     privateID = 1300894,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 48s dot, big nature damage boom after.
            { key = "ritual_venom_2",               label = "Ritual Venom 2",                   privateID = 1306909,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 48s dot, big nature damage boom after.

        },
    },
}



