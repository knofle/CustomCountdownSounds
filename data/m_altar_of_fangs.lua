-- data/m_altar_of_fangs.lua

CCS_Spells_Mplus_AltarOfFangs = {
    {
        raid    = "Altar of Fangs",
        boss    = "Rav'i",
        bossKey = "af_ravi",
        section = "Rav'i",
        journalInstanceID = 1322,
        journalEncounterID = 2878,
        abilities = {
            { key = "carrion_burst",                label = "Carrion Burst",                    privateID = 1307700,                soundM = "file:break",                                      desc = "Stacks while Rav'i eats. Burst her shield to stop it." },
            { key = "triple_shot",                  label = "Triple Shot",                      privateID = 1297876,                soundM = "file:spread",                                     desc = "Lands on 3 players. Spread out so you don't clip others." },
            { key = "regurgitate",                  label = "Regurgitate",                      privateID = 1296069,                soundM = nil,                             advanced = true,  desc = "Boss throws 3 globs in front of him. If you get hit you get a 25 second disease" },
        },
    },

    {
        raid    = "Altar of Fangs",
        boss    = "The Writhing Coil",
        bossKey = "af_writhing_coil",
        section = "The Writhing Coil",
        journalInstanceID = 1322,
        journalEncounterID = 2879,        
        abilities = {
            { key = "spiteful_hunt",                label = "Spiteful Hunt",                    privateID = 1300503,                soundM = "file:fixate",                                     desc = "A snake fixates you. Kite it, don't let it reach you." }, -- Fixate 15s
            { key = "toxic_atrophy",                label = "Toxic Atrophy",                    privateID = 1310974,                soundM = nil,                           advanced = true,    desc = "Interruptible. Reduces party damage done and movement speed. Stacks." },
            { key = "synchronized_venom",           label = "Synchronized Venom",               privateID = 1299189,                soundM = "file:dot",                    advanced = true,    desc = "Damage and a dot." },
            --{ key = "spiteful_venom",               label = "Spiteful Venom",                   privateID = 1305368,                soundM = "file:dot",                        advanced = true, desc = "Stacking poison from a snake that caught you. Avoid getting hit." }, -- REMOVED: Uncoiled Writhes no longer apply Spiteful Venom
            { key = "death_rattle",                 label = "Death Rattle",                     privateID = 1299080,                soundM = "file:break",                                      desc = "Ramping raid damage. Rnd run out to Uncoil the Coil with Vine Grip." }, -- Stacking dot
            { key = "corrosive_fangs",              label = "Corrosive Fangs",                  privateID = 1294845,                soundM = "file:dot",                    advanced = true    },
            { key = "vine_grip",                    label = "Vine Grip",                        privateID = {1300328,1287798,1287797},   soundM = nil,                      advanced = true,    desc = "Orweyna gives this to everyone automatically. All living players have to pull away together to Uncoil the Coil." }, -- M
        },
    },

    {
        raid    = "Altar of Fangs",
        boss    = "Zul'jan",
        bossKey = "af_zuljan",
        section = "Zul'jan",
        journalInstanceID = 1322,
        journalEncounterID = 2880,
        abilities = {
            { key = "ritual_of_the_fang",           label = "Ritual of the Fang",               privateID = 1300885,                soundM = nil,                            advanced = true, desc = "Body-block the beams to interrupt it. You'll take Ritual Venom instead of Zul'jan." },            
            { key = "ritual_venom",                 label = "Ritual Venom",                     privateID = 1300894,                soundM = nil,                            advanced = true, desc = "Bursts for big damage when it expires. Stand in a blood pool (Bloodletting) to clear it." }, -- 48s dot, big nature damage boom after
            { key = "boneslicer",                   label = "Boneslicer",                       privateID = 1301508,                soundM = nil,                            advanced = true, desc = "Axe thrown in a line. Don't stand in its path unless you need to clear Ritual Venom." },
            { key = "bloodletting",                 label = "Bloodletting",                     privateID = 1301231,                soundM = nil,                            advanced = true, desc = "Leaves blood pools. Stand in one to strip your Ritual Venom, but don't linger." }, -- Zul'jan-specific Bloodletting

        },
    },

    {
        raid    = "Altar of Fangs",
        boss    = "Trash mob abilities",
        bossKey = "af_trash",
        section = "Trash mob abilities",
        abilities = {
            { key = "septic_spatter",               label = "Septic Spatter",                   privateID = 1306232,                soundM = nil,                               advanced = true, desc = "Venomous Leech: Pool left when they die."    },
            { key = "paralyzing_shots",             label = "Paralyzing Shots",                 privateID = 1294569,                soundM = "file:debuff",                     advanced = true, desc = "Twinfang Harrower: Targets random players. Cleared by dispel or abilities that clears snares."   },
            { key = "toxic_breath",                 label = "Toxic Breath",                     privateID = 1306669,                soundM = nil,                               advanced = true, desc = "Twinfang Harrower: Channeled breath that spins."    },
            { key = "piercing_hiss",                label = "Piercing Hiss",                    privateID = 1294557,                soundM = nil,                               advanced = true, desc = "Primal Serpent: Haste reduction aoe debuff and damage on successful cast. Can be interrupted."    },          
            { key = "blood_sacrifice",              label = "Blood Sacrifice",                  privateID = 1306550,                soundM = "file:absorb",                     advanced = true, desc = "Ritual Chieftain: Heal absorb on the entire party."    },            
            { key = "envenom",                      label = "Envenom",                          privateID = 1307571,                soundM = "file:dot",                        advanced = true, desc = "High Evolutionist: Dot, can be interrupted."   },
            { key = "bloodletting_trash",           label = "Bloodletting (trash)",             privateID = 1307531,                soundM = nil,                               advanced = true, desc = "Bloodletter: Leaves blood pools."    },
            { key = "laced_edge",                   label = "Laced Edge",                       privateID = 1308518,                soundM = nil,                               advanced = true, desc = "Blade of the Altar: Nuke and short dot that applies to tank"    }, 
            { key = "infest",                       label = "Infest",                           privateID = 1308865,                soundM = {"file:infest","file:6s"},                          desc = "Ascendant Serpent: Casts on all party members. Hatchlings spawn after 6 seconds."     },
            { key = "noxious_spray",                label = "Noxious Spray",                    privateID = 1294958,                soundM = nil,                        advanced = true, desc = "Ascendant Serpent: Beam focused on the tank." },
            { key = "deadly_venom",                 label = "Deadly Venom",                     privateID = 1297422,                soundM = nil,                               advanced = true, desc = "Stepping in poison throughout the dungeon."   },                         


        },
    },
}