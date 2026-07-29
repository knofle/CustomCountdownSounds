-- data/spells_mplus_algethar_academy.lua
-- Note: No private auras identified for Algeth'ar Academy yet.

CCS_Spells_Mplus_AlgetharAcademy = {
    {
        raid    = "Algeth'ar Academy",
        boss    = "Vexamus",
        section = "Vexamus",
        abilities = {
                { key = "aa_corrupted_mana",                    label = "Corrupted Mana",               privateID = 386201, soundM = nil  },
                { key = "aa_oversurge",                         label = "Oversurge",                    privateID = 391977, soundM = nil  },
        },
    },
    {
        raid    = "Algeth'ar Academy",
        boss    = "Overgrown Ancient",
        section = "Overgrown Ancient",
        abilities = {
                { key = "aa_barkbreaker",                   label = "Barkbreaker",                  privateID = 388544, soundM = nil  },
                --{ key = "aa_lasher_toxin",                  label = "Lasher Toxin",                 privateID = 389033, soundM = nil  },
                --{ key = "aa_splinterbark",                  label = "Splinterbark",                 privateID = 396716, soundM = nil  },
        },
    },
    {
        raid    = "Algeth'ar Academy",
        boss    = "Crawth",
        section = "Crawth",
        abilities = {
                { key = "aa_gale_force",                    label = "Gale Force",                   privateID = 376760, soundM = nil  },
                --{ key = "aa_savage_peck",                   label = "Savage Peck",                  privateID = 376997, soundM = nil  },
                { key = "aa_deafening_screech",             label = "Deafening Screech",            privateID = 377009, soundM = nil  },
        },
    },
    {
        raid    = "Algeth'ar Academy",
        boss    = "Echo of Doragosa",
        section = "Echo of Doragosa",
        abilities = {
                { key = "aa_wild_energy",                   label = "Wild Energy",                  privateID = 389007, soundM = nil  },
                { key = "aa_overwhelming_power",            label = "Overwhelming Power",           privateID = 389011, soundM = nil  },
        },
    },
}