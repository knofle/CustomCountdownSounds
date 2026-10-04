-- data/S2/r_the_unbinding_of_kithix.lua
-- The Unbinding of Kith'ix (single-boss raid). Season 2 pool.
-- soundH = Heroic, soundM = Mythic, soundStack = Aura Stack, soundRemove = Aura Remove
--
-- NOTE: privateID values below are the *journal* spell IDs from the dungeon journal.

-- 12.1.5+ only.
if select(4, GetBuildInfo()) < 120105 then return end

local entries = {
    {
        raid    = "The Unbinding of Kith'ix",
        boss    = "Kith'ix",
        bossKey = "kithix",
        section = "|cff7fbf3fKith'ix|r",
        journalInstanceID = 1324,     
        journalEncounterID = 2896,    
        abilities = {
            -- ==================== Stage One: Darkness' Domain ====================

            -- Default-on: the player mechanics you actually react to.
            --{ key = "kith_fixate",                  label = "Fixate",                       privateID = 1302295,                soundH = {"fixate"},                        soundM = {"fixate"},     --Hidden                                                }, -- Bomber Beetle chases you
            --{ key = "kith_suffocating_darkness",    label = "Suffocating Darkness",         privateID = 1302951,                soundH = {"file:darkness"},                 soundM = {"file:darkness"},                                              }, -- 100 energy, get to Liadrin's bulwark
            { key = "kith_abyssal_grasp",           label = "Abyssal Grasp",                privateID = 1303406,                soundH = {"absorb"},                        soundM = {"absorb"},                                                     }, -- heal-absorb, remove before you're dragged in (fuse duration unknown)
            { key = "kith_unspeakable_horrors",     label = "Unspeakable Horrors",          privateID = 1304045,                soundH = {"file:out"},                      soundM = {"file:out"},                                           }, -- 6s then fear + scream, spread out
            --{ key = "kith_dark_devastation",        label = "Dark Devastation",             privateID = 1304930,                soundH = {"targeted"},                      soundM = {"targeted"},                                                   }, -- tank hit, 15yd splash + Devastated

            -- Adds / secondary (advanced)
            --{ key = "kith_voidswarm",               label = "Voidswarm",                    privateID = 1301511,                soundH = nil,                               soundM = nil,                       advanced = true,  unit="boss1",                   }, -- void portals + aqir summon
            --{ key = "kith_venom_roar",              label = "Venom Roar",                   privateID = 1302884,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Venomous Hulk frontal cone + knockback
            --{ key = "kith_incubation",              label = "Incubation",                   privateID = 1307407,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- eggs burst on aqir death
            { key = "kith_mindsting",               label = "Mindsting",                    privateID = 1304040,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Mindstinger stun + nature dot
            --{ key = "kith_voidweave",               label = "Voidweave",                    privateID = 1302333,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Voidweaver shadow dot 8s
            --{ key = "kith_nightfall",               label = "Nightfall",                    privateID = 1302705,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- stacking raid shadow dmg
            { key = "kith_gut_reaction",            label = "Gut Reaction",                 privateID = 1302117,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- beetle explosion
            { key = "kith_digestive_juices",        label = "Digestive Juices",             privateID = 1302319,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- stacking nature dot (consider soundStack)

            -- Suffocating Darkness phase pieces (advanced)
            { key = "kith_suffocation",             label = "Suffocation",                  privateID = 1303257,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- caught in the storm
            { key = "kith_dark_frenzy",             label = "Dark Frenzy",                  privateID = 1303260,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- surviving aqir empowered
            { key = "kith_refulgent_bulwark",       label = "Refulgent Bulwark",            privateID = 1302952,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Liadrin's barrier
            --{ key = "kith_divine_radiance",         label = "Divine Radiance",              privateID = 1303169,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Liadrin 100 energy, stuns Kith'ix 8s (burn)
            --{ key = "kith_exhausted",               label = "Exhausted",                    privateID = 1307662,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Liadrin stacking strain

            -- Light / raid burst (advanced)
            --{ key = "kith_extinguish",              label = "Extinguish",                   privateID = 1304424,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- big raid shockwave, needs Light's Embrace
            { key = "kith_lights_embrace",          label = "Light's Embrace",              privateID = 1304526,                soundH = "file:safe",                       soundM = "file:safe",                                                   }, -- -90% shadow buff, warn on drop before Extinguish

            -- Other Stage One (advanced)
            { key = "kith_overwhelming_fear",       label = "Overwhelming Fear",            privateID = 1304046,                soundH = "file:dispel",                     soundM = "file:dispel",                                            }, -- the fear from Unspeakable Horrors
            --{ key = "kith_twisted_appendage",       label = "Twisted Appendage",            privateID = 1303681,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- tentacles lash nearby
            { key = "kith_devastated",              label = "Devastated",                   privateID = 1304948,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- tank stacking dmg taken (consider soundStack)
            { key = "kith_voidscar",                label = "Voidscar",                     privateID = 1304950,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- H/M ground void
            { key = "kith_eclipse_fragment",        label = "Eclipse Fragment",             privateID = 1308674,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- fragments drift to Liadrin
            { key = "kith_lost_refulgence",         label = "Lost Refulgence",              privateID = 1308675,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- fragment reaches Liadrin
            { key = "kith_commanding_presence",     label = "Commanding Presence",          privateID = 1305008,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- passive aqir dmg reduction

            -- ==================== Stage Two: Last Light ====================

            -- Default-on
            { key = "kith_stygian_howl",            label = "Stygian Howl",                 privateID = 1301110,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- 25% health, phase 2 / burn race begins
            { key = "kith_null_gate",               label = "Null Gate",                    privateID = 1308873,                soundH = {"drop","file:5s"},                soundM = {"drop","file:5s"},                                             }, -- 5s fuse, drop gate away from raid
            { key = "kith_negation",                label = "Negation",                     privateID = 1318467,                soundH = {"file:clear"},                    soundM = {"file:clear"},                                                   }, -- reach a Null Gate before it expires (multi-stack on Mythic)

            -- Advanced
            --{ key = "kith_eightfold_eclipse",       label = "Eightfold Eclipse",            privateID = 1301479,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- soft enrage, eclipse pulses
            { key = "kith_nullshards",              label = "Nullshards",                   privateID = 1308881,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- shards scatter + Nullify
            { key = "kith_nullify",                 label = "Nullify",                      privateID = 1308875,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- stacking, 6 = death (consider soundStack)
            { key = "kith_explosive_restab",        label = "Explosive Restabilization",    privateID = 1318472,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Negation + Null Gate explosion
            --{ key = "kith_last_light",              label = "Last Light",                   privateID = 1305427,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- Liadrin full heal + Luminous Grace
            --{ key = "kith_luminous_grace",          label = "Luminous Grace",               privateID = 1305428,                soundH = nil,                               soundM = nil,                       advanced = true                     }, -- +50% dmg / +100% healing buff

        },
    },
}

for _, e in ipairs(entries) do
    CCS_Spells_Raid_S2[#CCS_Spells_Raid_S2 + 1] = e
end