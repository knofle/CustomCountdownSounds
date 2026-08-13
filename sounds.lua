-- sounds.lua
-- LibSharedMedia registration + path resolution. Add/remove sounds via lsmSounds.
-- Loaded before core.lua so CCS.ResolvePath exists after.

local addonName = ...
local LSM = LibStub("LibSharedMedia-3.0")

CCS = CCS or {}

local basePath = "Interface\\AddOns\\" .. addonName .. "\\sounds\\"

local lsmSounds = {
    "break","breath","burn","dot","marked","dispel","immune","adds","move","soak","spread","targeted","drop","fixate","pull","stack","safe","absorb","debuff","collect","damage","heal","slow","charge","clear","knock","spikes","skull","cross","square","moon","triangle","diamond","star","circle","in","out","right","left","magic","curse","poison","bleed","taunt"
}

-- Colour is baked into the registered LSM name so "CCS:" shows in other addons'
-- pickers too. Only the tag is coloured; group tint is display-only.
CCS.TAG_COLOR = "|cff9fd6f5"   -- light blue

local function registeredName(n)
    return CCS.TAG_COLOR .. "CCS:|r " .. n
end
CCS.RegisteredSoundName = registeredName

-- Display names for file: sounds (raw .ogg files, NOT registered in LSM). The
-- key is the file value as used in data/overrides ("file:nymticking"); the value
-- is what shows in the dropdown. Anything not listed just gets auto-prettified
-- from its filename.
CCS.FILE_SOUND_LABELS = {
    ["file:nymticking"] = "Drop + Tick",
    ["file:ticking_5s"] = "Ticking",
    ["file:ticking_4s"] = "Ticking",
    ["file.ticking_3s"] = "Ticking",
}

local function stripColor(s)
    return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end
CCS.StripColor = stripColor

local function bareName(s)
    if type(s) ~= "string" then return nil end
    return (stripColor(s)):match("^CCS:%s*(.+)$")
end
CCS.BareSoundName = bareName

for _, name in ipairs(lsmSounds) do
    LSM:Register("sound", registeredName(name), basePath .. name .. ".ogg")
end

--------------------------------------------------
-- Sound grouping + colour (display only)
--------------------------------------------------
-- Picker groups + tint (display only; stored name unchanged). List order =
-- picker order; unlisted sounds fall into a neutral group last.
CCS.SOUND_GROUPS = {
    { color = "|cffe8b3b3", names = { "absorb", "bleed", "curse", "debuff", "dot", "magic", "poison", "slow" } },       -- slight red
    { color = "|cffb3e0b8", names = { "in", "left", "move", "out", "right" } },                                          -- slight green
    { color = "|cffd8b8e8", names = { "break", "burn","collect", "dispel", "drop", "heal", "soak", "spread", "stack", "taunt" } },            -- slight purple
    { color = "|cffe8dfa8", names = { "adds", "breath", "charge", "damage", "fixate","immune", "knock", "marked", "pull", "safe", "spikes", "targeted" } }, -- slight yellow
}

-- bare name -> { color, order }. Ungrouped = no colour, sorts last.
CCS.SOUND_GROUP_OF = {}
for gi, group in ipairs(CCS.SOUND_GROUPS) do
    for ni, name in ipairs(group.names) do
        CCS.SOUND_GROUP_OF[name] = { color = group.color, group = gi, order = ni }
    end
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
    local bare = bareName(s)
    if bare and soundPaths[bare] then return soundPaths[bare] end
    if soundPaths[s] then return soundPaths[s] end
    return LSM:Fetch("sound", s)
end
CCS.ResolvePath = resolvePath

--------------------------------------------------
-- Migration
--------------------------------------------------
-- Rewrite stored picks to the current registeredName(). Idempotent, matches by
-- bare name (auto-recolours). Leaves file: and other addons' sounds alone.
local ourNames = {}
for _, n in ipairs(lsmSounds) do ourNames[n] = true end

local function fixValue(v)
    if type(v) ~= "string" then return v end
    if v:sub(1, 5) == "file:" then return v end
    local bare = bareName(v)
    if bare and ourNames[bare] then return registeredName(bare) end
    return v
end

function CCS.MigrateSoundNames()
    local prof = CCS.GetProfile and CCS.GetProfile()
    if not prof then return end
    if prof.warnOverride then
        for k, v in pairs(prof.warnOverride) do prof.warnOverride[k] = fixValue(v) end
    end
    if prof.countdownOverride then
        for _, co in pairs(prof.countdownOverride) do
            if type(co) == "table" then
                co.H = fixValue(co.H)
                co.M = fixValue(co.M)
            end
        end
    end
end