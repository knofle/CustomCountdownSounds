-- data/spells_mplus_windrunner_spire.lua

CCS_Spells_Mplus_WindrunnerSpire = {
    {
        raid    = "Windrunner Spire",
        boss    = "Emberdawn",
        section = "Emberdawn",
        abilities = {
            --{ key = "ws_flaming_updraft",    label = "Flaming Updraft",    privateID = 466559,  soundM = {"drop","file:6s"}  }, --not private
        },
    },
    {
        raid    = "Windrunner Spire",
        boss    = "Derelict Duo",
        section = "Derelict Duo",
        abilities = {
            { key = "ws_splattering_spew",   label = "Splattering Spew",   privateID = 474129,  soundM = {"drop","file:4s"}    },
            { key = "ws_heaving_yank",       label = "Heaving Yank",       privateID = 472793,  soundM = {"targeted","file:7s"}  },
            --{ key = "ws_curse_of_darkness",  label = "Curse of Darkness",  privateID = 1253834, soundM = "fixate"  }, --not private
        },
    },
    {
        raid    = "Windrunner Spire",
        boss    = "Commander Kroluk",
        section = "Commander Kroluk",
        abilities = {
            --{ key = "ws_intimidating_shout", label = "Intimidating Shout", privateID = 1253054, soundM = "stack"  }, --not private
            { key = "ws_reckless_leap",      label = "Reckless Leap",           privateID = 1283247, soundM = "targeted"  },
            { key = "ws_bladestorm",         label = "Bladestorm",              privateID = 470966,  soundM = "fixate"  },
        },
    },
    {
        raid    = "Windrunner Spire",
        boss    = "The Restless Heart",
        section = "The Restless Heart",
        abilities = {
            { key = "ws_bolt_gale",          label = "Bolt Gale",               privateID = 1282911, soundM = "targeted"  },
            { key = "ws_gust_shot",          label = "Gust Shot",               privateID = 1253979, soundM = {"spread","file:6s"}  },
            { key = "ws_tempest_slash",      label = "Tempest Slash",           privateID = 472662, soundM = nil  },
        },
    },
    
}