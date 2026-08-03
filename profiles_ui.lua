-- profiles_ui.lua
-- new, copy, rename, delete, plus profile export/import (LibSerialize+LibDeflate).

local addonName = ...
local CCS_CreateDropdown = CCS.CreateDropdown

-- Route labels through the font registry so they restyle with the addon.
local function fstring(parent, layer, obj)
    if CCS._makeFontString then return CCS._makeFontString(parent, layer, obj) end
    return parent:CreateFontString(nil, layer, obj)
end

local COL_BG        = { 0.11, 0.075, 0.075, 1 }  -- dark grey with a slight red hue
local COL_ROW       = { 0.13, 0.13, 0.13, 1 }
local COL_BORDER    = { 0.25, 0.25, 0.25, 1 }
local COL_EDGE      = { 0.25, 0.25, 0.25, 1 }     -- outer window edge (same as internal borders)
local BOX_W         = 524   -- paste box width
local BOX_H         = 91    -- paste box height

-- small helper: a flat button matching the rest of the UI
local function makeFlatButton(parent, w, h, text)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetColorTexture(0.15, 0.15, 0.15, 1)
    local border = CreateFrame("Frame", nil, b, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    border:SetBackdropBorderColor(unpack(COL_BORDER))
    local fs = fstring(b, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("CENTER"); fs:SetText(text)
    b._fs = fs; b._border = border
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.08)
    return b
end

local panel

local function refreshProfileList()
    if not panel then return end
    local active = CCS.GetProfileName()
    local names = CCS.GetProfileNames()

    local items = {}
    for _, n in ipairs(names) do items[#items + 1] = { label = n, value = n } end
    panel.profileDD:SetItems(items)
    panel.profileDD:SetValue(active)

    -- Delete dropdown: every profile except the active one.
    local delItems = { { label = "Select to delete...", value = "__none__" } }
    for _, n in ipairs(names) do
        if n ~= active then delItems[#delItems + 1] = { label = n, value = n } end
    end
    if panel.deleteDD then
        panel.deleteDD:SetItems(delItems)
        panel.deleteDD:SetValue("__none__")
    end
end

-- StaticPopups for name entry ------------------------------------------------

StaticPopupDialogs["CCS_PROFILE_NEW"] = {
    text = "New profile name:",
    button1 = ACCEPT, button2 = CANCEL,
    hasEditBox = true, editBoxWidth = 200,
    OnAccept = function(self)
        local name = (self.editBox or self.EditBox):GetText():gsub("^%s+",""):gsub("%s+$","")
        if name ~= "" then CCS.NewProfile(name); refreshProfileList() end
    end,
    EditBoxOnEnterPressed = function(self)
        local name = self:GetText():gsub("^%s+",""):gsub("%s+$","")
        if name ~= "" then CCS.NewProfile(name); refreshProfileList() end
        self:GetParent():Hide()
    end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

StaticPopupDialogs["CCS_PROFILE_COPY"] = {
    text = "Copy \"%s\" into a new profile named:",
    button1 = ACCEPT, button2 = CANCEL,
    hasEditBox = true, editBoxWidth = 200,
    OnAccept = function(self)
        local name = (self.editBox or self.EditBox):GetText():gsub("^%s+",""):gsub("%s+$","")
        local src  = self.data
        if name ~= "" and src then
            CCS.NewProfile(name)       -- create + switch to it
            CCS.CopyProfile(src)       -- copy source into the now-active profile
            refreshProfileList()
        end
    end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

StaticPopupDialogs["CCS_PROFILE_DELETE"] = {
    text = "Delete profile \"%s\"? This cannot be undone.",
    button1 = DELETE, button2 = CANCEL,
    OnAccept = function(self)
        local name = self.data
        if name and name ~= CCS.GetProfileName() then
            CCS.DeleteProfile(name); refreshProfileList()
        elseif name then
            print("|cffffff00CCS:|r Can't delete the active profile. Switch first.")
        end
    end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

StaticPopupDialogs["CCS_PROFILE_RENAME"] = {
    text = "Rename \"%s\" to:",
    button1 = ACCEPT, button2 = CANCEL,
    hasEditBox = true, editBoxWidth = 200,
    OnAccept = function(self)
        local newName = (self.editBox or self.EditBox):GetText():gsub("^%s+",""):gsub("%s+$","")
        local old = self.data
        if newName ~= "" and old then
            -- AceDB has no rename: copy old into a new name, then delete old.
            local wasActive = (old == CCS.GetProfileName())
            CCS.NewProfile(newName)
            CCS.CopyProfile(old)
            if not wasActive then CCS.SetActiveProfile(CCS.GetProfileName()) end
            CCS.DeleteProfile(old)
            refreshProfileList()
        end
    end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

-- Import target picker (replace vs save-as-new) ----

StaticPopupDialogs["CCS_IMPORT_TARGET"] = {
    text = "Import profile \"%s\"?\n\nSave as new keeps your current profiles.\nOverwrite replaces the profile you're on now.",
    button1 = "Save as new",
    button2 = CANCEL,
    button3 = "Overwrite current",
    hasEditBox = true, editBoxWidth = 200,
    OnShow = function(self)
        local eb = self.editBox or self.EditBox
        if eb then eb:SetText(self.data and self.data.name or "Imported") end
    end,
    OnAccept = function(self)  -- save as new
        local p = self.data
        local eb = self.editBox or self.EditBox
        local name = (eb and eb:GetText() or p.name):gsub("^%s+",""):gsub("%s+$","")
        if name == "" then name = p.name or "Imported" end
        local ok, err = CCS.ImportProfile(p, name)
        if ok then print("|cffffff00CCS:|r Imported into |cff00ff00" .. name .. "|r.")
        else print("|cffffff00CCS:|r Import failed - " .. (err or "unknown")) end
        refreshProfileList()
    end,
    OnAlt = function(self)  -- overwrite current
        local ok, err = CCS.ImportProfile(self.data, CCS.GetProfileName())
        if ok then print("|cffffff00CCS:|r Overwrote the current profile.")
        else print("|cffffff00CCS:|r Import failed - " .. (err or "unknown")) end
        refreshProfileList()
    end,
    timeout = 0, whileDead = true, hideOnEscape = true, exclusive = true,
}

-- Scrollable checkbox list with an "All" toggle. :SetItems, :GetChecked, :SetOnChange.
local function makeCheckList(parent, w, h, title)
    local ROW_H = 16
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetSize(w, h)
    box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    box:SetBackdropColor(0.05, 0.05, 0.05, 1)
    box:SetBackdropBorderColor(unpack(COL_BORDER))

    local lbl = fstring(box, "ARTWORK", "GameFontNormalSmall")
    lbl:SetPoint("BOTTOMLEFT", box, "TOPLEFT", 0, 3)
    lbl:SetText("|cffcccccc" .. title .. "|r")

    local scroll = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -22, 4)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(w - 26, h)
    scroll:SetScrollChild(content)

    box._rows = {}
    box._checked = {}
    box._onChange = nil

    local function fireChange() if box._onChange then box._onChange() end end

    -- reused row pool
    local function acquireRow(i)
        local row = box._rows[i]
        if not row then
            row = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
            row:SetSize(ROW_H, ROW_H)
            if CCS._stripCheckBorder then CCS._stripCheckBorder(row) end
            row._fs = fstring(row, "ARTWORK", "GameFontNormalSmall")
            row._fs:SetPoint("LEFT", row, "RIGHT", 2, 0)
            box._rows[i] = row
        end
        return row
    end

    -- item 1 = All; 2..n = instances.
    function box:SetItems(names)
        box._names = names
        local total = #names + 1
        for i = 1, total do
            local row = acquireRow(i)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -(i-1)*ROW_H)
            local isAll = (i == 1)
            local name = isAll and "All" or names[i-1]
            row._name = name
            row._isAll = isAll
            row._fs:SetText(isAll and "|cffffffffAll|r" or name)
            row:SetChecked(box._checked[name] and true or false)
            row:SetScript("OnClick", function(self)
                local on = self:GetChecked() and true or false
                if isAll then
                    for _, n in ipairs(names) do box._checked[n] = on end
                    box._checked["All"] = on
                    for j = 2, total do box._rows[j]:SetChecked(on) end
                else
                    box._checked[name] = on
                    if not on then
                        box._checked["All"] = false
                        box._rows[1]:SetChecked(false)
                    else
                        -- if every instance is now ticked, tick All too
                        local allOn = true
                        for _, n in ipairs(names) do if not box._checked[n] then allOn = false break end end
                        box._checked["All"] = allOn
                        box._rows[1]:SetChecked(allOn)
                    end
                end
                fireChange()
            end)
            row:Show()
        end
        for i = total + 1, #box._rows do box._rows[i]:Hide() end
        content:SetHeight(math.max(h, total * ROW_H))
    end

    -- ticked instance names (not "All")
    function box:GetChecked()
        local out = {}
        for _, n in ipairs(box._names or {}) do
            if box._checked[n] then out[n] = true end
        end
        return out
    end

    function box:ClearChecked()
        box._checked = {}
        for _, row in ipairs(box._rows) do row:SetChecked(false) end
    end

    function box:SetOnChange(fn) box._onChange = fn end
    return box
end

-- Build the window -----------------------------------------------------------

local function build()
    panel = CreateFrame("Frame", "CCSProfilesWindow", UIParent, "BackdropTemplate")
    tinsert(UISpecialFrames, "CCSProfilesWindow")  -- close on Esc
    panel:SetSize(546, 600)
    panel:SetPoint("TOPLEFT", UIParent, "CENTER", -273, 220)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(50)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
    })
    panel:SetBackdropColor(unpack(COL_BG))
    panel:SetBackdropBorderColor(unpack(COL_EDGE))
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    if CCS.AddShadow then CCS.AddShadow(panel) end
    panel:Hide()

    -- Darker band behind the profile selector (bottom set once expHeading exists).
    local topBand = panel:CreateTexture(nil, "BACKGROUND", nil, 1)
    topBand:SetColorTexture(0, 0, 0, 0.28)

    local title = fstring(panel, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -14)
    title:SetText("Profiles")

    -- close X (bare, matches main window)
    local close = CreateFrame("Button", nil, panel)
    close:SetSize(22, 22); close:SetPoint("TOPRIGHT", -6, -6)
    local cx = close:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    cx:SetPoint("CENTER"); cx:SetText("|cffb0b0b0\195\151|r")
    close:SetScript("OnEnter", function() cx:SetText("|cffffffff\195\151|r") end)
    close:SetScript("OnLeave", function() cx:SetText("|cffb0b0b0\195\151|r") end)
    close:SetScript("OnClick", function() panel:Hide() end)

    -- active profile dropdown
    local ddLbl = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    ddLbl:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -14)
    ddLbl:SetText("|cffccccccActive profile|r")

    panel.profileDD = CCS_CreateDropdown(panel, 200, 22, 12)
    panel.profileDD._noScroll = true
    panel.profileDD:SetPoint("TOPLEFT", ddLbl, "BOTTOMLEFT", 0, -4)
    panel.profileDD._noGreen = true
    panel.profileDD:SetOnSelect(function(v)
        if v and v ~= CCS.GetProfileName() then
            CCS.SetActiveProfile(v)
            refreshProfileList()
        end
    end)

    -- management buttons row
    local newBtn    = makeFlatButton(panel, 64, 22, "New")
    local copyBtn   = makeFlatButton(panel, 64, 22, "Copy")
    local renameBtn = makeFlatButton(panel, 64, 22, "Rename")
    newBtn:SetPoint("TOPLEFT", panel.profileDD, "BOTTOMLEFT", 0, -10)
    copyBtn:SetPoint("LEFT", newBtn, "RIGHT", 6, 0)
    renameBtn:SetPoint("LEFT", copyBtn, "RIGHT", 6, 0)

    newBtn:SetScript("OnClick", function() StaticPopup_Show("CCS_PROFILE_NEW") end)
    copyBtn:SetScript("OnClick", function()
        local dlg = StaticPopup_Show("CCS_PROFILE_COPY", CCS.GetProfileName())
        if dlg then dlg.data = CCS.GetProfileName() end
    end)
    renameBtn:SetScript("OnClick", function()
        local dlg = StaticPopup_Show("CCS_PROFILE_RENAME", CCS.GetProfileName())
        if dlg then dlg.data = CCS.GetProfileName() end
    end)

    -- delete dropdown: pick any OTHER profile to delete (can't delete active)
    local delLbl = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    delLbl:SetPoint("LEFT", renameBtn, "RIGHT", 12, 0)
    delLbl:SetText("|cffccccccDelete|r")

    panel.deleteDD = CCS_CreateDropdown(panel, 160, 22, 12)
    panel.deleteDD._noScroll = true
    panel.deleteDD:SetPoint("LEFT", delLbl, "RIGHT", 6, 0)
    panel.deleteDD._noGreen = true
    panel.deleteDD:SetOnSelect(function(v)
        if v and v ~= "__none__" and v ~= CCS.GetProfileName() then
            local dlg = StaticPopup_Show("CCS_PROFILE_DELETE", v)
            if dlg then dlg.data = v end
            panel.deleteDD:SetValue("__none__")  -- reset the picker
        end
    end)

    -- export box
    -- "Export" heading at the top of the section.
    local expHeading = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    expHeading:SetPoint("TOPLEFT", newBtn, "BOTTOMLEFT", 0, -14)
    expHeading:SetText("")   -- spacer: keeps the padding, no visible heading
    -- Close the top band just above the season dropdown / export section.
    -- Band bottom sits just above the season dropdown.
    topBand:SetPoint("TOPLEFT",  panel, "TOPLEFT",   2, -2)
    topBand:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)
    topBand:SetPoint("BOTTOM",   expHeading, "BOTTOM", 0, -4)

    -- Thin light line along the band's bottom edge to reinforce the split.
    local topBandLine = panel:CreateTexture(nil, "BACKGROUND", nil, 2)
    topBandLine:SetColorTexture(1, 1, 1, 0.12)
    topBandLine:SetHeight(1)
    topBandLine:SetPoint("LEFT",  topBand, "BOTTOMLEFT",  0, 0)
    topBandLine:SetPoint("RIGHT", topBand, "BOTTOMRIGHT", 0, 0)

    -- Paste box created here, anchored below the checklists/Generate later.
    local expLbl = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    expLbl:SetText("|cffccccccExport (copy this and share it)|r")

    local expFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    expFrame:SetSize(BOX_W, BOX_H)
    expFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    expFrame:SetBackdropColor(0.05, 0.05, 0.05, 1)
    expFrame:SetBackdropBorderColor(unpack(COL_BORDER))

    local expScroll = CreateFrame("ScrollFrame", nil, expFrame, "UIPanelScrollFrameTemplate")
    expScroll:SetPoint("TOPLEFT", 6, -4)
    expScroll:SetPoint("BOTTOMRIGHT", -24, 4)

    local expBox = CreateFrame("EditBox", nil, expScroll)
    expBox:SetMultiLine(true)
    local _bf = select(1, GameFontHighlightSmall:GetFont())
    expBox:SetFont(_bf, 10, "")
    expBox:SetWidth(BOX_W - 34)   -- fixed width forces wrapping instead of growth
    expBox:SetHeight(BOX_H - 8)
    expBox:SetAutoFocus(false)
    expScroll:SetScrollChild(expBox)
    expBox:SetScript("OnEscapePressed", expBox.ClearFocus)
    -- select-all on focus for easy copying, but fully editable (clearable)
    expBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    expFrame:EnableMouse(true)
    expFrame:SetScript("OnMouseDown", function() expBox:SetFocus() end)
    panel.expBox = expBox

    local expBtn = makeFlatButton(panel, 90, 22, "Generate")
    -- anchored below the checklists (set after they exist)

    -- Season dropdown swaps the check lists; only ticked instances export.
    local selSeason = CCS.GetSeason and CCS.GetSeason() or "S2"

    local seasonDD = CCS_CreateDropdown(panel, 90, 20, 11)
    seasonDD._noGreen = true; seasonDD._noScroll = true
    seasonDD:SetPoint("TOPLEFT", expHeading, "BOTTOMLEFT", 0, -8)
    seasonDD:SetItems({ { label = "Season 1", value = "S1" }, { label = "Season 2", value = "S2" } })

    local raidList = makeCheckList(panel, 190, 96, "Raids")
    raidList:SetPoint("TOPLEFT", seasonDD, "BOTTOMLEFT", 0, -22)
    local dungeonList = makeCheckList(panel, 190, 96, "Dungeons")
    dungeonList:SetPoint("LEFT", raidList, "RIGHT", 24, 0)

    -- Generate sits below the checklists; the paste box + label below Generate.
    expBtn:SetPoint("TOPLEFT", raidList, "BOTTOMLEFT", 0, -10)
    expLbl:SetPoint("TOPLEFT", expBtn, "BOTTOMLEFT", 0, -12)
    expFrame:SetPoint("TOPLEFT", expLbl, "BOTTOMLEFT", 0, -4)

    local function loadSeasonLists(season)
        local raids, dungeons = CCS.GetSeasonInstances(season)
        raidList:ClearChecked();    raidList:SetItems(raids)
        dungeonList:ClearChecked(); dungeonList:SetItems(dungeons)
    end
    seasonDD:SetOnSelect(function(v) selSeason = v; loadSeasonLists(v) end)
    seasonDD:SetValue(selSeason)
    loadSeasonLists(selSeason)

    expBtn:SetScript("OnClick", function()
        local selected = {}
        for name in pairs(raidList:GetChecked())    do selected[name] = true end
        for name in pairs(dungeonList:GetChecked()) do selected[name] = true end
        if not next(selected) then
            print("|cffffff00CCS:|r Pick at least one raid or dungeon to export.")
            return
        end
        local s, err = CCS.ExportProfileFiltered(nil, selected)
        if s then
            expBox:SetText(s)
            expBox:SetFocus(); expBox:HighlightText()
        else
            print("|cffffff00CCS:|r Export failed - " .. (err or "unknown"))
        end
    end)

    -- import box
    local impLbl = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    impLbl:SetPoint("TOPLEFT", expFrame, "BOTTOMLEFT", 0, -14)
    impLbl:SetText("|cffccccccImport (paste a string, then Import)|r")

    local impFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    impFrame:SetPoint("TOPLEFT", impLbl, "BOTTOMLEFT", 0, -4)
    impFrame:SetSize(BOX_W, BOX_H)
    impFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    impFrame:SetBackdropColor(0.05, 0.05, 0.05, 1)
    impFrame:SetBackdropBorderColor(unpack(COL_BORDER))

    local impScroll = CreateFrame("ScrollFrame", nil, impFrame, "UIPanelScrollFrameTemplate")
    impScroll:SetPoint("TOPLEFT", 6, -4)
    impScroll:SetPoint("BOTTOMRIGHT", -24, 4)

    local impBox = CreateFrame("EditBox", nil, impScroll)
    impBox:SetMultiLine(true)
    impBox:SetFont(_bf, 10, "")
    impBox:SetWidth(BOX_W - 34)
    impBox:SetHeight(BOX_H - 8)     -- fill the box so the whole area is clickable
    impBox:SetAutoFocus(false)
    impScroll:SetScrollChild(impBox)
    impBox:SetScript("OnEscapePressed", impBox.ClearFocus)
    -- clicking anywhere in the frame focuses the box for pasting
    impFrame:EnableMouse(true)
    impFrame:SetScript("OnMouseDown", function() impBox:SetFocus() end)
    panel.impBox = impBox

    -- Green preview: which instances the pasted string will bring in.
    local impPreview = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    impPreview:SetPoint("TOPLEFT", impFrame, "BOTTOMLEFT", 0, -6)
    impPreview:SetWidth(BOX_W)
    impPreview:SetJustifyH("LEFT")
    impPreview:SetText("")

    -- Instances a decoded payload touches, from all its ability-keyed tables.
    local function payloadInstances(payload)
        local keys = {}
        for _, tbl in ipairs({ "warnEnabled", "warnOverride", "countdownEnabled",
                               "countdownOverride", "showAllBosses", "customAuras" }) do
            if type(payload[tbl]) == "table" then
                for k in pairs(payload[tbl]) do keys[k] = true end
            end
        end
        return CCS.InstancesForKeys and CCS.InstancesForKeys(keys) or {}
    end

    local function updatePreview()
        local payload = CCS.DecodeProfile(impBox:GetText())
        if not payload then impPreview:SetText(""); return end
        local names = payloadInstances(payload)
        if #names == 0 then
            impPreview:SetText("|cff88cc88Ready to import (no instance-specific settings).|r")
        else
            impPreview:SetText("|cff66cc66Importing: " .. table.concat(names, ", ") .. "|r")
        end
    end
    impBox:SetScript("OnTextChanged", updatePreview)

    local impBtn = makeFlatButton(panel, 90, 22, "Import")
    impBtn:SetPoint("TOPLEFT", impPreview, "BOTTOMLEFT", 0, -6)
    impBtn:SetScript("OnClick", function()
        local payload, err = CCS.DecodeProfile(impBox:GetText())
        if not payload then
            print("|cffffff00CCS:|r Import failed - " .. (err or "unknown"))
            return
        end
        impBox:SetText("")
        impPreview:SetText("")
        local dlg = StaticPopup_Show("CCS_IMPORT_TARGET", payload.name or "Imported")
        if dlg then dlg.data = payload end
    end)

    return panel
end

-- Scale the profile window to match the addon's scale setting, keeping the
-- top-left corner fixed so it grows toward the bottom-right like the main window.
function CCS._applyProfilesScale(v)
    if not panel then return end
    v = v or (CCS.GetScale and CCS.GetScale() or 1.0)
    local left, top = panel:GetLeft(), panel:GetTop()
    if not (left and top) then panel:SetScale(v); return end
    local sx = left * panel:GetEffectiveScale()
    local sy = top  * panel:GetEffectiveScale()
    panel:SetScale(v)
    local newEff = panel:GetEffectiveScale()
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", sx / newEff, sy / newEff)
end

-- Reset the profile window to its default centered position and current scale.
function CCS.ResetProfilesPosition()
    if not panel then return end
    -- Scale first, then set the anchor last so the position isn't re-derived
    -- from a stale corner by the scale function.
    panel:SetScale(CCS.GetScale and CCS.GetScale() or 1.0)
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", UIParent, "CENTER", -273, 220)
end

function CCS.ToggleProfiles()
    if not panel then build() end
    if panel:IsShown() then
        panel:Hide()
    else
        CCS._applyProfilesScale(CCS.GetScale and CCS.GetScale() or 1.0)
        refreshProfileList()
        panel:Show()
    end
end