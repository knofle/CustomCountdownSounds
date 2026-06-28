-- core.lua

local addonName = ...
local LSM = LibStub("LibSharedMedia-3.0")

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

--------------------------------------------------
-- LSM Registration
--------------------------------------------------

local basePath = "Interface\\AddOns\\" .. addonName .. "\\sounds\\"

local lsmSounds = {
    "break","breath","burn","dot","marked","move","soak","spread","targeted","drop","fixate","pull","stack","absorb","debuff","charge","clear","knock","spikes","skull","cross","square","moon","triangle","diamond","star","circle","in","out","right","left"
}

for _, name in ipairs(lsmSounds) do
    LSM:Register("sound", "CCS: " .. name, basePath .. name .. ".ogg")
end


local soundPaths = {}
for _, name in ipairs(lsmSounds) do
    soundPaths[name] = basePath .. name .. ".ogg"
end

local function resolvePath(s)
    if not s then return nil end
    if type(s) ~= "string" then return nil end
    if s:sub(1, 5) == "file:" then
        return basePath .. s:sub(6) .. ".ogg"
    end
    if soundPaths[s] then return soundPaths[s] end
    return LSM:Fetch("sound", s)
end
CCS.ResolvePath = resolvePath

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
    profile = {},
    char = {
        minimap              = { minimapPos = 225, hide = false },
        module               = "raid",
        activeDungeon        = "__all__",
        activeRaid           = "__all__",
        customTimerOverride  = false,
        showAllBosses        = {},
    },
}

-- Initialise the shared raid table; data files append to it.
CCS_Spells_Raid = CCS_Spells_Raid or {}

-- Active M+ dungeons, switched on patch.
local _, _, _, tocVersion = GetBuildInfo()

local mplusDungeons_120 = {
    { key = "magisters_terrace",       label = "Magister's Terrace",      color = "|cffda8b45", data = function() return CCS_Spells_Mplus_MagistersTerrace      end },
    { key = "maisara_caverns",         label = "Maisara Caverns",         color = "|cff7ec87e", data = function() return CCS_Spells_Mplus_MaisaraCaverns         end },
    { key = "nexus_point_xenas",       label = "Nexus-Point Xenas",       color = "|cff6aacdc", data = function() return CCS_Spells_Mplus_NexusPointXenas        end },
    { key = "windrunner_spire",        label = "Windrunner Spire",        color = "|cffe8c46a", data = function() return CCS_Spells_Mplus_WindrunnerSpire        end },
    { key = "algethar_academy",        label = "Algeth'ar Academy",       color = "|cffc17de8", data = function() return CCS_Spells_Mplus_AlgetharAcademy        end },
    { key = "pit_of_saron",            label = "Pit of Saron",            color = "|cff9dbde8", data = function() return CCS_Spells_Mplus_PitOfSaron             end },
    { key = "seat_of_the_triumvirate", label = "Seat of the Triumvirate", color = "|cffdc8fe0", data = function() return CCS_Spells_Mplus_SeatOfTheTriumvirate   end },
    { key = "skyreach",                label = "Skyreach",                color = "|cffe8e06a", data = function() return CCS_Spells_Mplus_Skyreach               end },
}

local mplusDungeons_121 = {
    { key = "murder_row",              label = "Murder Row",              color = "|cffe07a3a", data = function() return CCS_Spells_Mplus_MurderRow             end },
    { key = "den_of_nalorakk",         label = "Den of Nalorakk",         color = "|cff6dab5a", data = function() return CCS_Spells_Mplus_DenOfNalorakk         end },
    { key = "blinding_vale",           label = "The Blinding Vale",       color = "|cff8ae0d4", data = function() return CCS_Spells_Mplus_BlindingVale          end },
    { key = "voidscar_arena",          label = "Voidscar Arena",          color = "|cff8e5acb", data = function() return CCS_Spells_Mplus_VoidscarArena         end },
    { key = "altar_of_fangs",          label = "Altar of Fangs",          color = "|cffc04a4a", data = function() return CCS_Spells_Mplus_AltarOfFangs          end },
    { key = "ruby_life_pools",         label = "Ruby Life Pools",         color = "|cffe04a5a", data = function() return CCS_Spells_Mplus_RubyLifePools         end },
    { key = "temple_of_sethraliss",    label = "Temple of Sethraliss",    color = "|cff5cb46c", data = function() return CCS_Spells_Mplus_TempleOfSethraliss    end },
    { key = "kings_rest",              label = "Kings' Rest",             color = "|cffd4af37", data = function() return CCS_Spells_Mplus_KingsRest             end },
}

CCS.MplusDungeons = (tocVersion >= 120100) and mplusDungeons_121 or mplusDungeons_120

local db

