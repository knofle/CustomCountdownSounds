-- data/r_vs_dr_mqd.lua
-- Voidspire, Dreamrift, March on Quel'Danas (12.0.x raids).
--
-- Sound field formatting:
--   soundH = "targeted"
--   soundH = {"targeted", "file:ccs7s"}    -- warning + default countdown
--
-- Available sounds
--   Registered in LSM: break, breath, burn, dot, marked, move, drop, soak, spread, targeted, fixate, stack, pull, absorb, debuff, charge, clear, knock, spikes, skull, cross, square, moon, triangle, diamond, star, circle
--   Not Registered in LSM: arrow, break_add, light_dive, void_dive, madness, rune, shield, void_quill, light_quill, miasma, madness, pools, shroomling, fungling, blue add, red add
--   Not Registered Countdowns: 2s, 2,5s up to 13s, 2sfull, 3sfull,
--
-- Difficulty: soundH = Heroic, soundM = Mythic. nil silences that diff.

local _, _, _, tocVersion = GetBuildInfo()
if tocVersion >= 120100 then return end

-- TEST: Plexus Sentinel — toggled in/out via /ccs plexus (off by default).
CCS = CCS or {}
CCS._plexusTestEntry = {
    raid    = "Manaforge Omega",
    boss    = "Plexus Sentinel",
    bossKey = "plexus_sentinel",
    section = "|cff1eff00Plexus Sentinel|r |cffaaaaaa(Test)|r",
    abilities = {
        { key = "manifest_matrices",        label = "Manifest Matrices",                privateID = 1219459,                soundH = {"file:pools", "file:6s"},         soundM = {"file:spikes", "file:6s"}                         }, -- Manifest Matrices
        { key = "eradicating_salvo",        label = "Eratidcating Salvo",               privateID = 1219607,                soundH = {"file:soak", "file:7s"},          soundM = {"file:spikes", "file:7s"},      advanced = true   }, -- Eradicating Salvo
    },
}

