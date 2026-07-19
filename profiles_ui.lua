-- profiles_ui.lua
-- new, copy, rename, delete, plus profile export/import (LibSerialize+LibDeflate).

local addonName = ...
local CCS_CreateDropdown = CCS.CreateDropdown

-- Route labels through the font registry when it's available, so the profile
-- window restyles with the chosen font like the rest of the addon.
local function fstring(parent, layer, obj)
    if CCS._makeFontString then return CCS._makeFontString(parent, layer, obj) end
    return parent:CreateFontString(nil, layer, obj)
end

local COL_BG        = { 0.078, 0.078, 0.078, 1 }
local COL_ROW       = { 0.13, 0.13, 0.13, 1 }
local COL_BORDER    = { 0.25, 0.25, 0.25, 1 }
local BOX_W         = 748   -- paste box width (window 600 - margins)
local BOX_H         = 130   -- paste box height

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

-- Import target picker (replace current vs save-as-new) -----------------------

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

-- Build the window -----------------------------------------------------------

local function build()
    panel = CreateFrame("Frame", "CCSProfilesWindow", UIParent, "BackdropTemplate")
    tinsert(UISpecialFrames, "CCSProfilesWindow")  -- close on Esc
    panel:SetSize(780, 580)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(50)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
    })
    panel:SetBackdropColor(unpack(COL_BG))
    panel:SetBackdropBorderColor(unpack(COL_BORDER))
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()

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
    local expLbl = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    expLbl:SetPoint("TOPLEFT", newBtn, "BOTTOMLEFT", 0, -14)
    expLbl:SetText("|cffccccccExport (copy this and share it)|r")

    local expFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    expFrame:SetPoint("TOPLEFT", expLbl, "BOTTOMLEFT", 0, -4)
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
    expBox:SetFontObject("GameFontHighlightSmall")
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
    expBtn:SetPoint("TOPLEFT", expFrame, "BOTTOMLEFT", 0, -6)
    expBtn:SetScript("OnClick", function()
        local s, err = CCS.ExportProfile()
        if s then
            expBox:SetText(s)
            expBox:SetFocus(); expBox:HighlightText()
        else
            print("|cffffff00CCS:|r Export failed - " .. (err or "unknown"))
        end
    end)

    -- import box
    local impLbl = fstring(panel, "ARTWORK", "GameFontNormalSmall")
    impLbl:SetPoint("TOPLEFT", expBtn, "BOTTOMLEFT", 0, -14)
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
    impBox:SetFontObject("GameFontHighlightSmall")
    impBox:SetWidth(BOX_W - 34)
    impBox:SetHeight(BOX_H - 8)     -- fill the box so the whole area is clickable
    impBox:SetAutoFocus(false)
    impScroll:SetScrollChild(impBox)
    impBox:SetScript("OnEscapePressed", impBox.ClearFocus)
    -- clicking anywhere in the frame focuses the box for pasting
    impFrame:EnableMouse(true)
    impFrame:SetScript("OnMouseDown", function() impBox:SetFocus() end)
    panel.impBox = impBox

    local impBtn = makeFlatButton(panel, 90, 22, "Import")
    impBtn:SetPoint("TOPLEFT", impFrame, "BOTTOMLEFT", 0, -6)
    impBtn:SetScript("OnClick", function()
        local payload, err = CCS.DecodeProfile(impBox:GetText())
        if not payload then
            print("|cffffff00CCS:|r Import failed - " .. (err or "unknown"))
            return
        end
        impBox:SetText("")
        local dlg = StaticPopup_Show("CCS_IMPORT_TARGET", payload.name or "Imported")
        if dlg then dlg.data = payload end
    end)

    return panel
end

function CCS.ToggleProfiles()
    if not panel then build() end
    if panel:IsShown() then
        panel:Hide()
    else
        refreshProfileList()
        panel:Show()
    end
end