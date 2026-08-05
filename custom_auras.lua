-- custom_auras.lua
-- User-added spell IDs, stored per profile as IDs per bossKey and injected into
-- the boss's ability list at runtime (treated as normal advanced abilities).
-- Loads after ui.lua (borrows its styling helpers).

--------------------------------------------------
-- Storage
--------------------------------------------------

-- Colon-prefixed keys never collide with built-in ones.
local KEY_PREFIX = "ccs::user::"

-- Key includes the unit so the same spell can be added per unit as its own row
-- with its own settings. Player (default) omits the unit, keeping the original
-- key format so existing saved custom auras are unaffected.
function CCS.CustomAuraKey(bossKey, spellID, unit)
    local base = KEY_PREFIX .. tostring(bossKey) .. "::" .. tostring(spellID)
    if unit and unit ~= "player" then base = base .. "::" .. unit end
    return base
end

function CCS.IsCustomAuraKey(key)
    return type(key) == "string" and key:sub(1, #KEY_PREFIX) == KEY_PREFIX
end

function CCS.GetCustomAuras(bossKey)
    local p = CCS.GetProfile()
    return p.customAuras and p.customAuras[bossKey]
end

local function makeCustomAbility(bossKey, spellID, unit)
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
    return {
        key         = CCS.CustomAuraKey(bossKey, spellID, unit),
        label       = (info and info.name) or ("Spell " .. spellID),
        privateID   = spellID,
        unit        = unit,   -- nil = player
        advanced    = true,   -- no built-in sound, so hidden until opted in
        _custom     = true,
        _customBoss = bossKey,
        _customID   = spellID,
        _customUnit = unit,   -- nil = player; part of this row's identity
    }
end

-- Stored custom auras are either a bare spellID (legacy = player) or
-- { id=, unit= }. Normalise to id, unit.
local function auraFields(v)
    if type(v) == "table" then return v.id, v.unit end
    return v, nil
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

-- Rebuild injected rows from storage. Idempotent (strips old first).
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
        for _, v in ipairs(ids or {}) do
            local id, unit = auraFields(v)
            list[#list + 1] = makeCustomAbility(entry.bossKey, id, unit)
        end
    end)
end

function CCS.AddCustomAura(bossKey, spellID, unit)
    if not bossKey or type(spellID) ~= "number" then return false end
    if unit == "player" then unit = nil end
    local p = CCS.GetProfile()
    p.customAuras = p.customAuras or {}
    local list = p.customAuras[bossKey]
    if not list then list = {}; p.customAuras[bossKey] = list end
    for _, v in ipairs(list) do
        local vid, vunit = auraFields(v)
        if vid == spellID and vunit == unit then return false, "already" end
    end
    list[#list + 1] = unit and { id = spellID, unit = unit } or spellID
    CCS.SyncCustomAuras()
    return true
end

-- Move a custom aura's stored settings from its old key to its new key when
-- its unit changes, including the @stack/@remove trigger keys.
local function migrateAuraSettings(p, bossKey, spellID, oldUnit, newUnit)
    local oldKey = CCS.CustomAuraKey(bossKey, spellID, oldUnit)
    local newKey = CCS.CustomAuraKey(bossKey, spellID, newUnit)
    if oldKey == newKey then return end
    local function move(tbl)
        if not tbl then return end
        tbl[newKey], tbl[oldKey] = tbl[oldKey], nil
    end
    move(p.warnEnabled);      move(p.warnOverride)
    move(p.countdownEnabled); move(p.countdownOverride)
    if p.expandedSpells then move(p.expandedSpells) end
    for _, event in ipairs(CCS.EXTRA_EVENTS) do
        local suf = CCS.EVENT_SUFFIX[event]
        local function moveV(tbl)
            if not tbl then return end
            tbl[newKey .. suf], tbl[oldKey .. suf] = tbl[oldKey .. suf], nil
        end
        moveV(p.warnEnabled); moveV(p.warnOverride)
    end
end

-- Change a user-added aura's unit. Identified by its OLD unit, since the same
-- spell can appear under several units. Moves its stored settings to the new
-- key so the row keeps its sound/tick after the change.
function CCS.SetCustomAuraUnit(bossKey, spellID, oldUnit, newUnit)
    if oldUnit == "player" then oldUnit = nil end
    if newUnit == "player" then newUnit = nil end
    if oldUnit == newUnit then return end
    local p = CCS.GetProfile()
    local list = p.customAuras and p.customAuras[bossKey]
    if not list then return end
    -- reject if the target (spell, newUnit) already exists
    for _, v in ipairs(list) do
        local vid, vunit = auraFields(v)
        if vid == spellID and vunit == newUnit then return end
    end
    for i, v in ipairs(list) do
        local vid, vunit = auraFields(v)
        if vid == spellID and vunit == oldUnit then
            list[i] = newUnit and { id = spellID, unit = newUnit } or spellID
            migrateAuraSettings(p, bossKey, spellID, oldUnit, newUnit)
            CCS.SyncCustomAuras()
            CCS.RefreshSounds()
            if CCS._fullRebuild then CCS._fullRebuild() end
            return
        end
    end
end

function CCS.RemoveCustomAura(bossKey, spellID, unit)
    if unit == "player" then unit = nil end
    local p = CCS.GetProfile()
    local list = p.customAuras and p.customAuras[bossKey]
    if not list then return end
    for i = #list, 1, -1 do
        local vid, vunit = auraFields(list[i])
        if vid == spellID and vunit == unit then table.remove(list, i) end
    end
    if #list == 0 then p.customAuras[bossKey] = nil end

    -- Drop its settings + trigger keys too (no orphans).
    local key = CCS.CustomAuraKey(bossKey, spellID, unit)
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
-- "Add Aura" button expands inline to "Spell ID [__] [Add]". Pooled like ui rows.

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

    local unit = (row._unitDD and row._unitDD:GetValue()) or "player"
    local ok, why = CCS.AddCustomAura(bossKey, spellID, unit)
    if not ok then
        if why == "already" then
            print("|cffffff00CCS:|r Spell " .. spellID .. " is already added to this boss.")
        end
        return
    end

    -- Spell may not be cached yet; show the ID until it loads.
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
    if not info then
        if C_Spell and C_Spell.RequestLoadSpellData then
            C_Spell.RequestLoadSpellData(spellID)
        end
        print("|cffffff00CCS:|r No name found for spell " .. spellID .. " yet. It was added anyway.")
    end

    -- New aura has no sound until one is chosen.
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
        row:SetSize(340, h)

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

        -- Unit dropdown: which unit's aura the new sound listens on.
        local unitDD = CCS.CreateDropdown(row, 84, h - 2, 11)
        unitDD._noGreen = true
        unitDD:SetPoint("LEFT", box, "RIGHT", 6, 0)
        do
            local items = {}
            for _, u in ipairs(CCS.UNIT_ORDER) do
                items[#items + 1] = { label = CCS.UNIT_LABEL[u], value = u }
            end
            unitDD:SetItems(items)
        end
        row._unitDD = unitDD

        local okBtn = CreateFrame("Button", nil, row)
        okBtn:SetSize(44, h)
        okBtn:SetPoint("LEFT", unitDD, "RIGHT", 6, 0)
        styleButton(okBtn, "|cffaaaaaaAdd|r")

        function row:Collapse()
            eb:ClearFocus()
            lbl:Hide(); box:Hide(); unitDD:Hide(); okBtn:Hide()
            addBtn:Show()
        end
        function row:Expand()
            addBtn:Hide()
            lbl:Show(); box:Show(); unitDD:Show(); okBtn:Show()
            unitDD:SetValue("player")
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
        -- No OnEditFocusLost: clicking Add takes focus
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