local entries = {

    --------------------------------------------------------------------------
    -- The Voidspire
    --------------------------------------------------------------------------

    {
        raid    = "The Voidspire",
        boss    = "Imperator Averzian",
        bossKey = "imperator_averzian",
        section = "|cffc17de8Imperator Averzian|r",
        abilities = {
            { key = "marked",                   label = "Void Marked",                      privateID = 1280023,                soundH = "file:break_add",                  soundM = "file:break_add"                                   }, -- Debuff to break adds
            { key = "weakened",                 label = "Weakened",                         privateID = 1283069,                soundH = "fixate",                          soundM = "fixate"                                           }, -- Tank (Fixate)
            { key = "umbral_collapse",          label = "Umbral Collapse",                  privateID = { 1260203, 1249265 },   soundH = "soak",                            soundM = "soak"                                             }, -- Tank (Soak)
            { key = "gnashing_void",            label = "Gnashing Void",                    privateID = 1255680,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Voidmaw bleed
            { key = "lingering_darkness",       label = "Lingering Darkness",               privateID = 1280075,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- After Void Marked removal
            { key = "march_of_the_endless",     label = "March of the Endless",             privateID = 1260981,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Wipe condition
            { key = "blackening_wounds",        label = "Blackening Wounds",                privateID = 1265540,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Tank debuff
        },
    },

    {
        raid    = "The Voidspire",
        boss    = "Vorasius",
        bossKey = "vorasius",
        section = "|cffc17de8Vorasius|r",
        abilities = {
            { key = "vorasius_fixate",          label = "Fixate",                           privateID = 1254113,                soundH = "fixate",                          soundM = "fixate"                                           }, -- Vorasius Fixate
            { key = "creep_spit",               label = "Creep Spit",                       privateID = 1272527,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Spit debuff
            { key = "dark_goo",                 label = "Dark Goo",                         privateID = { 1243220,1243270 },    soundH = nil,                               soundM = nil,                            advanced = true    }, -- Puddle debuff
            { key = "smashed",                  label = "Smashed",                          privateID = 1241844,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Slam debuff
        },
    },

    {
        raid    = "The Voidspire",
        boss    = "Fallen-King Salhadaar",
        bossKey = "fallen_king_salhadaar",
        section = "|cffc17de8Fallen-King Salhadaar|r",
        abilities = {
            { key = "despotic_command",         label = "Despotic Command",                 privateID = 1248697,                soundH = {"drop","file:11s"},               soundM = {"drop","file:12s"},                               }, -- Puddles
            { key = "shattering_twilight",      label = "Shattering Twilight",              privateID = 1268992,                soundH = {"file:spikes","file:10s"},        soundM = {"file:spikes","file:9s"},                         }, -- Spikes
            { key = "shattering_tank",          label = "Shattering Twilight (Tank)",       privateID = 1253024,                soundH = {"file:spikes","file:5s"},         soundM = {"file:spikes","file:5s"},                         }, -- Spikes (Tank)
            { key = "void_exposure",            label = "Void Exposure",                    privateID = 1250828,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "dark_radiation",           label = "Dark Radiation",                   privateID = 1250991,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "void_infusion",            label = "Void Infusion",                    privateID = 1245960,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "torturous_extract",        label = "Torturous Extract",                privateID = 1245592,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "umbral_beams",             label = "Umbral Beams",                     privateID = 1260030,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "twilight_spikes",          label = "Twilight Spikes",                  privateID = 1251213,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "oppressive_darkness",      label = "Oppressive Darkness",              privateID = 1248709,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "twisting_obscurity",       label = "Twisting Obscurity",               privateID = 1250686,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "The Voidspire",
        boss    = "Vaelgor & Ezzorak",
        bossKey = "vaelgor_ezzorak",
        section = "|cffc17de8Vaelgor & Ezzorak|r",
        abilities = {
            { key = "breath",                   label = "Dread Breath",                     privateID = 1255612,                soundH = {"breath","file:7s"},              soundM = {"breath","file:6s"},                              }, -- Fear Breath
            { key = "shadowmark",               label = "Shadowmark",                       privateID = 1270497,                soundH = "spread",                          soundM = "spread"                                           }, -- P2 add damage circles
            { key = "nullzone",                 label = "Nullzone",                         privateID = 1244672,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "nullzone_implosion",       label = "Nullzone Implosion",               privateID = 1252157,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "gloomtouched",             label = "Gloomtouched",                     privateID = 1245554,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "diminish",                 label = "Diminish",                         privateID = 1270852,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "gloomfield",               label = "Gloomfield",                       privateID = 1245421,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "voidbolt_debuff",          label = "Voidbolt",                         privateID = 1245175,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "impale_debuff",            label = "Impale",                           privateID = 1265152,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "radiant_barrier",          label = "Radiant Barrier",                  privateID = 1249595,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "The Voidspire",
        boss    = "Lightblinded Vanguard",
        bossKey = "lightblinded_vanguard",
        section = "|cffc17de8Lightblinded Vanguard|r",
        abilities = {
            { key = "avengers_shield",          label = "Avenger's Shield",                     privateID = 1246487,                soundH = {"spread","file:6s"},              soundM = {"spread","file:6s"},                              }, -- Dispell debuff
            { key = "execution_sentence",       label = "Execution Sentence",                   privateID = 1248994,                soundH = {"soak","file:10s"},               soundM = {"soak","file:10s"},                               }, -- AoE Soaks
            { key = "tyrs_wrath",               label = "Tyr's Wrath",                          privateID = 1248721,                soundH = "absorb",                          soundM = "absorb",                                          }, -- Absorb Shield
            { key = "divine_consecration",      label = "Divine Consecration",                  privateID = 1276982,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "execution_sentence_dot",   label = "Execution Sentence (DoT)",             privateID = { 1249008,1249024 },    soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "divine_tempest",           label = "Divine Tempest",                       privateID = 1272324,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "judgment_final_verdict",   label = "Judgment (Final Verdict)",             privateID = 1246736,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "judgment_shield",          label = "Judgment (Shield of the Righteous)",   privateID = 1251857,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "divine_toll",              label = "Divine Toll",                          privateID = 1248652,                soundH = nil,                               soundM = nil,                            advanced = true    },
        },
    },

    {
        raid    = "The Voidspire",
        boss    = "Crown of the Cosmos",
        bossKey = "crown_of_the_cosmos",
        section = "|cffc17de8Crown of the Cosmos|r",
        abilities = {
            { key = "silverstrike_arrow",       label = "Silverstrike Arrow",               privateID = 1233602,                        soundH = {"file:arrow","file:6s"},      soundM = {"file:arrow","file:6s"} ,                     }, -- P1 arrow
            { key = "grasp_of_emptiness",       label = "Grasp of Emptiness",               privateID = { H = 1232470, M = 1260027 },   soundH = {"file:spikes","file:8s"},     soundM = {"file:spikes","file:10s"},                    }, -- Spikes/Obelisks (H/M differ)
            { key = "void_expulsion",           label = "Void Expulsion",                   privateID = 1283236,                        soundH = {"drop","file:6s"},            soundM = {"drop","file:6s"},                            }, -- Puddles
            { key = "ranger_mark_alt",          label = "Ranger Captain's Mark",            privateID = { H = 1237623, M = 1259861 },   soundH = {"file:arrow","file:6s"},      soundM = {"file:arrow","file:6s"},                      }, -- P2 arrow (H/M differ)
            { key = "aspect_of_the_end",        label = "Aspect of the End",                privateID = 1239111,                        soundH = "break",                       soundM = "break"                                        }, -- Break circles
            { key = "dark_rush",                label = "Dark Rush",                        privateID = 1238708,                        soundH = "file:feather",                soundM = "file:feather"                                 }, -- Feather buff
            { key = "silverstrike_barrage",     label = "Silverstrike Barrage",             privateID = 1243981,                        soundH = nil,                           soundM = nil,                        advanced = true    }, -- 1st intermission arrows
            { key = "void_remnants",            label = "Void Remnants",                    privateID = 1242553,                        soundH = nil,                           soundM = nil,                        advanced = true    },
            { key = "ravenous_abyss",           label = "Ravenous Abyss",                   privateID = 1243753,                        soundH = nil,                           soundM = nil,                        advanced = true    },
            { key = "stellar_emission",         label = "Stellar Emission",                 privateID = 1234570,                        soundH = nil,                           soundM = nil,                        advanced = true    },
            { key = "rift_slash",               label = "Rift Slash",                       privateID = 1246462,                        soundH = nil,                           soundM = nil,                        advanced = true    },
            { key = "volatile_fissure",         label = "Volatile Fissure",                 privateID = 1238206,                        soundH = nil,                           soundM = nil,                        advanced = true    },
            { key = "voidstalker_sting",        label = "Voidstalker Sting",                privateID = 1237038,                        soundH = nil,                           soundM = nil,                        advanced = true    },
            { key = "devouring_cosmos",         label = "Devouring Cosmos",                 privateID = 1227557,                        soundH = nil,                           soundM = nil,                        advanced = true    },
            { key = "gravity_collapse",         label = "Gravity Collapse",                 privateID = 1255453,                        soundH = nil,                           soundM = nil,                        advanced = true    },
        },
    },
    
    --------------------------------------------------------------------------
    -- The Dreamrift
    --------------------------------------------------------------------------

    {
        raid    = "The Dreamrift",
        boss    = "Chimaerus the Undreamt God",
        bossKey = "chimaerus",
        section = "|cff6aacdcChimaerus the Undreamt God|r",
        abilities = {
            { key = "rift_madness",             label = "Rift Madness",                     privateID = 1264756,        soundH = "file:madness",                      soundM = {"file:madness","file:5s"}                               }, -- Rift Madness
            { key = "consuming_miasma",         label = "Consuming Miasma",                 privateID = 1257087,        soundH = "file:miasma",                       soundM = "file:miasma"                                            }, -- Puddle dispell debuff
            { key = "alnsight",                 label = "Alnsight",                         privateID = 1245698,        soundH = nil,                                 soundM = nil,                                 advanced = true     },
            { key = "lingering_miasma",         label = "Lingering Miasma",                 privateID = 1258192,        soundH = nil,                                 soundM = nil,                                 advanced = true     },
            { key = "caustic_phlegm",           label = "Caustic Phlegm",                   privateID = 1246653,        soundH = nil,                                 soundM = nil,                                 advanced = true     },
        },
    },
    --------------------------------------------------------------------------
    -- March on Quel'Danas
    --------------------------------------------------------------------------

    {
        raid    = "March on Quel'Danas",
        boss    = "Belo'ren, Child of Al'ar",
        bossKey = "belo_ren",
        section = "|cff6fcf6fBelo'ren, Child of Al'ar|r",
        abilities = {
            { key = "void_dive",                label = "Void Dive",                        privateID = 1241339,        soundH = {"file:void_dive", "file:8s"},       soundM = {"file:void_dive", "file:8s"},                           }, -- Void Soak
            { key = "light_dive",               label = "Light Dive",                       privateID = 1241292,        soundH = {"file:light_dive", "file:8s"},      soundM = {"file:light_dive", "file:8s"},                          }, -- Light Soak
            { key = "light_quill",              label = "Light Quill",                      privateID = 1241992,        soundH = {"file:light_quill","file:6s"},      soundM = {"file:light_quill","file:6s"},                          }, -- Light Quill
            { key = "void_quill",               label = "Void Quill",                       privateID = 1242091,        soundH = {"file:void_quill","file:6s"},       soundM = {"file:void_quill","file:6s"},                           }, -- Void Quill
            { key = "light_patch",              label = "Light Patch",                      privateID = 1241840,        soundH = nil,                                 soundM = nil,                                 advanced = true     }, -- Light Patch
            { key = "void_patch",               label = "Void Patch",                       privateID = 1241841,        soundH = nil,                                 soundM = nil,                                 advanced = true     }, -- Void Patch
            { key = "light_burn",               label = "Light Burn",                       privateID = 1244348,        soundH = nil,                                 soundM = nil,                                 advanced = true     }, -- Light Burn (absorb)
            { key = "void_burn",                label = "Void Burn",                        privateID = 1266404,        soundH = nil,                                 soundM = nil,                                 advanced = true     }, -- Void Burn (absorb)
            { key = "light_flames",             label = "Light Flames",                     privateID = 1242803,        soundH = nil,                                 soundM = nil,                                 advanced = true     }, -- Light Flames (Incubation)
            { key = "void_flames",              label = "Void Flames",                      privateID = 1242815,        soundH = nil,                                 soundM = nil,                                 advanced = true     }, -- Void Flames (Incubation)
        },
    },

    {
        raid    = "March on Quel'Danas",
        boss    = "Midnight Falls",
        bossKey = "midnight_falls",
        section = "|cff6fcf6fMidnight Falls|r",
        abilities = {
            { key = "dark_rune",                label = "Dark Rune",                        privateID = 1249609,                soundH = {"file:rune","file:10s"},    soundM = {"file:rune","file:10s"}                                 }, -- Dark Rune, indiscriminate of which
            { key = "starsplinter",             label = "Starsplinter",                     privateID = { 1279512, 1285510 },   soundH = {nil,"file:4s"},             soundM = {nil,"file:3sfull"}                                      }, -- Spikes, intermission
            { key = "criticality",              label = "Criticality",                      privateID = 1281184,                soundH = {nil,nil},                   soundM = {nil,"file:4s"}                                          }, -- P2 spread circles (mythic)
            { key = "galvanize",                label = "Galvanize",                        privateID = 1284527,                soundH = {"targeted","file:7s"},      soundM = {"targeted","file:6s"}                                   }, -- P2 beam
            { key = "glimmering",               label = "Glimmering",                       privateID = 1253031,                soundH = "file:crystal",              soundM = "file:crystal",                                          },        
            { key = "grim_symphony_blue",       label = "Grim Symphony (Blue)",             privateID = 1284984,                soundH = "file:blue",                 soundM = "file:blue"                                              }, -- Grim Symphony Blue
            { key = "grim_symphony_red",        label = "Grim Symphony (Red)",              privateID = 1286294,                soundH = "file:red",                  soundM = "file:red"                                               }, -- Grim Symphony Red
            { key = "the_darkwell",             label = "The Darkwell",                     privateID = 1282027,                soundH = nil,                         soundM = nil,                                 advanced = true     },
            { key = "dark_quasar",              label = "Dark Quasar",                      privateID = 1282470,                soundH = nil,                         soundM = nil,                                 advanced = true     },
            { key = "impaled_mf",               label = "Impaled",                          privateID = 1265842,                soundH = nil,                         soundM = nil,                                 advanced = true     },
            { key = "midnight_debuff",          label = "Midnight",                         privateID = 1263514,                soundH = nil,                         soundM = nil,                                 advanced = true     },
        },
    },
  
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid[#CCS_Spells_Raid + 1] = e
end