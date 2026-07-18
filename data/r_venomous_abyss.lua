-- data/r_venomous_abyss.lua
-- The Venomous Abyss (12.1.0 raid).

local _, _, _, tocVersion = GetBuildInfo()
if tocVersion < 120100 then return end

local entries = {
    {
        raid    = "The Venomous Abyss",
        boss    = "Nek'zali the Soulcoiler",
        bossKey = "nekzali_the_soulcoiler",
        section = "|cffae3df5Nek'zali the Soulcoiler|r",
        journalInstanceID = 1320,
        journalEncounterID = 2888,
        abilities = {
            { key = "hungering_pyre",               label = "Hungering Pyre",               privateID = 1306666,                soundH = {"soak","file:7,5s"},              soundM = {"soak","file:7,5s"}, desc = "Big stack. Get in and share it, it clears the adds." }, -- Big stack, clears adds. Share
            { key = "cremation",                    label = "Cremation",                    privateID = 1289875,                soundH = "spread",                          soundM = "spread", desc = "Goes off around whoever stacked for the Pyre. Spread out." }, -- Aoe around people who stacked.            
            { key = "essence_rend",                 label = "Essence Rend",                 privateID = 1287434,                soundH = {"drop","file:5s"},                soundM = {"drop","file:5s"}, desc = "Leaves a Latent Cultist where it expires. Drop it away from the group." },            
            { key = "slithering_flame",             label = "Slithering Flame",             privateID = 1294933,                soundH = "clear",                           soundM = "clear", desc = "Lands on whoever didn't stack for the Pyre." }, -- Goes on whoever didn't stack.            
            { key = "hollowed",                     label = "Hollowed",                     privateID = 1284109,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Tank stacks from Sever. Cuts your healing received." }, -- Dot, healing nerfed. On tank Stacks
            { key = "soulcoil_rite",                label = "Soulcoil Rite",                privateID = 1288772,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Stacks every time a soul reaches the well. Stop the Amani to stop it." }, -- Dot, stacks when spirits are consumed
            { key = "corpse_blight",                label = "Corpse Blight",                privateID = 1307939,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "20s dot after the Amani die. Just heal through it." }, -- 20 second dot after amani die.
            { key = "ritual_burn",                  label = "Ritual Burn",                  privateID = 1297624,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Raises your Soulcoil Rite damage taken for a minute." }, -- Increased damage from soulcoil rite, 1m. 
            { key = "residual_toll",                label = "Residual Toll",                privateID = 1298698,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Turns into Hollowed after 12s." }, -- Dot, gives them hollowed after 12s
            { key = "soulcoil_well",                label = "Soulcoil Well",                privateID = 1285623,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "latent_cultist",               label = "Latent Cultist",               privateID = 1288554,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "possession_barrage",           label = "Possession Barrage",           privateID = 1284103,                soundH = nil,                               soundM = nil,                            advanced = true    },

        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Entombed Sentinels",
        bossKey = "entombed_sentinels",
        section = "|cffae3df5Entombed Sentinels|r",
        journalInstanceID = 1320,
        journalEncounterID = 2874,
        abilities = {
            { key = "unstable_miasma",          label = "Unstable Miasma",              privateID = 1288260,                soundH = {"stack","file:8s"},               soundM = {"stack","file:8s"}, desc = "Erupts in 8s and splits between everyone within 5 yards. Stack up, don't take it alone." }, -- Upon expiration, damage split players 5 yards.
            { key = "clinging_murk",            label = "Clinging Murk",                privateID = 1288297,                soundH = {"drop","file:6s"},                soundM = {"drop","file:6s"},                                desc = "Blood venom split off a Miasma that hit you. Drops a pool where it expires." },
            { key = "helical_toxins",           label = "Helical Toxins",               privateID = 1284590,                soundH = "clear",                           soundM = "clear", desc = "Run into other infected players to reach exactly 4 stacks. Exactly 4 neutralizes it, anything else and it bursts." }, -- Run into people, stack to exactly 4.    
            { key = "mark_of_acid",             label = "Mark of Acid",                 privateID = 1284500,                soundH = "file:acid",                       soundM = "file:acid",                    advanced = true, desc = "Breath's mark, applied to anyone within 40 yards. Stacks." },
            { key = "mark_of_blood",            label = "Mark of Blood",                privateID = 1284506,                soundH = "file:blood",                      soundM = "file:blood",                   advanced = true, desc = "Blood's mark, applied to anyone within 40 yards. Stacks." },            
            { key = "shifting_protovenom",      label = "Shifting Protovenom",          privateID = 1296880,                soundH = "clear",                           soundM = "clear",                        advanced = true, desc = "Run into another Protovenom player to neutralize it. Touching a clean player erupts on them instead." }, -- Hit other protovenoms, colliding - Protovenom Eruption                                             
            { key = "blood_venom",              label = "Blood Venom",                  privateID = 1284210,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Drops a toxic pool where it expires. More stacks means a bigger pool." }, -- Puddle damage
            { key = "blighted_blood",           label = "Blighted Blood",               privateID = 1284471,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Dispel it. If it runs the full 18s it turns into Blood Venom." }, -- 18s Magic Dot
            { key = "debilitating_miasma",      label = "Debilitating Miasma",          privateID = 1284477,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Slows you, and moving burns the stacks off. Keep moving." }, -- 10s dot, movement decrease, movement reduces stacks.
            { key = "bloodvenom_injection",     label = "Bloodvenom Injection",         privateID = 1284491,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Tank stack, each hit on the same target hits harder." }, -- Stacking dot on target (tank)
            { key = "cultivated_burst",         label = "Cultivated Burst",             privateID = 1284947,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "You didn't reach 4 stacks of Helical Toxins in time. Big hit plus a 1 minute dot." }, -- Big dot if full duration of helical toxin.
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Lost Explorers",
        bossKey = "the_lost_explorers",
        section = "|cffae3df5The Lost Explorers|r",
        journalInstanceID = 1320,
        journalEncounterID = 2894,        
        abilities = {
            { key = "steady_strikes",               label = "Steady Strikes",               privateID = 1291929,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Tank stacks, each hit hurts more. Swap when it gets high." },
            { key = "splinters",                    label = "Splinters",                    privateID = 1308853,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "shredding_shards",             label = "Shredding Shards",             privateID = 1295858,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Tank debuff, each shard raises your magic damage taken. Swap when it gets high." },
            { key = "mighty_thud",                  label = "Mighty Thud",                  privateID = 1296092,                soundH = "targeted",                        soundM = "targeted",                                        desc = "Nama leaps to you. Stack with others to split it, if he misses everyone the raid eats it." },
            { key = "shell_spin",                   label = "Shell Spin",                   privateID = 1291918,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Stunned by a shell. Dodge them next time." },
            { key = "burning_flames",               label = "Burning Flames",               privateID = 1295928,                soundH = "file:fire",                    soundM = "file:fire",                                    desc = "Fire dot until a frost effect clears it. Go find frost, but it explodes on the raid when they cancel." },
            { key = "piercing_frost",               label = "Piercing Frost",               privateID = 1295954,                soundH = "file:frost",                      soundM = "file:frost",                                      desc = "Frost dot and heavy slow until a fire effect clears it. Go find fire, but it explodes on the raid when they cancel." },
            { key = "frostfire_volley_fire",        label = "Frostfire Volley (Fire)",      privateID = 1295886,                soundH = "file:fire_volley",                       soundM = "file:fire_volley",                                       desc = "Fire volley. Pair up with a frost player to cancel it." },
            { key = "frostfire_volley_frost",       label = "Frostfire Volley (Frost)",     privateID = 1295935,                soundH = "file:frost_volley",                      soundM = "file:frost_volley",                                      desc = "Frost volley. Pair up with a fire player to cancel it." },
            { key = "frost_patch",                  label = "Frost Patch",                  privateID = 1297648,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Frost on the ground. Gives you Piercing Frost, but clears Burning Flames." },
            { key = "explosive_surprise",           label = "Explosive Surprise",           privateID = 1297625,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Gebbo's bomb knocks you high into the air." },
            { key = "bounce",                       label = "Bounce",                       privateID = 1299854,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "fire_patch",                   label = "Fire Patch",                   privateID = 1297649,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Fire on the ground. Gives you Burning Flames, but clears Piercing Frost." },
            { key = "blast_wave",                   label = "Blast Wave",                   privateID = 1305844,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "You got clipped by the shockwave. Don't stand in its path." },
            { key = "icebound_flames",              label = "Icebound Flames",              privateID = 1286922,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Heavy dot and slow. Dispellable, ask for a cleanse." },
            { key = "spooky_mask",                  label = "Spooky Mask",                  privateID = 1310032,                soundH = "file:buff",                       soundM = "file:buff",                                       },
            -- No confirmed aura IDs yet (never landed on PTR). Journal IDs below are
            -- likely cast IDs, so verify against logs before enabling.
            --{ key = "fungal_burst",                 label = "Fungal Burst",                 privateID = 1292292,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Huge hit plus a 10s dot from a mushroom." },
            --{ key = "concussive_blast",             label = "Concussive Blast",             privateID = 1296247,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Knockback plus a 12s fire dot from Gebbo's bomb." },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Vashnik the Malignant",
        bossKey = "vashnik_the_malignant",
        section = "|cffae3df5Vashnik the Malignant|r",
        journalInstanceID = 1320,
        journalEncounterID = 2882,        
        abilities = {
            --{ key = "plague_froth_incubate",        label = "Plague Froth (incubate)",      privateID = 1281910,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 2s incubate
            --{ key = "plague_froth_dot",             label = "Plague Froth (dot)",           privateID = 1281908,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- 6s dot
            --{ key = "plague_froth_untooltipped",    label = "Plague Froth (untooltipped)",  privateID = 1282078,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- No tooltip
            { key = "plague_froth_mythic",          label = "Plague Froth",                 privateID = {1281908, 1281913},     soundH = {"spread","file:6s"},              soundM = {"spread","file:6s"}, desc = "Waves erupt from you in cardinal directions when it drops. Get away from the group, and on Mythic aim them at the Malignant Tumors to strip Hardened Tumor." }, -- Mythic?
            { key = "exploding_infection",          label = "Exploding Infection",          privateID = 1295173,                soundH = {"file:exploding","file:10s"},     soundM = {"file:exploding","file:10s"}, desc = "Fire fountain infection. Explodes on the whole raid when it drops, damage falls off with distance, so get as far out as you can." },
            { key = "siphoning_infection",          label = "Siphoning Infection",          privateID = 1295224,                soundH = "file:siphon",                     soundM = "file:siphon",                                     desc = "You can't be healed for 15s. Stay near allies so Siphon Blood keeps you alive." },
            { key = "being_siphoned",               label = "Being Siphoned",               privateID = 1295380,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "An infected player near you is draining your health." },
            { key = "stygian_infection",            label = "Stygian Infection",            privateID = 1294994,                soundH = "drop",                            soundM = "drop", desc = "Shadow fountain infection. Bursts erupt under your feet and hit anyone within 3 yards. Keep away from the group." },
            { key = "clotting_blood",               label = "Clotting Blood",               privateID = 1302517,                soundH = "absorb",                          soundM = "absorb",                       advanced = true, desc = "Absorb shield." },                                                
            { key = "congealing_bolt",              label = "Congealing Bolt",              privateID = 1305833,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Shadow venom from the Shrouded Venoms. Stacking slow." },
            { key = "dripping_fangs",               label = "Dripping Fangs",               privateID = 1280934,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Tank bite. Doubles your physical damage taken for 32s, swap it off." },
            { key = "caustic_surge",                label = "Caustic Surge",                privateID = 1285979,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Burn from a Burning Venom dying. Just heal through it." },
            { key = "virulent_fumes",               label = "Virulent Fumes",               privateID = 1291461,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Just heal through it." },
            { key = "adaptive_infection",           label = "Adaptive Infection",           privateID = 1282117,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Vashnik picks your infection based on which fountains are feeding him." },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Sszorak",
        bossKey = "sszorak",
        section = "|cffae3df5Sszorak|r",
        journalInstanceID = 1320,
        journalEncounterID = 2871,        
        abilities = {
            { key = "corroding_venom",              label = "Corroding Venom",              privateID = 1282873,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "mutilate",                     label = "Mutilate",                     privateID = 1277051,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "tempest",                      label = "Tempest",                      privateID = 1287083,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "venomous_surge",               label = "Venomous Surge",               privateID = 1305963,                soundH = {"file:surge","file:10s"}, soundM = {"file:surge","file:10s"},               desc = "Bursts on the whole raid when it expires and leaves a cyst behind. Get away from everyone." },
            { key = "serpents_fury",                label = "Serpent's Fury",               privateID = 1305621,                soundH = "file:serpents_fury",              soundM = "file:serpents_fury",                              desc = "You're marked. Sszorak charges you once enough players stack near you." },
            { key = "virulence_1",                  label = "Virulence 1",                  privateID = 1297707,                soundH = {"file:virulence","file:5s"},      soundM = {"file:virulence","file:5s"},                      desc = "Bursts when it drops and spreads to anyone nearby. Get away from the group." },
            { key = "virulence_2",                  label = "Virulence 2",                  privateID = 1299899,                soundH = {"file:virulence","file:5s"},      soundM = {"file:virulence","file:5s"},                      desc = "Bursts when it drops and spreads to anyone nearby. Get away from the group." },
            { key = "raging_crosswinds_north",      label = "Raging Crosswinds (North)",    privateID = 1285425,                soundH = {"file:winds","file:8s"},          soundM = {"file:winds","file:8s"},                          desc = "Blows you north when it expires. Collide with the player blown south to cancel it out." },
            { key = "raging_crosswinds_east",       label = "Raging Crosswinds (East)",     privateID = 1297096,                soundH = {"file:winds","file:8s"},          soundM = {"file:winds","file:8s"},                          desc = "Blows you east when it expires. Collide with the player blown west to cancel it out." },
            { key = "raging_crosswinds_south",      label = "Raging Crosswinds (South)",    privateID = 1285453,                soundH = {"file:winds","file:8s"},          soundM = {"file:winds","file:8s"},                          desc = "Blows you south when it expires. Collide with the player blown north to cancel it out." },
            { key = "raging_crosswinds_west",       label = "Raging Crosswinds (West)",     privateID = 1297111,                soundH = {"file:winds","file:8s"},          soundM = {"file:winds","file:8s"},                          desc = "Blows you west when it expires. Collide with the player blown east to cancel it out." },
            { key = "caustic_residue",              label = "Caustic Residue",              privateID = 1296667,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Pool on the ground that raises your damage taken. Get out of it." },
            { key = "viscous_cyst",                 label = "Viscous Cyst",                 privateID = 1287205,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "turbulent_gusts",              label = "Turbulent Gusts",              privateID = 1285447,                soundH = nil,                               soundM = nil,                            advanced = true, desc = "Floating after the winds. Touch the player blown from the opposite side to drop." },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Twin Fangs",
        bossKey = "the_twin_fangs",
        section = "|cffae3df5The Twin Fangs|r",
        journalInstanceID = 1320,
        journalEncounterID = 2887,        
        abilities = {
            { key = "eternal_venom",                label = "Eternal Venom",                privateID = 1290336,                soundH = "file:venom",                      soundM = "file:venom",                   advanced = true,   desc = "Stacks from almost everything. At 5 stacks you die. Get hit by Ravenous Feast to eat a stack off." },
            { key = "coiling_ichor",                label = "Coiling Ichor",                privateID = 1290814,                soundH = {"file:drop","file:12s"},          soundM = {"file:drop","file:12s"},                          desc = "Tightens on you, then spreads Eternal Venom to anyone within 4 yards. Run out and drop it away from the group." },
            { key = "fractured",                    label = "Fractured",                    privateID = 1289092,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Raises your Stone Breaker damage taken. Stacks." },
            { key = "corrosive_spit",               label = "Corrosive Spit",               privateID = 1293979,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Spit from a Spawn of Vexhul. Applies Eternal Venom." },
            { key = "caustic_deluge",               label = "Caustic Deluge",               privateID = 1289192,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Tank only. Globs erupt off you for 5s, each one hands Eternal Venom to players within 4 yards." },
            { key = "congealed_gore_1",             label = "Congealed Gore 1",             privateID = 1306925,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Gore pool from Barrage. Heavy slow, get out of it." },
            { key = "congealed_gore_2",             label = "Congealed Gore 2",             privateID = 1292552,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Gore pool from Barrage. Heavy slow, get out of it." },
            { key = "tf_deadly_venom",              label = "Deadly Venom",                 privateID = 1297338,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "stir_the_depths",              label = "Stir the Depths",              privateID = 1292807,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Waves roll across the platform and apply Eternal Venom. Stay out of them." },
            { key = "noxious_slick",                label = "Noxious Slick",                privateID = 1309471,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Slick left behind by Coiling Ichor. Heavy slow, get out of it." },
            { key = "vile_flood",                   label = "Vile Flood",                   privateID = 1294605,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Vexhul's 14s gout of venom. Anything it hits gets Eternal Venom, stay out of it." },
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "The Coiled Altar",
        bossKey = "the_bargained_crown",
        section = "|cffae3df5The Coiled Altar|r",
        journalInstanceID = 1320,
        journalEncounterID = 2883,        
        abilities = {
            { key = "twinfang_toxin",               label = "Twinfang Toxin",               privateID = 1283345,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Tank Debuff, expires into Twinfang Rupture
            { key = "axegrinder",                   label = "Axegrinder",                   privateID = 1285017,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot when in an axe
            { key = "dreadmarch",                   label = "Dreadmarch",                   privateID = {1285640,1285647,1297445}, soundH = "file:dreadmarch",              soundM = "file:dreadmarch",                                 desc = "You're possessed and walking off the edge. The raid has to break your absorb shield to stop it." },
            { key = "unnerving_fixation",           label = "Unnerving Fixation",           privateID = 1285911,                soundH = "fixate",                          soundM = "fixate",                                          desc = "A Manifestation is stalking you. Stare at it to hold it still, it only moves when you look away." },
            { key = "shadowfang",                   label = "Shadowfang",                   privateID = 1286326,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},                              }, -- Axe Marks, 15 yard explode after 5s
            { key = "wail_of_terror",               label = "Wail of Terror",               privateID = 1286399,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Fear for 5s
            { key = "gloombomb",                    label = "Gloombomb",                    privateID = 1286901,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},           advanced = true    }, -- Bomb marks, 15 yard damage after 5s. Also Gravebound.
            { key = "defilement_of_the_crucible",   label = "Defilement of the Crucible",   privateID = 1298594,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Heal Absorb, auto attack to apply toxin
            { key = "blighted_toxin",               label = "Blighted Toxin",               privateID = 1287227,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Statue venom, ticks on anyone within 5 yards of you for 15s. Don't park it on the group." },
            { key = "spirit_erasure",               label = "Spirit Erasure",               privateID = 1300665,                soundH = {"debuff","file:4s"},              soundM = {"debuff","file:4s"},           advanced = true    }, -- Soak, increasing on stacks, 4 sec dur
            { key = "soul_sever",                   label = "Soul Sever",                   privateID = 1307959,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "sever",                        label = "Sever",                        privateID = 1301690,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "gravebound",                   label = "Gravebound",                   privateID = 1286837,                soundH = "file:gravebound",                 soundM = "file:gravebound",                                 desc = "You die in 11 seconds. Step on your Soul Fragments to clear a stack each." },
            { key = "volatile_venom",               label = "Volatile Venom",               privateID = 1282419,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},                              desc = "Stuck to you for 5s, hurts anyone within 5 yards and drops a new venom globule where you are. Move away and place it." },
            { key = "mutagenic_venom",              label = "Mutagenic Venom",              privateID = 1310498,                soundH = {"spread","file:5s"},              soundM = {"spread","file:5s"},                              desc = "Spread out before it drops." },
            { key = "venom_rupture",                label = "Venom Rupture",                privateID = 1299838,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "guillotined",                  label = "Guillotined",                  privateID = 1307425,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "venomfang",                    label = "Venomfang",                    privateID = 1306906,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "noxious_ground",               label = "Noxious Ground",               privateID = 1283290,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "suffocating_darkness",         label = "Suffocating Darkness",         privateID = 1286947,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "guillotine",                   label = "Guillotine",                   privateID = 1283485,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "corrupted_toxin",              label = "Corrupted Toxin",              privateID = 1298795,                soundH = nil,                               soundM = nil,                            advanced = true    },
            
        },
    },
    {
        raid    = "The Venomous Abyss",
        boss    = "Ula'tek",
        bossKey = "ulatek",
        section = "|cffae3df5Ula'tek|r",
        journalInstanceID = 1320,
        journalEncounterID = 2895,
        abilities = {
            -- Default-on: the three things a player has to act on.
            { key = "surging_fang",                 label = "Surging Fang",                 privateID = {1288879,1295876,1293146}, soundH = "file:fang",                    soundM = "file:fang",                                       desc = "Kills you in 15s unless someone leeches it out of you. Get to the group and stay reachable." },
            { key = "volatile_purge",               label = "Volatile Purge",               privateID = 1306086,                soundH = {"file:purge","file:6s"},          soundM = {"file:purge","file:6s"},                          desc = "What you get for leeching a fang. Erupts on anyone within 7 yards when it drops, so spread." },
            { key = "doomscale_pheromones",         label = "Doomscale Pheromones",         privateID = 1300265,                soundH = "file:pheromones",                 soundM = "file:pheromones",                                 desc = "You smell like a Warden for 20s. Your Doomscale egg stays dormant while you have this." },

            -- Marks (short fuse, then something lands on you)
            { key = "serpents_bite_mark",           label = "Serpent's Bite (mark)",        privateID = 1293046,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "5s until the fang lands. Spread, everyone within 7 yards gets hit and takes Surging Fang." },
            { key = "serpents_bite",                label = "Serpent's Bite",               privateID = 1295905,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "You're marked. Spread, everyone within 7 yards gets hit and takes Surging Fang." },
            { key = "serpents_bite_impact",         label = "Serpent's Bite (impact)",      privateID = 1295838,                soundH = nil,                               soundM = nil,                            advanced = true    },
            { key = "petrifying_sting_mark",        label = "Petrifying Sting (mark)",      privateID = 1305163,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "5s until the viper dives. Move away, it petrifies everyone within 10 yards." },
            { key = "petrifying_sting",             label = "Petrifying Sting",             privateID = 1303414,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Petrified. Heal absorb that only breaks once you're topped off." },
            { key = "grasping_fangs_mark",          label = "Grasping Fangs (mark)",        privateID = 1301118,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "8s until the snakes root you. Get where you need to be first." },
            { key = "grasping_fangs",               label = "Grasping Fangs",               privateID = 1311611,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Rooted and slowed by the swarm." },

            -- Eggs
            { key = "malignant_shell",              label = "Malignant Shell",              privateID = 1295360,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Egg stuck to you, ticks while attached. Keep it out of the venom or it hatches." },
            { key = "noxious_shell",                label = "Noxious Shell",                privateID = 1307612,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Mythic egg stuck to you. Stay 3+ yards from other carriers or it hatches on you." },
            { key = "doomscale_shell",              label = "Doomscale Shell",              privateID = 1300312,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Stage 2 egg stuck to you. It only stays dormant while you have Doomscale Pheromones." },
            { key = "greasy_hatchling",             label = "Greasy Hatchling",             privateID = 1306388,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "You're holding a hatchling and it slips out of your grip in 20s. Deliver it before then." },
            { key = "butter_fingers",               label = "Butter Fingers",               privateID = 1306393,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "You dropped the hatchling. You can't hold another for a minute." },

            -- Dots and tank stacks
            { key = "putrid_membrane",              label = "Putrid Membrane",              privateID = {1301268,1308275},      soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Sprayed on everyone each time a viper hatches. Lasts an hour, just heal through it." },
            { key = "mothers_wrath",                label = "Mother's Wrath",               privateID = 1298367,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Tank knockback and mark. Stay in her reach or she hits the whole raid with it." },
            { key = "stone_venom",                  label = "Stone Venom",                  privateID = 1298417,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Tank stacks, slows you more as it builds." },
            { key = "mephitic_thrash",              label = "Mephitic Thrash",              privateID = 1296301,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Knockback plus a 20s poison. Just heal through it." },
            { key = "acidic_burst",                 label = "Acidic Burst",                 privateID = 1301800,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Viper spit, 18s poison. Just heal through it." },
            { key = "toxic_wounds",                 label = "Toxic Wounds",                 privateID = 1296203,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Blightscale Viper melee stacks this on whoever it's hitting." },
            { key = "poisonous_bite",               label = "Poisonous Bite",               privateID = 1287036,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Birthling bite, stacks. Just heal through it." },
            { key = "calcified_corpse",             label = "Calcified Corpse",             privateID = 1306119,                soundH = nil,                               soundM = nil,                            advanced = true,   desc = "Nobody leeched your fang in time. Breaks immunities and turns you to stone." },
        },
    },
    --{
        --raid    = "The Venomous Abyss",
        --boss    = "Uncategorized",
        --bossKey = "uncategorized",
        --section = "|cffae3df5Uncategorized|r",
        --abilities = {
            --{ key = "gnashing_extraction",          label = "Gnashing Extraction",          privateID = 1287551,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Pulling a fang 15 yards
            --{ key = "petrified",                    label = "Petrified",                    privateID = 1288891,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Viper Venom turn to stone, heal fully
            --{ key = "caustic_venom",                label = "Caustic Venom",                privateID = 1290036,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, if 5 stacks big 50yd boom
            --{ key = "fixate_12.1.0_1",              label = "Fixate",                       privateID = 1292782,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some fixate somewhere
            --{ key = "noxious_poison",               label = "Noxious Poison",               privateID = 1295701,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Some poison puddle


            
            --{ key = "dunduns_strange_shape",        label = "Dundun's Strange Shape",       privateID = 1297815,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- dunno
            --{ key = "necrotic_anguish",             label = "Necrotic Anguish",             privateID = 1299467,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dot, heal absorb

            --{ key = "unstable_venom",               label = "Unstable Venom",               privateID = 1301478,                soundH = "spread",                          soundM = "spread",                       advanced = true    }, -- Dot, spread 14s
            --{ key = "corrosive_tempest",            label = "Corrosive Tempest",            privateID = 1305386,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Dunno, dot and movement speed or something
            --{ key = "toxic_beam",                   label = "Toxic Beam",                   privateID = 1306856,                soundH = nil,                               soundM = nil,                            advanced = true    }, -- Beam, does damage when hit
            
        --},
    --},
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid[#CCS_Spells_Raid + 1] = e
end