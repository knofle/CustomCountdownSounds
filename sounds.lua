-- sounds.lua
-- LibSharedMedia registration and sound path resolution.
-- To add or remove a bundled sound, edit lsmSounds below. Nothing else needs to change.
-- Loaded before core.lua so CCS.ResolvePath exists for everything after it.

local addonName = ...
local LSM = LibStub("LibSharedMedia-3.0")

CCS = CCS or {}

local basePath = "Interface\\AddOns\\" .. addonName .. "\\sounds\\"

local lsmSounds = {
    "break","breath","burn","dot","marked","move","soak","spread","targeted","drop","fixate","pull","stack","safe","absorb","debuff","collect","damage","heal","slow","charge","clear","knock","spikes","skull","cross","square","moon","triangle","diamond","star","circle","in","out","right","left","magic","curse","poison","bleed","taunt"
}

-- The colour goes INTO the registered LSM name, because that name is what every
-- picker displays, including other addons' pickers. Only the "CCS:" tag is
-- coloured here; the sound name itself stays plain in the registered string.
-- (The per-group tint is applied on top, display-only, in CCS's own picker.)
CCS.TAG_COLOR = "|cff9fd6f5"   -- light blue

local function registeredName(n)
    return CCS.TAG_COLOR .. "CCS:|r " .. n
end
CCS.RegisteredSoundName = registeredName

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
-- The picker groups our sounds by theme and tints each group very slightly, so
-- similar sounds sit together and read at a glance without being loud. This is
-- display only: the registered/stored name stays "CCS: <name>", so saved picks
-- and profile strings are unaffected. To move a sound to another group, edit
-- the lists below; anything not listed falls into a neutral group at the end.
--
-- Order of the groups here is the order they appear in the picker.
CCS.SOUND_GROUPS = {
    { color = "|cffe8b3b3", names = { "absorb", "bleed", "curse", "debuff", "dot", "magic", "poison", "slow" } },       -- slight red
    { color = "|cffb3e0b8", names = { "in", "left", "move", "out", "right" } },                                          -- slight green
    { color = "|cffd8b8e8", names = { "break", "burn","collect", "drop", "heal", "soak", "spread", "stack", "taunt" } },            -- slight purple
    { color = "|cffe8dfa8", names = { "breath", "charge", "damage", "fixate", "knock", "marked", "pull", "safe", "spikes", "targeted" } }, -- slight yellow
}

-- Lookup: bare sound name -> { color, order } for its group. Sounds not in any
-- group get no colour and sort last.
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
-- The registered name is also the value stored in a profile, so changing the
-- colour would orphan existing saved picks. Rewrite any stored value that
-- refers to one of our sounds into the current registeredName(). Matching by
-- bare name makes this idempotent AND auto-recolours everything if TAG_COLOR
-- ever changes. "file:" values and other addons' sounds are left alone.
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