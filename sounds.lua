-- sounds.lua
-- LibSharedMedia registration and sound path resolution.
-- To add or remove a bundled sound, edit lsmSounds below. Nothing else needs to change.
-- Loaded before core.lua so CCS.ResolvePath exists for everything after it.

local addonName = ...
local LSM = LibStub("LibSharedMedia-3.0")

CCS = CCS or {}

local basePath = "Interface\\AddOns\\" .. addonName .. "\\sounds\\"

local lsmSounds = {
    "break","breath","burn","dot","marked","move","soak","spread","targeted","drop","fixate","pull","stack","absorb","debuff","charge","clear","knock","spikes","skull","cross","square","moon","triangle","diamond","star","circle","in","out","right","left","magic","curse","poison","bleed"
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