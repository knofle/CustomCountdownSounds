-- data/spells_mplus_maisara_caverns.lua

CCS_Spells_Mplus_MaisaraCaverns = {
    {
        raid    = "Maisara Caverns",
        boss    = "Muro'jin and Nekraxx",
        section = "Muro'jin and Nekraxx",
        abilities = {
            { key = "mc_barrage",         label = "Barrage",         privateID = 1260643, soundM = "targeted"  },
            { key = "mc_carrion_swoop",   label = "Carrion Swoop",   privateID = 1249478, soundM = {"charge","file:4,5s"}  },
        },
    },
    {
        raid    = "Maisara Caverns",
        boss    = "Vordaza",
        section = "Vordaza",
        abilities = {
            { key = "mc_final_pursuit",   label = "Final Pursuit",   privateID = 1251775, soundM = "fixate"  },
        },
    },
    {
        raid    = "Maisara Caverns",
        boss    = "Rak'tul, Vessel of Souls",
        section = "Rak'tul, Vessel of Souls",
        abilities = {

            { key = "mc_crush_souls",     label = "Crush Souls",     privateID = 1252675, soundM = {"targeted","file:4,5s"}  },
        },
    },
}