function CCS.GetProfile()
    if not db then return { warnEnabled={}, warnOverride={}, countdownEnabled={}, countdownOverride={} } end
    local p = db.profile
    if rawget(p, "warnEnabled")       == nil then rawset(p, "warnEnabled",       {}) end
    if rawget(p, "warnOverride")      == nil then rawset(p, "warnOverride",       {}) end
    if rawget(p, "countdownEnabled")  == nil then rawset(p, "countdownEnabled",   {}) end
    if rawget(p, "countdownOverride") == nil then rawset(p, "countdownOverride",  {}) end
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

local function applyModule()
    local m = (db and db.char.module) or "raid"
    if not CCS.MPLUS_ENABLED and m == "mplus" then
        if db then db.char.module = "raid" end
        m = "raid"
    end
    if m == "mplus" and CCS.MPLUS_ENABLED then
        local key = (db and db.char.activeDungeon) or "__all__"
        if key == "__all__" then
            local combined = {}
            for _, dungeon in ipairs(CCS.MplusDungeons) do
                local data = dungeon.data()
                if data then
                    for _, entry in ipairs(data) do
                        entry._color = dungeon.color
                        combined[#combined + 1] = entry
                    end
                end
            end
            CCS_Spells = combined
            return
        end
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            if dungeon.key == key then
                local data = dungeon.data()
                if data then
                    for _, entry in ipairs(data) do
                        entry._color = dungeon.color
                    end
                end
                CCS_Spells = data or {}
                return
            end
        end
        -- Stored dungeon no longer exists, reset.
        if db then db.char.activeDungeon = "__all__" end
        local combined = {}
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then
                for _, entry in ipairs(data) do
                    entry._color = dungeon.color
                    combined[#combined + 1] = entry
                end
            end
        end
        CCS_Spells = combined
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

function CCS.GetShowAllBoss(bossKey)
    if not bossKey then return false end
    return CCS.GetChar().showAllBosses[bossKey] == true
end

function CCS.SetShowAllBoss(bossKey, val)
    if not bossKey then return end
    CCS.GetChar().showAllBosses[bossKey] = val or nil
    CCS.RefreshSounds()
end

-- True unless the ability is advanced and its boss's "Show all" is off.
function CCS.IsAbilityActive(abilityKey)
    if not abilityKey then return true end
    if CCS_Spells_Raid then
        for _, entry in ipairs(CCS_Spells_Raid) do
            if entry.abilities then
                for _, ab in ipairs(entry.abilities) do
                    if ab.key == abilityKey then
                        if ab.advanced and not CCS.GetShowAllBoss(entry.bossKey) then
                            return false
                        end
                        return true
                    end
                end
            end
        end
    end
    if CCS.MplusDungeons then
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then
                for _, entry in ipairs(data) do
                    if entry.abilities then
                        for _, ab in ipairs(entry.abilities) do
                            if ab.key == abilityKey then
                                if ab.advanced and not CCS.GetShowAllBoss(entry.bossKey) then
                                    return false
                                end
                                return true
                            end
                        end
                    end
                end
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

-- Iterate abilities for "raid" or "mplus".
local function iterateModuleSpells(module, fn)
    if module == "raid" then
        for _, entry in ipairs(CCS_Spells_Raid) do
            if entry.abilities then
                for _, ability in ipairs(entry.abilities) do fn(ability, false) end
            end
        end
    elseif module == "mplus" then
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then
                for _, entry in ipairs(data) do
                    if entry.abilities then
                        for _, ability in ipairs(entry.abilities) do fn(ability, true) end
                    end
                end
            end
        end
    end
end

function CCS.SetAllWarn(val, module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    iterateModuleSpells(module, function(ability)
        local function fieldHasWarn(f)
            if f == nil then return false end
            if type(f) == "table" then return f[1] ~= nil end
            return true
        end
        local hasDefault = fieldHasWarn(ability.soundH) or fieldHasWarn(ability.soundM)
        local hasOverride = p.warnOverride[ability.key] ~= nil
        -- Bulk-enable skips advanced abilities without an override; bulk-disable still applies.
        if val and ability.advanced and not hasOverride then return end
        if not val or hasDefault or hasOverride then
            p.warnEnabled[ability.key] = val
        end
    end)
end

function CCS.SetAllCD(val, module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    iterateModuleSpells(module, function(ability, isMplus)
        local function hasDefault(diff)
            local s = diff == "M" and ability.soundM or (diff ~= "M" and ability.soundH)
            return type(s) == "table" and s[2] ~= nil
        end
        local function hasOverride(diff)
            return p.countdownOverride[ability.key] and p.countdownOverride[ability.key][diff] ~= nil
        end
        local function isEnabled(diff)
            return p.countdownEnabled[ability.key] and p.countdownEnabled[ability.key][diff] == true
        end
        -- Bulk-enable skips advanced abilities without an override; bulk-disable still applies.
        local anyOverride = hasOverride("H") or hasOverride("M")
        if val and ability.advanced and not anyOverride then return end
        if isMplus then
            if not val or hasDefault("M") or hasOverride("M") then
                p.countdownEnabled[ability.key] = p.countdownEnabled[ability.key] or {}
                p.countdownEnabled[ability.key].M = val
            elseif not val and isEnabled("M") then
                p.countdownEnabled[ability.key].M = false
            end
        else
            if ability.soundH ~= nil or hasOverride("H") or isEnabled("H") then
                if not val or hasDefault("H") or hasOverride("H") then
                    p.countdownEnabled[ability.key] = p.countdownEnabled[ability.key] or {}
                    p.countdownEnabled[ability.key].H = val
                end
            end
            if ability.soundM ~= nil or hasOverride("M") or isEnabled("M") then
                if not val or hasDefault("M") or hasOverride("M") then
                    p.countdownEnabled[ability.key] = p.countdownEnabled[ability.key] or {}
                    p.countdownEnabled[ability.key].M = val
                end
            end
        end
    end)
end

-- Returns "all_on" / "all_off" / "mixed" for the visible abilities' warn flags.
function CCS.GetBulkWarnState(module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    local seen, onCount, offCount = 0, 0, 0
    iterateModuleSpells(module, function(ability)
        local function fieldHasWarn(f)
            if f == nil then return false end
            if type(f) == "table" then return f[1] ~= nil end
            return true
        end
        local hasDefault  = fieldHasWarn(ability.soundH) or fieldHasWarn(ability.soundM)
        local hasOverride = p.warnOverride[ability.key] ~= nil
        if hasDefault or hasOverride then
            -- Advanced w/o override can't be bulk-toggled, so don't count it.
            if ability.advanced and not hasOverride then return end
            seen = seen + 1
            if p.warnEnabled[ability.key] then onCount = onCount + 1 else offCount = offCount + 1 end
        end
    end)
    if seen == 0 then return "all_off" end
    if onCount == seen then return "all_on" end
    if offCount == seen then return "all_off" end
    return "mixed"
end

-- Same shape as GetBulkWarnState, for countdown flags.
function CCS.GetBulkCDState(module)
    module = module or CCS.GetModule()
    local p = CCS.GetProfile()
    local seen, onCount, offCount = 0, 0, 0
    iterateModuleSpells(module, function(ability, isMplus)
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
            if hasDefault(d) or hasOverride(d) then
                if ability.advanced and not hasOverride(d) then
                    -- advanced w/o override: skip
                else
                    seen = seen + 1
                    if isEnabled(d) then onCount = onCount + 1 else offCount = offCount + 1 end
                end
            end
        end
    end)
    if seen == 0 then return "all_off" end
    if onCount == seen then return "all_on" end
    if offCount == seen then return "all_off" end
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
            local p = resolvePath(warnKey)
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
        local ctOn = CCS.GetCustomTimerOverride()
        local cdKey = (ctOn and CCS.GetCountdownOverride(ability.key, diff)) or defaultCD
        if cdKey then
            local p = resolvePath(cdKey)
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
-- Private Aura Registration
--------------------------------------------------

local handles = {}
-- Pending work that hit combat/dead lockdown; flushPending() drains them later.
local pendingRefreshAll = false
local pendingRefreshKeys = {}

-- Protected private-aura APIs are blocked during combat lockdown and while dead.
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
        C_UnitAuras.RemovePrivateAuraAppliedSound(id)
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
    -- Advanced abilities are gated by their boss's "Show all" toggle.
    -- If bossKey is missing, look it up via IsAbilityActive.
    if ability.advanced then
        if bossKey then
            if not CCS.GetShowAllBoss(bossKey) then return end
        else
            if not CCS.IsAbilityActive(ability.key) then return end
        end
    end
    local ids = getPrivateIDs(ability, diff)
    if #ids == 0 then return end

    for _, spellID in ipairs(ids) do
        if not C_UnitAuras.AuraIsPrivate(spellID) then
            if diff then
                print("|cffff9900CCS:|r " .. ability.key .. " (spellID " .. spellID .. ") is not a private aura — skipping.")
            end
            return
        end
    end

    local paths = resolveAbilitySounds(ability, diff)
    if not paths then return end
    -- Wipe any stale handles to avoid double playback from racing refresh paths.
    if handles[ability.key] then unregisterAbility(ability.key) end
    handles[ability.key] = {}

    for _, spellID in ipairs(ids) do
        for _, path in ipairs(paths) do
            local id = C_UnitAuras.AddPrivateAuraAppliedSound({
                unitToken     = "player",
                spellID       = spellID,
                soundFileName = path,
                outputChannel = "Master",
            })
            if id then
                handles[ability.key][#handles[ability.key] + 1] = id
            end
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