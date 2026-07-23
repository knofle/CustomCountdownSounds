-- core.lua

local addonName = ...

CCS = CCS or {}

-- Set true to enable the Mythic+ module
CCS.MPLUS_ENABLED = true

-- OnReady: queued init callbacks fired after AceDB is up.
CCS._onReadyQueue = CCS._onReadyQueue or {}
CCS._ready = false
function CCS.OnReady(fn)
    if CCS._ready then
        fn()
    else
        CCS._onReadyQueue[#CCS._onReadyQueue + 1] = fn
    end
end

-- Sound registration and CCS.ResolvePath now live in sounds.lua (loaded first).

--------------------------------------------------
-- Difficulty
--------------------------------------------------

local function getCurrentDifficulty()
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "raid" then
        if difficultyID == 16 or difficultyID == 233 then return "M"
        elseif difficultyID == 15 then return "H"
        end
    elseif instanceType == "party" then
        -- 8 = Mythic Keystone, 23 = Mythic dungeon / M0
        if difficultyID == 8 or difficultyID == 9 or difficultyID == 23 then
            return "M"
        end
        -- /plexus test mode: treat any party instance as Mythic so follower
        -- dungeons work for PTR testing. Resets every reload.
        if CCS._followerTestMode then return "M" end
    end
    return nil
end

local function getInstanceType()
    local _, instanceType = GetInstanceInfo()
    return instanceType  -- "raid", "party", "none", etc.
end

CCS.getCurrentDifficulty = getCurrentDifficulty

--------------------------------------------------
-- AceDB
--------------------------------------------------

local dbDefaults = {
    profile = {
        showAllBosses = {},
        expandedSpells = {},
        channel       = "Master", -- output channel: Master/Music/SFX/Ambience/Dialog
    },
    char = {
        minimap              = { minimapPos = 225, hide = false },
        module               = "raid",
        activeDungeon        = "__all__",
        activeRaid           = "__all__",
        customTimerOverride  = false,
        extraAuraTriggers    = false,  -- show the per-trigger sub-rows
        scale                = 1.0,   -- standalone window scale
    },
}

-- Initialise the shared raid table; data files append to it.
CCS_Spells_Raid = CCS_Spells_Raid or {}

-- Active M+ dungeons, switched on patch.
local _, _, _, tocVersion = GetBuildInfo()

local mplusDungeons_120 = {
    { key = "magisters_terrace",       label = "Magister's Terrace",      color = "|cffda8b45", icon = 7439625, data = function() return CCS_Spells_Mplus_MagistersTerrace      end },
    { key = "maisara_caverns",         label = "Maisara Caverns",         color = "|cff7ec87e", icon = 7322719, data = function() return CCS_Spells_Mplus_MaisaraCaverns         end },
    { key = "nexus_point_xenas",       label = "Nexus-Point Xenas",       color = "|cff6aacdc", icon = 7553062, data = function() return CCS_Spells_Mplus_NexusPointXenas        end },
    { key = "windrunner_spire",        label = "Windrunner Spire",        color = "|cffe8c46a", icon = 7266215, data = function() return CCS_Spells_Mplus_WindrunnerSpire        end },
    { key = "algethar_academy",        label = "Algeth'ar Academy",       color = "|cffc17de8", icon = 4578414, data = function() return CCS_Spells_Mplus_AlgetharAcademy        end },
    { key = "pit_of_saron",            label = "Pit of Saron",            color = "|cff9dbde8", icon = 343641, data = function() return CCS_Spells_Mplus_PitOfSaron             end },
    { key = "seat_of_the_triumvirate", label = "Seat of the Triumvirate", color = "|cffdc8fe0", icon = 1711340, data = function() return CCS_Spells_Mplus_SeatOfTheTriumvirate   end },
    { key = "skyreach",                label = "Skyreach",                color = "|cffe8e06a", icon = 1002596, data = function() return CCS_Spells_Mplus_Skyreach               end },
}

local mplusDungeons_121 = {
    { key = "murder_row",              label = "Murder Row",              color = "|cffe07a3a", icon = 7266213, data = function() return CCS_Spells_Mplus_MurderRow             end },
    { key = "den_of_nalorakk",         label = "Den of Nalorakk",         color = "|cff6dab5a", icon = 7266214, data = function() return CCS_Spells_Mplus_DenOfNalorakk         end },
    { key = "blinding_vale",           label = "The Blinding Vale",       color = "|cff8ae0d4", icon = 7354408, data = function() return CCS_Spells_Mplus_BlindingVale          end },
    { key = "voidscar_arena",          label = "Voidscar Arena",          color = "|cff8e5acb", icon = 7439626, data = function() return CCS_Spells_Mplus_VoidscarArena         end },
    { key = "altar_of_fangs",          label = "Altar of Fangs",          color = "|cffc04a4a", icon = 7956175, data = function() return CCS_Spells_Mplus_AltarOfFangs          end },
    { key = "ruby_life_pools",         label = "Ruby Life Pools",         color = "|cffe04a5a", icon = 4578416, data = function() return CCS_Spells_Mplus_RubyLifePools         end },
    { key = "temple_of_sethraliss",    label = "Temple of Sethraliss",    color = "|cff5cb46c", icon = 2011143, data = function() return CCS_Spells_Mplus_TempleOfSethraliss    end },
    { key = "kings_rest",              label = "Kings' Rest",             color = "|cffd4af37", icon = 2011123, data = function() return CCS_Spells_Mplus_KingsRest             end },
}

CCS.MplusDungeons = (tocVersion >= 120100) and mplusDungeons_121 or mplusDungeons_120

local db

function CCS.GetProfile()
    if not db then return { warnEnabled={}, warnOverride={}, countdownEnabled={}, countdownOverride={}, showAllBosses={}, expandedSpells={} } end
    local p = db.profile
    if rawget(p, "warnEnabled")       == nil then rawset(p, "warnEnabled",       {}) end
    if rawget(p, "warnOverride")      == nil then rawset(p, "warnOverride",       {}) end
    if rawget(p, "countdownEnabled")  == nil then rawset(p, "countdownEnabled",   {}) end
    if rawget(p, "countdownOverride") == nil then rawset(p, "countdownOverride",  {}) end
    if rawget(p, "showAllBosses")     == nil then rawset(p, "showAllBosses",      {}) end
    if rawget(p, "expandedSpells")    == nil then rawset(p, "expandedSpells",     {}) end
    if rawget(p, "channel")           == nil then rawset(p, "channel",     "Master") end
    return p
end

function CCS.GetChar()
    if not db then return dbDefaults.char end
    return db.char
end

function CCS.GetProfileName()
    if not db then return "Default" end
    return db:GetCurrentProfile()
end

function CCS.GetProfileNames()
    if not db then return {"Default"} end
    local names = {}
    db:GetProfiles(names)
    table.sort(names)
    return names
end

function CCS.SetActiveProfile(name)
    if not db then return end
    db:SetProfile(name)
end

function CCS.NewProfile(name)
    if not db then return end
    db:SetProfile(name)
end

function CCS.CopyProfile(sourceName)
    if not db then return end
    db:CopyProfile(sourceName)
end

function CCS.DeleteProfile(name)
    if not db then return end
    db:DeleteProfile(name)
end

function CCS.ResetProfile()
    if not db then return end
    db:ResetProfile()
end

function CCS.GetDB()
    return db
end

--------------------------------------------------
-- Profile export / import
--------------------------------------------------
-- A profile is shared as a printable string. We serialize only the settings
-- that describe "how this profile sounds" (the four delta tables + channel),
-- keyed by ability key so the string survives spell-ID changes. Personal
-- display prefs (scale, module) live in char and are never exported.

local EXPORT_PREFIX = "CCS1"  -- magic marker + format version

-- Which profile fields travel with an export.
local EXPORT_KEYS = {
    warnEnabled = true, warnOverride = true,
    countdownEnabled = true, countdownOverride = true,
    channel = true, showAllBosses = true, expandedSpells = true,
}

local function getLibs()
    local ser = LibStub and LibStub("LibSerialize", true)
    local def = LibStub and LibStub("LibDeflate", true)
    return ser, def
end

-- Serialize the named profile (or current) into a printable string.
-- Returns string, or nil + error message.
function CCS.ExportProfile(profileName)
    local ser, def = getLibs()
    if not ser or not def then return nil, "Missing LibSerialize/LibDeflate." end
    if not db then return nil, "No database." end

    profileName = profileName or CCS.GetProfileName()
    local src = (profileName == CCS.GetProfileName()) and db.profile or (db.sv.profiles and db.sv.profiles[profileName])
    if not src then return nil, "Profile not found." end

    local payload = { name = profileName }
    for k in pairs(EXPORT_KEYS) do
        if src[k] ~= nil then payload[k] = src[k] end
    end
    local serialized = ser:Serialize(payload)
    local compressed = def:CompressDeflate(serialized, { level = 7 })
    if not compressed then return nil, "Compression failed." end
    return EXPORT_PREFIX .. def:EncodeForPrint(compressed)
end

-- Decode + validate an import string WITHOUT writing anything.
-- Returns a clean payload table (with .name), or nil + error message.
function CCS.DecodeProfile(str)
    local ser, def = getLibs()
    if not ser or not def then return nil, "Missing LibSerialize/LibDeflate." end
    if type(str) ~= "string" then return nil, "No import string." end

    str = str:gsub("%s+", "")  -- tolerate stray whitespace/newlines from pasting
    local prefix = str:sub(1, #EXPORT_PREFIX)
    if prefix ~= EXPORT_PREFIX then
        return nil, "Not a Custom Countdown Sounds profile string."
    end

    local body = str:sub(#EXPORT_PREFIX + 1)
    local decoded = def:DecodeForPrint(body)
    if not decoded then return nil, "String is corrupt (decode failed)." end
    local decompressed = def:DecompressDeflate(decoded)
    if not decompressed then return nil, "String is corrupt (decompress failed)." end

    local ok, payload = ser:Deserialize(decompressed)
    if not ok or type(payload) ~= "table" then return nil, "String is corrupt (bad data)." end

    -- Validate: every exported field must be a table (or the channel string),
    -- and nothing unexpected gets through.
    local clean = { name = type(payload.name) == "string" and payload.name or "Imported" }
    for k in pairs(EXPORT_KEYS) do
        local v = payload[k]
        if k == "channel" then
            if type(v) == "string" then clean.channel = v end
        elseif type(v) == "table" then
            clean[k] = v
        end
    end
    return clean
end

-- Commit a decoded payload into a target profile, replacing its contents.
-- targetName is created if it does not exist. Switches to it.
function CCS.ImportProfile(payload, targetName)
    if not db then return false, "No database." end
    if type(payload) ~= "table" then return false, "Nothing to import." end
    targetName = targetName or payload.name or "Imported"

    db:SetProfile(targetName)          -- creates it if new, and makes it active
    db:ResetProfile()                  -- replace: start from a clean profile
    local p = CCS.GetProfile()
    for k in pairs(EXPORT_KEYS) do
        if k == "channel" then
            if payload.channel then p.channel = payload.channel end
        elseif payload[k] then
            p[k] = payload[k]
        end
    end

    if CCS._onProfileChange then CCS._onProfileChange() end
    -- Older strings may carry a font field; the addon ships its own font now,
    -- so it is ignored rather than treated as an error.
    return true
end

-- Stamp each entry with its dungeon colour and return a combined list.
local function combineDungeons(onlyKey)
    local out = {}
    for _, dungeon in ipairs(CCS.MplusDungeons) do
        if not onlyKey or dungeon.key == onlyKey then
            local data = dungeon.data()
            if data then
                for _, entry in ipairs(data) do
                    entry._color = dungeon.color
                    out[#out + 1] = entry
                end
            end
        end
    end
    return out
end

local function applyModule()
    local m = (db and db.char.module) or "raid"
    if not CCS.MPLUS_ENABLED and m == "mplus" then
        if db then db.char.module = "raid" end
        m = "raid"
    end
    if m == "mplus" and CCS.MPLUS_ENABLED then
        local key = (db and db.char.activeDungeon) or "__all__"
        if key ~= "__all__" then
            -- Single dungeon; combineDungeons stamps colour and filters.
            local single = combineDungeons(key)
            if #single > 0 then
                CCS_Spells = single
                return
            end
            -- Stored dungeon no longer exists; fall through to "all".
            if db then db.char.activeDungeon = "__all__" end
        end
        CCS_Spells = combineDungeons(nil)
    else
        local raidKey = (db and db.char.activeRaid) or "__all__"
        if raidKey == "__all__" then
            CCS_Spells = CCS_Spells_Raid
        else
            local filtered = {}
            for _, entry in ipairs(CCS_Spells_Raid) do
                if entry.raid == raidKey then
                    filtered[#filtered + 1] = entry
                end
            end
            -- Stored raid no longer exists (e.g. patch changed); reset.
            if #filtered == 0 then
                if db then db.char.activeRaid = "__all__" end
                CCS_Spells = CCS_Spells_Raid
            else
                CCS_Spells = filtered
            end
        end
    end
end

CCS.ApplyModule = applyModule

function CCS.SetDungeon(key)
    if not db or not CCS.MPLUS_ENABLED then return end
    if key ~= "__all__" then
        local valid = false
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            if dungeon.key == key then valid = true; break end
        end
        if not valid then
            print("|cffff5555CCS:|r Unknown dungeon '" .. tostring(key) .. "'.")
            return
        end
    end
    db.char.activeDungeon = key
    applyModule()
    CCS.RefreshAll()
    if CCS._fullRebuild then CCS._fullRebuild() end
end

function CCS.GetActiveDungeon()
    return (db and db.char.activeDungeon) or "__all__"
end

-- Ordered list of unique raid names.
function CCS.GetRaidList()
    local seen = {}
    local list = {}
    for _, entry in ipairs(CCS_Spells_Raid) do
        if entry.raid and not seen[entry.raid] then
            seen[entry.raid] = true
            list[#list + 1] = entry.raid
        end
    end
    return list
end

function CCS.GetActiveRaid()
    return (db and db.char.activeRaid) or "__all__"
end

function CCS.SetRaid(name)
    if not db then return end
    if name ~= "__all__" then
        local valid = false
        for _, entry in ipairs(CCS_Spells_Raid) do
            if entry.raid == name then valid = true; break end
        end
        if not valid then
            print("|cffff5555CCS:|r Unknown raid '" .. tostring(name) .. "'.")
            return
        end
    end
    db.char.activeRaid = name
    applyModule()
    CCS.RefreshAll()
    if CCS._fullRebuild then CCS._fullRebuild() end
end

function CCS.SetModule(name)
    if name ~= "raid" and name ~= "mplus" then
        print("|cffff5555CCS:|r Unknown module '" .. name .. "'. Use 'raid' or 'mplus'.")
        return
    end
    if name == "mplus" and not CCS.MPLUS_ENABLED then
        print("|cffff5555CCS:|r Mythic+ module is not enabled.")
        return
    end
    if not db then return end
    db.char.module = name
    applyModule()
    CCS.RefreshAll()
    if CCS._fullRebuild then CCS._fullRebuild() end
end

function CCS.GetModule()
    if not CCS.MPLUS_ENABLED then return "raid" end
    return (db and db.char.module) or "raid"
end

function CCS.GetCustomTimerOverride()
    return CCS.GetChar().customTimerOverride == true
end

function CCS.SetCustomTimerOverride(val)
    CCS.GetChar().customTimerOverride = val
end

-- Reveals the per-spell expand chevrons and their apply/stack/remove sub-rows.
-- Visibility only: sounds already set on a trigger keep playing either way,
-- the same way an override applies whether or not Manual Mode is on.
function CCS.GetExtraAuraTriggers()
    if CCS.SupportsAuraTriggers and not CCS.SupportsAuraTriggers() then
        return false
    end
    return CCS.GetChar().extraAuraTriggers == true
end

function CCS.SetExtraAuraTriggers(val)
    CCS.GetChar().extraAuraTriggers = val
end

-- True if this exact trigger key has a sound set on it (ticked or overridden).
-- A configured trigger stays visible even with the toggle off, so an imported
-- profile's settings can't end up active but hidden with no way to clear them.
function CCS.HasTriggerConfig(triggerKey)
    if not triggerKey then return false end
    local p = CCS.GetProfile()
    return p.warnEnabled[triggerKey] == true or p.warnOverride[triggerKey] ~= nil
end

local VALID_CHANNELS = { Master = true, Music = true, SFX = true, Ambience = true, Dialog = true }
function CCS.GetChannel() return CCS.GetProfile().channel or "Master" end
function CCS.SetChannel(v)
    if VALID_CHANNELS[v] then CCS.GetProfile().channel = v end
end

function CCS.GetScale() return CCS.GetChar().scale or 1.0 end
function CCS.SetScale(v)
    if type(v) == "number" then
        CCS.GetChar().scale = math.max(0.75, math.min(2.0, v))
    end
end

function CCS.GetShowAllBoss(bossKey)
    if not bossKey then return false end
    return CCS.GetProfile().showAllBosses[bossKey] == true
end

function CCS.SetShowAllBoss(bossKey, val)
    if not bossKey then return end
    CCS.GetProfile().showAllBosses[bossKey] = val or nil
    CCS.RefreshSounds()
end

-- Per-spell expansion: shows the apply/stack/remove sub-rows for one ability.
function CCS.IsSpellExpanded(key)
    if not key then return false end
    local t = CCS.GetProfile().expandedSpells
    return t and t[key] == true
end

function CCS.SetSpellExpanded(key, val)
    if not key then return end
    local p = CCS.GetProfile()
    p.expandedSpells = p.expandedSpells or {}
    p.expandedSpells[key] = val or nil
end

-- Collapse every expanded spell. Used when the triggers toggle is switched off,
-- so turning it back on starts from a clean list rather than restoring whatever
-- was open before. Configured triggers stay visible on their own regardless.
function CCS.ClearSpellExpansions()
    CCS.GetProfile().expandedSpells = {}
end

-- opt-in = at least one warn/countdown tick is on. a chosen sound alone
-- doesn't count, an unticked ability stays hidden.
function CCS.IsAbilityOptedIn(key)
    if not key then return false end
    local p = CCS.GetProfile()
    if p.warnEnabled[key] == true then return true end
    local ce = p.countdownEnabled[key]
    if ce and (ce.H == true or ce.M == true) then return true end
    -- A sound set on only a stack/remove event still counts as opting in, or
    -- the ability would disappear (and stop registering) when its boss collapses.
    for _, event in ipairs({ "stack", "remove" }) do
        if p.warnEnabled[key .. CCS.EVENT_SUFFIX[event]] == true then return true end
    end
    return false
end

-- Advanced abilities are visible if the boss's "Show non-default" is on
-- OR if the user has opted them in (any enabled tick).
-- Non-advanced abilities are always active.
function CCS.IsAbilityActive(abilityKey)
    if not abilityKey then return true end

    local function scan(entries)
        for _, entry in ipairs(entries) do
            if entry.abilities then
                for _, ab in ipairs(entry.abilities) do
                    if ab.key == abilityKey then
                        if ab.advanced
                           and not CCS.GetShowAllBoss(entry.bossKey)
                           and not CCS.IsAbilityOptedIn(abilityKey) then
                            return false
                        end
                        return true
                    end
                end
            end
        end
        return nil  -- not found in this set
    end

    if CCS_Spells_Raid then
        local r = scan(CCS_Spells_Raid)
        if r ~= nil then return r end
    end
    if CCS.MplusDungeons then
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then
                local r = scan(data)
                if r ~= nil then return r end
            end
        end
    end
    return true
end

--------------------------------------------------
-- Profile data accessors
--------------------------------------------------

function CCS.isWarnEnabled(key)
    return CCS.GetProfile().warnEnabled[key] == true
end

function CCS.SetWarnEnabled(key, val)
    CCS.GetProfile().warnEnabled[key] = val
end

function CCS.GetWarnOverride(key)
    return CCS.GetProfile().warnOverride[key]
end

function CCS.SetWarnOverride(key, soundKey)
    CCS.GetProfile().warnOverride[key] = soundKey
end

function CCS.IsCDEnabled(key, diff)
    local t = CCS.GetProfile().countdownEnabled[key]
    return t and t[diff] == true or false
end

function CCS.SetCDEnabled(key, diff, val)
    local p = CCS.GetProfile()
    p.countdownEnabled[key] = p.countdownEnabled[key] or {}
    p.countdownEnabled[key][diff] = val
end

function CCS.GetCountdownOverride(key, diff)
    local t = CCS.GetProfile().countdownOverride[key]
    return t and t[diff] or nil
end

function CCS.SetCountdownOverride(key, diff, soundKey)
    local p = CCS.GetProfile()
    p.countdownOverride[key] = p.countdownOverride[key] or {}
    p.countdownOverride[key][diff] = soundKey
end

-- Iterate abilities for "raid" or "mplus". Callback receives
-- (ability, isMplus, bossKey).
local function iterateModuleSpells(module, fn)
    if module == "raid" then
        for _, entry in ipairs(CCS_Spells_Raid) do
            if entry.abilities then
                for _, ability in ipairs(entry.abilities) do fn(ability, false, entry.bossKey) end
            end
        end
    elseif module == "mplus" then
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then
                for _, entry in ipairs(data) do
                    if entry.abilities then
                        for _, ability in ipairs(entry.abilities) do fn(ability, true, entry.bossKey) end
                    end
                end
            end
        end
    end
end

-- Shared helpers for the bulk warn/countdown operations below.
local function fieldHasWarn(f)
    if f == nil then return false end
    if type(f) == "table" then return f[1] ~= nil end
    return true
end

-- An advanced ability is only bulk-touchable when it's visible: its boss's
-- "Show non-default" is on, or the user has opted it in.
local function abilityVisibleForBulk(ability, bossKey)
    if not ability.advanced then return true end
    if CCS.GetShowAllBoss(bossKey) then return true end
    return CCS.IsAbilityOptedIn(ability.key)
end

-- Bulk enable/disable warns.
--   - Only touches abilities that are visible right now.
--   - Enable needs a default/override; disable also unticks tick-only.
function CCS.SetAllWarn(val, module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    iterateModuleSpells(module, function(ability, _, bossKey)
        if not abilityVisibleForBulk(ability, bossKey) then return end
        local hasDefault  = fieldHasWarn(ability.soundH) or fieldHasWarn(ability.soundM)
        local hasOverride = p.warnOverride[ability.key] ~= nil
        local currentlyOn = p.warnEnabled[ability.key] == true
        if val then
            if hasDefault or hasOverride then
                p.warnEnabled[ability.key] = true
            end
        elseif hasDefault or hasOverride or currentlyOn then
            p.warnEnabled[ability.key] = false
        end
    end)
end

-- Bulk enable/disable countdowns.
function CCS.SetAllCD(val, module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    iterateModuleSpells(module, function(ability, isMplus, bossKey)
        if not abilityVisibleForBulk(ability, bossKey) then return end
        local function hasDefault(diff)
            local s = diff == "M" and ability.soundM or (diff ~= "M" and ability.soundH)
            return type(s) == "table" and s[2] ~= nil
        end
        local function hasOverride(diff)
            return p.countdownOverride[ability.key] and p.countdownOverride[ability.key][diff] ~= nil
        end
        local function currentlyOn(diff)
            return p.countdownEnabled[ability.key] and p.countdownEnabled[ability.key][diff] == true
        end
        local function apply(diff)
            if val then
                if hasDefault(diff) or hasOverride(diff) then
                    p.countdownEnabled[ability.key] = p.countdownEnabled[ability.key] or {}
                    p.countdownEnabled[ability.key][diff] = true
                end
            elseif hasDefault(diff) or hasOverride(diff) or currentlyOn(diff) then
                p.countdownEnabled[ability.key] = p.countdownEnabled[ability.key] or {}
                p.countdownEnabled[ability.key][diff] = false
            end
        end
        if isMplus then
            apply("M")
        else
            apply("H")
            apply("M")
        end
    end)
end

-- Returns "all_on" / "all_off" / "mixed" for the bulk-toggleable warns.
function CCS.GetBulkWarnState(module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    local seen, onCount = 0, 0
    iterateModuleSpells(module, function(ability, _, bossKey)
        if not abilityVisibleForBulk(ability, bossKey) then return end
        local hasDefault  = fieldHasWarn(ability.soundH) or fieldHasWarn(ability.soundM)
        local hasOverride = p.warnOverride[ability.key] ~= nil
        local currentlyOn = p.warnEnabled[ability.key] == true
        if not hasDefault and not hasOverride and not currentlyOn then return end
        seen = seen + 1
        if currentlyOn then onCount = onCount + 1 end
    end)
    if seen == 0 or onCount == 0 then return "all_off" end
    if onCount == seen then return "all_on" end
    return "mixed"
end

-- Same shape, for countdown flags.
function CCS.GetBulkCDState(module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    local seen, onCount = 0, 0
    iterateModuleSpells(module, function(ability, isMplus, bossKey)
        if not abilityVisibleForBulk(ability, bossKey) then return end
        local function hasDefault(diff)
            local s = diff == "M" and ability.soundM or ability.soundH
            return type(s) == "table" and s[2] ~= nil
        end
        local function hasOverride(diff)
            return p.countdownOverride[ability.key] and p.countdownOverride[ability.key][diff] ~= nil
        end
        local function isEnabled(diff)
            return p.countdownEnabled[ability.key] and p.countdownEnabled[ability.key][diff] == true
        end
        local diffs = isMplus and {"M"} or {"H", "M"}
        for _, d in ipairs(diffs) do
            if hasDefault(d) or hasOverride(d) or isEnabled(d) then
                seen = seen + 1
                if isEnabled(d) then onCount = onCount + 1 end
            end
        end
    end)
    if seen == 0 or onCount == 0 then return "all_off" end
    if onCount == seen then return "all_on" end
    return "mixed"
end




--------------------------------------------------
-- Sound resolution
--------------------------------------------------

-- Dedupe resolve-failure warnings so each unique problem only prints once.
local _warnedResolveFailures = {}
local function warnResolveFailure(kind, soundKey, abilityKey)
    local k = abilityKey .. "|" .. tostring(soundKey) .. "|" .. kind
    if _warnedResolveFailures[k] then return end
    _warnedResolveFailures[k] = true
    if kind == "warn" then
        print("|cffff9900CCS:|r Warning — could not resolve sound '" .. tostring(soundKey) .. "' for " .. abilityKey)
    else
        print("|cffff9900CCS:|r Warning — could not resolve countdown sound '" .. tostring(soundKey) .. "' for " .. abilityKey)
    end
end

local function resolveAbilitySounds(ability, diff)
    local paths = {}

    if CCS.isWarnEnabled(ability.key) then
        local warnField = ability.soundH or ability.soundM
        local defaultWarn
        if type(warnField) == "table" then
            defaultWarn = warnField[1]
        else
            defaultWarn = warnField
        end
        local warnKey = CCS.GetWarnOverride(ability.key) or defaultWarn
        if warnKey then
            local p = CCS.ResolvePath(warnKey)
            if p then
                paths[#paths + 1] = p
            else
                warnResolveFailure("warn", warnKey, ability.key)
            end
        end
    end

    if CCS.IsCDEnabled(ability.key, diff) then
        local soundField = diff == "M" and ability.soundM or (diff ~= "M" and ability.soundH)
        local defaultCD = type(soundField) == "table" and soundField[2] or nil
        -- A user-set override is their choice and plays whether or not manual
        -- mode is on; manual mode only governs whether they can edit it.
        local cdKey = CCS.GetCountdownOverride(ability.key, diff) or defaultCD
        if cdKey then
            local p = CCS.ResolvePath(cdKey)
            if p then
                paths[#paths + 1] = p
            else
                warnResolveFailure("cd", cdKey, ability.key)
            end
        end
    end

    return #paths > 0 and paths or nil
end

--------------------------------------------------
-- Aura Registration
--------------------------------------------------

-- The private-aura sound API has been renamed twice as it was generalized:
--   AddPrivateAuraAppliedSound  (original, private auras only)
--   AddAuraAppliedSound         (12.1.0, restriction lifted)
--   AddAuraSound                (12.1.0 PTR 6, also supports gain/remove events)
-- Feature-detect newest first so we work across all clients. The add call is
-- routed through callAddAuraSound below, since its signature changed too.
local removeAuraSound      = C_UnitAuras.RemoveAuraSound
                          or C_UnitAuras.RemoveAuraAppliedSound
                          or C_UnitAuras.RemovePrivateAuraAppliedSound
local hasGeneralAuraSounds = (C_UnitAuras.AddAuraSound or C_UnitAuras.AddAuraAppliedSound) ~= nil

-- 12.1.0 PTR 6: AddAuraSound can fire on apply, on gaining an application
-- (stack) or on removal. A spell's settings are stored under its own key for
-- apply, and under key.."@stack" / key.."@remove" for the other two, so the
-- existing flat storage, profiles and export all work unchanged.
-- The addon ships its own font, so nothing depends on LibSharedMedia or on
-- whatever fonts the user happens to have installed. Bold is for the large
-- headings; regular for everything else.
CCS.FONT_DIR     = "Interface\\AddOns\\CustomCountdownSounds\\fonts\\"
CCS.FONT_REGULAR = CCS.FONT_DIR .. "Expressway.ttf"
CCS.FONT_BOLD    = CCS.FONT_DIR .. "Expressway Bold.ttf"

CCS.AURA_EVENTS = { "apply", "stack", "remove" }
CCS.EVENT_SUFFIX = { apply = "", stack = "@stack", remove = "@remove" }
-- Display names for the trigger sub-rows.
CCS.EVENT_LABEL  = { apply = "Aura Applied", stack = "Stack Gain", remove = "Aura Removed" }

-- Strip a variant suffix to get back the base ability key.
function CCS.BaseKey(key)
    if type(key) ~= "string" then return key end
    return (key:gsub("@%a+$", ""))
end

-- Default warn sound authored for an extra aura event, if any. Data files can
-- set soundStack / soundRemove alongside soundM, e.g.
--   { key = "x", label = "X", privateID = 123,
--     soundM = "file:warn", soundStack = "file:stack" }
-- A table is accepted for symmetry with soundM but only its warn slot is used,
-- since a countdown makes no sense on a stack or removal trigger.
function CCS.GetEventDefault(ability, event)
    if not ability or event == "apply" then return nil end
    local s = (event == "stack") and ability.soundStack or ability.soundRemove
    if type(s) == "table" then return s[1] end
    return s
end

-- Build the stand-in ability table a stack/remove sub-row registers under.
-- Its authored default (if any) is passed as soundM so the existing warn
-- resolution and dropdown logic pick it up with no special-casing.
function CCS.MakeEventAbility(ability, event)
    return {
        key       = ability.key .. CCS.EVENT_SUFFIX[event],
        label     = ability.label,
        privateID = ability.privateID,
        soundM    = CCS.GetEventDefault(ability, event),
        _event    = event,
    }
end

-- ONLY PLACE that knows the real API shape. 12.1.0 PTR 6 replaced the single
-- options table with two arguments:
--     C_UnitAuras.AddAuraSound(trigger, sound)
-- where trigger is an Enum.UnitAuraSoundTrigger value and sound carries the
-- unit/spell/file/channel that the old single-table call took.
local legacyAddSound = C_UnitAuras.AddAuraAppliedSound
                    or C_UnitAuras.AddPrivateAuraAppliedSound

local TRIGGER = Enum.UnitAuraSoundTrigger and {
    apply  = Enum.UnitAuraSoundTrigger.Added,
    stack  = Enum.UnitAuraSoundTrigger.ApplicationsIncreased,
    remove = Enum.UnitAuraSoundTrigger.Removed,
}

-- Stack/removal triggers need the newer two-argument API. Older clients can
-- only play on application, so the whole feature stays hidden there.
function CCS.SupportsAuraTriggers()
    return C_UnitAuras.AddAuraSound ~= nil and TRIGGER ~= nil
end

local function callAddAuraSound(unitToken, spellID, path, channel, event)
    local sound = {
        unitToken     = unitToken,
        spellID       = spellID,
        soundFileName = path,
        outputChannel = channel,
    }
    if C_UnitAuras.AddAuraSound and TRIGGER then
        local trigger = TRIGGER[event or "apply"]
        if trigger ~= nil then
            local ok, id = pcall(C_UnitAuras.AddAuraSound, trigger, sound)
            if ok and id then return id end
        end
    end
    -- Older clients only ever played on application, so never use this for
    -- stack/remove or they'd fire at the wrong moment.
    if legacyAddSound and (not event or event == "apply") then
        local ok, id = pcall(legacyAddSound, sound)
        if ok and id then return id end
    end
    return nil
end

local handles = {}
-- Pending work that hit combat/dead lockdown; flushPending() drains them later.
local pendingRefreshAll = false
local pendingRefreshKeys = {}

-- Protected aura-sound APIs are blocked during combat lockdown and while dead.
local function canRegister()
    if InCombatLockdown() then return false end
    if UnitIsDeadOrGhost("player") then return false end
    return true
end

local function unregisterAbility(key)
    if not handles[key] then return end
    if not canRegister() then
        pendingRefreshAll = true
        return
    end
    for _, id in ipairs(handles[key]) do
        pcall(removeAuraSound, id)
    end
    handles[key] = nil
end

-- Returns a flat list of spellIDs. privateID can be scalar, array, or {H=, M=}.
local function getPrivateIDs(ability, diff)
    local pid = ability.privateID
    if not pid then return {} end
    if type(pid) == "table" then
        if pid.H ~= nil or pid.M ~= nil then
            -- H/M split
            local val = pid[diff]
            if not val then return {} end
            if type(val) == "table" then return val end
            return {val}
        end
        -- plain array, same for both diffs
        return pid
    end
    return {pid}
end

local function registerAbility(ability, diff, bossKey)
    if not ability then return end
    if not canRegister() then
        pendingRefreshAll = true
        return
    end
    -- Advanced abilities are gated by "Show non-default" for their boss, or
    -- by the user having opted in (any tick or override set on the ability).
    if ability.advanced then
        if bossKey then
            if not CCS.GetShowAllBoss(bossKey) and not CCS.IsAbilityOptedIn(ability.key) then
                return
            end
        else
            if not CCS.IsAbilityActive(ability.key) then return end
        end
    end
    local ids = getPrivateIDs(ability, diff)
    if #ids == 0 then return end

    -- Pre-12.1 could only attach sounds to private auras; enforce that here.
    if not hasGeneralAuraSounds then
        for _, spellID in ipairs(ids) do
            if not C_UnitAuras.AuraIsPrivate(spellID) then
                if diff then
                    print("|cffff9900CCS:|r " .. ability.key .. " (spellID " .. spellID .. ") is not a private aura — skipping.")
                end
                return
            end
        end
    end

    -- Register one event's sounds under its own storage key.
    local function registerEvent(evAbility, evKey, event)
        -- Clear old handles first, so a sound the user just turned off stops
        -- even when we bail out below with nothing to register.
        if handles[evKey] then unregisterAbility(evKey) end
        local paths = resolveAbilitySounds(evAbility, diff)
        if not paths or #paths == 0 then return end
        handles[evKey] = {}

        for _, spellID in ipairs(ids) do
            for _, path in ipairs(paths) do
                local id = callAddAuraSound("player", spellID, path,
                                            CCS.GetChannel(), event)
                if id then
                    handles[evKey][#handles[evKey] + 1] = id
                end
            end
        end
    end

    -- apply: the ability's own key, so existing settings keep working.
    registerEvent(ability, ability.key, "apply")

    -- stack / remove: same spell IDs, separate keys, no built-in default sound
    -- (the user picks one), so only register when they've enabled it.
    for _, event in ipairs({ "stack", "remove" }) do
        local vKey = ability.key .. CCS.EVENT_SUFFIX[event]
        if CCS.isWarnEnabled(vKey) then
            registerEvent(CCS.MakeEventAbility(ability, event), vKey, event)
        elseif handles[vKey] then
            unregisterAbility(vKey)
        end
    end
end

local function unregisterAll()
    for key in pairs(handles) do
        unregisterAbility(key)
    end
end

local function registerAll()
    local diff = getCurrentDifficulty()
    if not diff then return end
    local instType = getInstanceType()

    if instType == "raid" then
        for _, entry in ipairs(CCS_Spells_Raid) do
            if entry.abilities then
                for _, ability in ipairs(entry.abilities) do
                    registerAbility(ability, diff, entry.bossKey)
                end
            end
        end
    elseif instType == "party" and CCS.MPLUS_ENABLED then
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then
                for _, entry in ipairs(data) do
                    if entry.abilities then
                        for _, ability in ipairs(entry.abilities) do
                            registerAbility(ability, diff, entry.bossKey)
                        end
                    end
                end
            end
        end
    end
end

--------------------------------------------------
-- Refresh queue
--------------------------------------------------

local function flushPending()
    if not canRegister() then
        C_Timer.After(1, flushPending)
        return
    end
    if pendingRefreshAll then
        pendingRefreshAll = false
        pendingRefreshKeys = {}
        unregisterAll()
        registerAll()
        -- Combat re-entered mid-call; retry.
        if pendingRefreshAll then
            C_Timer.After(1, flushPending)
        end
    else
        for key, entry in pairs(pendingRefreshKeys) do
            unregisterAbility(key)
            local diff = getCurrentDifficulty()
            if diff then registerAbility(entry.ability, diff, entry.bossKey) end
        end
        pendingRefreshKeys = {}
    end
end

--------------------------------------------------
-- Public API
--------------------------------------------------

function CCS.RefreshAbility(key, ability, bossKey)
    if InCombatLockdown() then
        pendingRefreshKeys[key] = {ability = ability, bossKey = bossKey}
        return
    end
    unregisterAbility(key)
    local diff = getCurrentDifficulty()
    if diff then registerAbility(ability, diff, bossKey) end
end

function CCS.RefreshAll()
    if InCombatLockdown() then
        pendingRefreshAll = true
        return
    end
    unregisterAll()
    registerAll()
end

-- Alias.
CCS.RefreshSounds = CCS.RefreshAll

function CCS.EnableAll()
    CCS.SetAllWarn(true)
    CCS.SetAllCD(true)
    CCS.RefreshAll()
end

function CCS.DisableAll()
    CCS.SetAllWarn(false)
    CCS.SetAllCD(false)
    CCS.RefreshAll()
end


--------------------------------------------------
-- Debug
--------------------------------------------------

function CCS.DebugProfile()
    local p = CCS.GetProfile()
    local diff = getCurrentDifficulty()
    print("|cffffff00CCS Debug — Profile:|r " .. CCS.GetProfileName() .. "  |cffaaaaaa(diff: " .. (diff or "none") .. ")|r")

    local warned, counted = 0, 0
    for _, entry in ipairs(CCS_Spells) do
        if entry.abilities then
            for _, ability in ipairs(entry.abilities) do
                local warnOn  = CCS.isWarnEnabled(ability.key)
                local warnOvr = CCS.GetWarnOverride(ability.key)
                local hOn     = CCS.IsCDEnabled(ability.key, "H")
                local mOn     = CCS.IsCDEnabled(ability.key, "M")
                local hOvr    = CCS.GetCountdownOverride(ability.key, "H")
                local mOvr    = CCS.GetCountdownOverride(ability.key, "M")
                if warnOn or warnOvr or hOn or mOn or hOvr or mOvr then
                    local parts = {}
                    if warnOn  then parts[#parts+1] = "|cff00ff00warn|r" end
                    if warnOvr then parts[#parts+1] = "|cffaaaaaarwarn=" .. warnOvr .. "|r" end
                    if hOn     then parts[#parts+1] = "|cff00ff00HC|r" end
                    if hOvr    then parts[#parts+1] = "|cffaaaaaaHC=" .. hOvr .. "|r" end
                    if mOn     then parts[#parts+1] = "|cff00ff00M|r" end
                    if mOvr    then parts[#parts+1] = "|cffaaaaaaM=" .. mOvr .. "|r" end
                    print("  " .. ability.key .. ": " .. table.concat(parts, "  "))
                    if warnOn then warned = warned + 1 end
                    if hOn or mOn then counted = counted + 1 end
                end
            end
        end
    end
    print("|cffaaaaaa  " .. warned .. " warn(s), " .. counted .. " countdown(s) enabled.|r")
end

function CCS.DebugSounds()
    local count = 0
    print("|cffffff00CCS Debug — Registered Sounds:|r")
    for key, ids in pairs(handles) do
        print("  " .. key .. ": " .. #ids .. " handle(s) — " .. table.concat(ids, ", "))
        count = count + 1
    end
    if count == 0 then
        print("|cffaaaaaa  No sounds currently registered.|r")
    else
        print("|cffaaaaaa  " .. count .. " ability/abilities registered.|r")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_UNGHOST")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local dbReady = false
local pendingEnterWorld = false

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= addonName then return end

        db = LibStub("AceDB-3.0"):New("CCS_DB", dbDefaults, true)
        applyModule()

        -- Migrate old per-char minimap fields.
        if db.char.minimapAngle ~= nil then
            db.char.minimap.minimapPos = db.char.minimapAngle
            db.char.minimapAngle = nil
        end
        if db.char.minimapHidden ~= nil then
            db.char.minimap.hide = db.char.minimapHidden
            db.char.minimapHidden = nil
        end

        -- move showAllBosses from db.char into the profile (one-shot), then
        -- clear the char store so profile switches aren't overwritten.
        if db.char.showAllBosses then
            local p = CCS.GetProfile()
            for k, v in pairs(db.char.showAllBosses) do
                if p.showAllBosses[k] == nil then p.showAllBosses[k] = v end
            end
            db.char.showAllBosses = nil
        end

        db.RegisterCallback(CCS, "OnProfileChanged", function()
            CCS.RefreshAll()
            if CCS._onProfileChange then CCS._onProfileChange() end
        end)
        db.RegisterCallback(CCS, "OnProfileCopied",  function()
            CCS.RefreshAll()
            if CCS._onProfileChange then CCS._onProfileChange() end
        end)
        db.RegisterCallback(CCS, "OnProfileReset",   function()
            CCS.RefreshAll()
            if CCS._onProfileChange then CCS._onProfileChange() end
        end)

        dbReady = true
        CCS._ready = true
        self:UnregisterEvent("ADDON_LOADED")

        for _, fn in ipairs(CCS._onReadyQueue) do
            local ok, err = pcall(fn)
            if not ok then
                print("|cffff5555CCS:|r OnReady callback error: " .. tostring(err))
            end
        end
        CCS._onReadyQueue = {}

        if pendingEnterWorld then
            pendingEnterWorld = false
            if not canRegister() then
                pendingRefreshAll = true
            else
                unregisterAll()
                C_Timer.After(0, function()
                    if not canRegister() then
                        pendingRefreshAll = true
                    else
                        registerAll()
                    end
                end)
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if not dbReady then
            pendingEnterWorld = true
            return
        end
        if not canRegister() then
            pendingRefreshAll = true
            return
        end
        unregisterAll()
        local instType = getInstanceType()
        if instType ~= "raid" and instType ~= "party" then
            return
        end
        -- One-frame delay so difficultyID is populated.
        C_Timer.After(0, function()
            if not canRegister() then
                pendingRefreshAll = true
            else
                registerAll()
            end
        end)

    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
        if pendingRefreshAll or next(pendingRefreshKeys) then
            flushPending()
        end

    elseif event == "ENCOUNTER_END" then
        -- Sounds persist between pulls.
    end
end)