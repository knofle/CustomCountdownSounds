-- data/spells_mplus_magisters_terrace.lua

CCS_Spells_Mplus_MagistersTerrace = {
    {
        raid    = "Magister's Terrace",
        boss    = "Seranel Sunlash",
        section = "Seranel Sunlash",
        abilities = {
            { key = "mt_runic_mark",        label = "Runic Mark",         privateID = 1225792, soundM = "clear"  },
        },
    },
        
    {
        raid    = "Magister's Terrace",
        boss    = "Gemellus",
        section = "Gemellus",
        abilities = {
            { key = "mt_neural_link",        label = "Neural Link",       privateID = 1253709, soundM = "break"  },
            --{ key = "mt_cosmic_sting",       label = "Cosmic Sting",      privateID = 1223958, soundM = {"drop","file:ccs4s"}  }, --not private
            --{ key = "mt_astral_grasp",       label = "Astral Grasp",      privateID = 1224299, soundM = "pull"  }, --not private
        },
        
    },
    {
    
    raid    = "Magister's Terrace",
        boss    = "Degentrius",
        section = "Degentrius",
        abilities = {
            { key = "mt_unstable_void_essence",         label = "Unstable Void Essence",        privateID = 1215157, soundM = nil  },
            { key = "mt_entropy_orb",                   label = "Entropy Orb",                  privateID = 1269631, soundM = nil  },
            --{ key = "mt_devouring_entropy",  label = "Devouring Entropy", privateID = 1215897, soundM = "targeted"  }, --not private
        },
    },
}