-- custom_auras.lua
-- User-added spell IDs.
--
-- A boss can carry extra spell IDs the user adds themselves. They are stored
-- per profile as a list of IDs per bossKey, then injected into that boss's
-- ability list at runtime, so registration, search, bulk toggles and the test
-- commands treat them as ordinary advanced abilities without needing to know
-- they exist.
--
-- Loads after ui.lua: the button factory below borrows its styling helpers.

--------------------------------------------------
-- Storage
--------------------------------------------------

-- Colons never appear in data-file keys, so a user aura can never collide with
-- a built-in one, and the suffix stripping in CCS.BaseKey leaves it alone.
local KEY_PREFIX = "ccs::user::"

function CCS.CustomAuraKey(bossKey, spellID)
    return KEY_PREFIX .. tostring(bossKey) .. "::" .. tostring(spellID)
end

function CCS.IsCustomAuraKey(key)
    return type(key) == "string" and key:sub(1, #KEY_PREFIX) == KEY_PREFIX
end

function CCS.GetCustomAuras(bossKey)
    local p = CCS.GetProfile()
    return p.customAuras and p.customAuras[bossKey]
end

local function makeCustomAbility(bossKey, spellID)
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
    return {
        key         = CCS.CustomAuraKey(bossKey, spellID),
        label       = (info and info.name) or ("Spell " .. spellID),
        privateID   = spellID,
        advanced    = true,   -- no built-in sound, so hidden until opted in
        _custom     = true,
        _customBoss = bossKey,
        _customID   = spellID,
    }
end

-- Every section entry across raid and dungeons.
local function iterateEntries(fn)
    for _, entry in ipairs(CCS_Spells_Raid or {}) do fn(entry) end
    for _, dungeon in ipairs(CCS.MplusDungeons or {}) do
        local data = dungeon.data()
        if data then
            for _, entry in ipairs(data) do fn(entry) end
        end
    end
end

-- Rebuild the injected rows from the stored list. Safe to call repeatedly:
-- previously injected rows are stripped first, so nothing accumulates.
function CCS.SyncCustomAuras()
    iterateEntries(function(entry)
        if not entry.bossKey then return end
        local list = entry.abilities
        local ids  = CCS.GetCustomAuras(entry.bossKey)
        if not list then
            if not ids or #ids == 0 then return end
            list = {}
            entry.abilities = list
        end
        for i = #list, 1, -1 do
            if list[i]._custom then table.remove(list, i) end
        end
        for _, spellID in ipairs(ids or {}) do
            list[#list + 1] = makeCustomAbility(entry.bossKey, spellID)
        end
    end)
end

function CCS.AddCustomAura(bossKey, spellID)
    if not bossKey or type(spellID) ~= "number" then return false end
    local p = CCS.GetProfile()
    p.customAuras = p.customAuras or {}
    local list = p.customAuras[bossKey]
    if not list then list = {}; p.customAuras[bossKey] = list end
    for _, id in ipairs(list) do
        if id == spellID then return false, "already" end
    end
    list[#list + 1] = spellID
    CCS.SyncCustomAuras()
    return true
end

function CCS.RemoveCustomAura(bossKey, spellID)
    local p = CCS.GetProfile()
    local list = p.customAuras and p.customAuras[bossKey]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == spellID then table.remove(list, i) end
    end
    if #list == 0 then p.customAuras[bossKey] = nil end

    -- Drop its settings too, including the extra trigger keys, so removing an
    -- aura doesn't leave orphaned entries behind in the profile.
    local key = CCS.CustomAuraKey(bossKey, spellID)
    p.warnEnabled[key], p.warnOverride[key] = nil, nil
    p.countdownEnabled[key], p.countdownOverride[key] = nil, nil
    if p.expandedSpells then p.expandedSpells[key] = nil end
    for _, event in ipairs(CCS.EXTRA_EVENTS) do
        local vKey = key .. CCS.EVENT_SUFFIX[event]
        p.warnEnabled[vKey], p.warnOverride[vKey] = nil, nil
    end
    CCS.SyncCustomAuras()
end

--------------------------------------------------
-- "Add Aura" row
--------------------------------------------------
-- Collapsed it is a single "Add Aura" button. Clicking it expands the row into
-- an inline "Spell ID [____] [Add]" entry, so adding a spell never leaves the
-- list. Pooled the same way ui.lua pools its rows, and styled with ui.lua's
-- helpers so it matches the buttons beside it.

local _addRows = {}

local function commitSpellID(row, text)
    local bossKey = row._bossKey
    if not bossKey then return end
    local spellID = tonumber(text and text:match("%d+"))
    if not spellID or spellID <= 0 then
        print("|cffffff00CCS:|r That isn't a valid spell ID.")
        return
    end
    if InCombatLockdown() then
        print("|cffffff00CCS:|r Cannot change settings during combat.")
        return
    end

    local ok, why = CCS.AddCustomAura(bossKey, spellID)
    if not ok then
        if why == "already" then
            print("|cffffff00CCS:|r Spell " .. spellID .. " is already added to this boss.")
        end
        return
    end

    -- Spell data may not be cached yet, in which case the row shows the ID
    -- until it loads. Ask for it and say so rather than rejecting the entry.
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
    if not info then
        if C_Spell and C_Spell.RequestLoadSpellData then
            C_Spell.RequestLoadSpellData(spellID)
        end
        print("|cffffff00CCS:|r No name found for spell " .. spellID .. " yet. It was added anyway.")
    end

    -- A new aura ships with no sound, so nothing plays until one is chosen.
    print("|cffffff00CCS:|r Added "
        .. ((info and info.name) or ("spell " .. spellID))
        .. ". Tick its box and pick a sound to start using it.")

    CCS.RefreshSounds()
    if CCS._fullRebuild then CCS._fullRebuild() end
end

-- Shared look for the two small buttons on this row.
local function styleButton(btn, label)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetColorTexture(0.06, 0.06, 0.06, 0.95)
    local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
    border:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    local fs = CCS._makeFontString(btn, "OVERLAY", "GameFontNormalSmall")
    fs:SetAllPoints(); fs:SetJustifyH("CENTER"); fs:SetJustifyV("MIDDLE")
    fs:SetText(label)
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.08)
    if CCS._addBorderHighlight then CCS._addBorderHighlight(btn, border) end
    return fs
end

function CCS.AcquireAddAuraButton(parent, idx)
    local row = _addRows[idx]
    if not row then
        local h = CCS.ROW_HEIGHT or 22
        row = CreateFrame("Frame", nil, parent)
        row:SetSize(240, h)

        -- Collapsed state.
        local addBtn = CreateFrame("Button", nil, row)
        addBtn:SetSize(96, h)
        addBtn:SetPoint("LEFT", row, "LEFT", 0, 0)
        styleButton(addBtn, "|cffaaaaaaAdd Aura|r")
        if CCS._addTooltip then
            CCS._addTooltip(addBtn, "Add Aura",
                "Track a spell ID that isn't in the list.")
        end

        -- Expanded state: label, entry box, confirm.
        local lbl = CCS._makeFontString(row, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT", row, "LEFT", 0, 0)
        lbl:SetText("|cffaaaaaaSpell ID|r")

        local box = CreateFrame("Frame", nil, row, "BackdropTemplate")
        box:SetSize(74, h - 4)
        box:SetPoint("LEFT", lbl, "RIGHT", 6, 0)
        box:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2,
        })
        box:SetBackdropColor(0.1, 0.1, 0.1, 1)
        box:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

        local eb = CreateFrame("EditBox", nil, box)
        eb:SetAllPoints()
        eb:SetAutoFocus(false)
        eb:SetNumeric(true)
        eb:SetMaxLetters(9)
        eb:SetTextInsets(5, 5, 0, 0)
        eb:SetFont(CCS.FONT_REGULAR, 11, "")
        eb:SetTextColor(1, 1, 1, 1)

        local okBtn = CreateFrame("Button", nil, row)
        okBtn:SetSize(44, h)
        okBtn:SetPoint("LEFT", box, "RIGHT", 6, 0)
        styleButton(okBtn, "|cffaaaaaaAdd|r")

        function row:Collapse()
            eb:ClearFocus()
            lbl:Hide(); box:Hide(); okBtn:Hide()
            addBtn:Show()
        end
        function row:Expand()
            addBtn:Hide()
            lbl:Show(); box:Show(); okBtn:Show()
            eb:SetText(""); eb:SetFocus()
        end

        addBtn:SetScript("OnClick", function() row:Expand() end)
        okBtn:SetScript("OnClick", function()
            local t = eb:GetText()
            row:Collapse()
            commitSpellID(row, t)
        end)
        eb:SetScript("OnEnterPressed", function(self)
            local t = self:GetText()
            row:Collapse()
            commitSpellID(row, t)
        end)
        -- Deliberately no OnEditFocusLost handler: clicking Add takes focus
        -- off the box, so collapsing there would hide the button mid-click.
        -- Escape, Enter, Add or the next rebuild all close it.
        eb:SetScript("OnEscapePressed", function() row:Collapse() end)

        _addRows[idx] = row
    end
    -- Every rebuild starts collapsed; a half-typed entry doesn't survive one.
    row:Collapse()
    return row
end

function CCS.HideAddAuraButtonsFrom(idx)
    for i = idx, #_addRows do _addRows[i]:Hide() end
end