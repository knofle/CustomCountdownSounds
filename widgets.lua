-- widgets.lua
-- custom dropdown (popup + button). loaded before ui.lua, exports CCS.CreateDropdown.

-- play a sound by its value key
local function previewSound(value)
    if not value or value == "__default__" then return end
    local path = CCS.ResolvePath and CCS.ResolvePath(value)
    if path then PlaySoundFile(path, CCS.GetChannel()) end
end

------------------------------------------------------------
-- Dropdown widget
------------------------------------------------------------

local CCS_DropdownPopup

local function CCS_GetOrCreatePopup()
    if CCS_DropdownPopup then return CCS_DropdownPopup end

    local MAX_VISIBLE = 13
    local ROW_H    = 16
    local PAD      = 6
    local SCROLL_W = 14
    local SEARCH_H = 22
    local PREV_W   = 22

    local popup = CreateFrame("Frame", "CCS_DropdownPopup", UIParent, "BackdropTemplate")
    popup:SetFrameStrata("HIGH")
    popup:SetFrameLevel(200)
    popup:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 1,
        insets   = { left=1, right=1, top=1, bottom=1 },
    })
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.97)
    popup:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    popup:Hide()
    popup._buttons = {}
    popup._owner   = nil
    popup._offset  = 0

    local searchBox = CreateFrame("EditBox", nil, popup, "BackdropTemplate")
    searchBox:SetHeight(SEARCH_H)
    searchBox:SetPoint("TOPLEFT",  popup, "TOPLEFT",  PAD, -PAD)
    searchBox:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -(PAD + SCROLL_W + 2), -PAD)
    searchBox:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 1,
        insets   = { left=1, right=1, top=1, bottom=1 },
    })
    searchBox:SetBackdropColor(0.05, 0.05, 0.05, 1)
    searchBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    searchBox:SetFontObject("GameFontHighlightSmall")
    searchBox:SetTextInsets(6, 6, 0, 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(64)
    searchBox:Hide()
    popup._searchBox = searchBox

    local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchHint:SetPoint("LEFT",  searchBox, "LEFT",  6, 0)
    searchHint:SetPoint("RIGHT", searchBox, "RIGHT", -6, 0)
    searchHint:SetJustifyH("LEFT")
    searchHint:SetText("Type to search...")

    local clipper = CreateFrame("Frame", nil, popup)
    clipper:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -(PAD + SCROLL_W + 2), PAD)
    popup._clipper = clipper

    local track = CreateFrame("Frame", nil, popup, "BackdropTemplate")
    track:SetWidth(SCROLL_W)
    track:SetPoint("TOPRIGHT",    popup, "TOPRIGHT",    -PAD, -PAD)
    track:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -PAD,  PAD)
    track:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 1,
        insets   = { left=1, right=1, top=1, bottom=1 },
    })
    track:SetBackdropColor(0.05, 0.05, 0.05, 1)
    track:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local thumb = track:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    popup._thumb = thumb

    local function UpdateThumb()
        local total   = popup._total or 0
        local visible = math.min(total, MAX_VISIBLE)
        if total <= visible then thumb:Hide(); return end
        thumb:Show()
        local trackH = track:GetHeight()
        local ratio  = visible / total
        local thumbH = math.max(16, trackH * ratio)
        local travel = trackH - thumbH
        local frac   = (popup._offset or 0) / math.max(1, total - visible)
        thumb:SetHeight(thumbH)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOPLEFT",  track, "TOPLEFT",  2, -(travel * frac))
        thumb:SetPoint("TOPRIGHT", track, "TOPRIGHT", -2, -(travel * frac))
    end

    local function Refresh()
        local items  = popup._items or {}
        local owner  = popup._owner
        local offset = popup._offset or 0
        local wide   = owner and owner._widePreview
        local search = owner and (owner._widePreview or owner._wantSearch)
        for i = 1, MAX_VISIBLE do
            local row  = popup._buttons[i]
            local item = items[offset + i]
            if item then
                row._text:ClearAllPoints()
                row._text:SetPoint("LEFT", row._check, "RIGHT", 2, 0)
                if wide then
                    row._text:SetPoint("RIGHT", row, "RIGHT", -(PREV_W + 6), 0)
                    row._prev:Show()
                else
                    row._text:SetPoint("RIGHT", row, "RIGHT", -4, 0)
                    row._prev:Hide()
                end
                row._text:SetText(item.label)
                -- Pooled rows keep whatever face they were last given, so set
                -- it every time rather than only when it changes.
                local size  = row._text._ccsSize or 12
                local flags = row._text._ccsFlags or ""
                if not row._text:SetFont(CCS.FONT_REGULAR, size, flags) then
                    row._text:SetFont(row._text._ccsFace, size, flags)
                end
                row._check:SetText(item.value == (owner and owner._value) and "|cff00ff00*|r" or "")
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT",  clipper, "TOPLEFT",  0, -(i-1)*ROW_H)
                row:SetPoint("TOPRIGHT", clipper, "TOPRIGHT", 0, -(i-1)*ROW_H)
                row:Show()
                row:SetScript("OnClick", function()
                    if owner then
                        owner._value = item.value
                        owner._label:SetText(item.shortLabel or item.label)
                        if owner._noGreen or item.value == "__default__" then
                            owner:SetBackdropColor(0.15, 0.15, 0.15, 1)
                        else
                            owner:SetBackdropColor(0.05, 0.28, 0.05, 1)
                        end
                        if owner._onSelect then owner._onSelect(item.value) end
                    end
                    popup:Hide()
                end)
                row._prev:SetScript("OnClick", function()
                    previewSound(item.value == "__default__" and popup._default or item.value)
                end)
            else
                row:Hide()
            end
        end
        UpdateThumb()
    end
    popup._refresh = Refresh

    searchBox:SetScript("OnTextChanged", function(self)
        local txt = self:GetText()
        searchHint:SetShown(txt == "")
        local query = txt:lower()
        if query == "" then
            popup._items = popup._allItems
        else
            local filtered = {}
            for _, item in ipairs(popup._allItems) do
                if item.label:lower():find(query, 1, true) then
                    filtered[#filtered + 1] = item
                end
            end
            popup._items = filtered
        end
        popup._offset = 0
        popup._total  = #popup._items
        Refresh()
    end)
    searchBox:SetScript("OnEscapePressed", function() popup:Hide() end)

    popup:EnableMouseWheel(true)
    popup:SetScript("OnMouseWheel", function(_, delta)
        local total   = popup._total or 0
        local visible = math.min(total, MAX_VISIBLE)
        popup._offset = math.max(0, math.min(popup._offset - delta, total - visible))
        Refresh()
    end)

    track:EnableMouse(true)
    track:SetScript("OnMouseDown", function(_, btn)
        if btn ~= "LeftButton" then return end
        local total   = popup._total or 0
        local visible = math.min(total, MAX_VISIBLE)
        if total <= visible then return end
        track:SetScript("OnUpdate", function()
            local _, my = GetCursorPosition()
            local scale = track:GetEffectiveScale()
            local frac  = math.max(0, math.min(1, (track:GetTop() - my/scale) / track:GetHeight()))
            popup._offset = math.floor(frac * (total - visible) + 0.5)
            Refresh()
        end)
    end)
    track:SetScript("OnMouseUp", function() track:SetScript("OnUpdate", nil) end)

    for i = 1, MAX_VISIBLE do
        local row = CreateFrame("Button", nil, clipper)
        row:SetHeight(ROW_H)
        row._check = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row._check:SetPoint("LEFT", row, "LEFT", 6, 0)
        row._check:SetWidth(14)
        row._check:SetJustifyH("LEFT")
        row._text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        -- Capture the concrete face/size/flags now, so a pooled row that
        -- previewed a custom font can always restore exactly, without relying
        -- on SetFontObject resolving a name string.
        row._text._ccsFace, row._text._ccsSize, row._text._ccsFlags = row._text:GetFont()
        -- Fallbacks in case GetFont is read before the font object resolves.
        row._text._ccsFace  = row._text._ccsFace  or "Fonts\\FRIZQT__.TTF"
        row._text._ccsSize  = row._text._ccsSize  or 12
        row._text._ccsFlags = row._text._ccsFlags or ""
        row._text:SetPoint("LEFT", row._check, "RIGHT", 2, 0)
        row._text:SetJustifyH("LEFT")
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.1)
        local prev = CreateFrame("Button", nil, row)
        prev:SetSize(PREV_W, ROW_H)
        prev:SetPoint("RIGHT", row, "RIGHT", -2, 0)
        local prevHL = prev:CreateTexture(nil, "HIGHLIGHT")
        prevHL:SetAllPoints(); prevHL:SetColorTexture(0.6, 0.8, 1, 0.15)
        local prevTex = prev:CreateTexture(nil, "ARTWORK")
        prevTex:SetSize(PREV_W - 6, PREV_W - 6)
        prevTex:SetPoint("CENTER")
        prevTex:SetAtlas("common-icon-sound")
        prevTex:SetVertexColor(0.6, 0.8, 1, 0.7)
        prev:SetScript("OnEnter", function() prevTex:SetVertexColor(0.8, 1, 1, 1) end)
        prev:SetScript("OnLeave", function() prevTex:SetVertexColor(0.6, 0.8, 1, 0.7) end)
        row._prev = prev
        row:Hide()
        popup._buttons[i] = row
    end

    local catcher = CreateFrame("Frame", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("HIGH")
    catcher:SetFrameLevel(199)
    catcher:Hide()
    catcher:EnableMouse(true)
    catcher:SetScript("OnMouseDown", function() popup:Hide() end)
    popup._catcher = catcher

    popup:SetScript("OnHide", function()
        catcher:Hide()
        searchBox:SetText("")
        searchBox:ClearFocus()
    end)

    CCS_DropdownPopup = popup
    return popup
end

local function CCS_CreateDropdown(parent, width, height, fontSize)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 120, height or 22)
    btn:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 1,
        insets   = { left=1, right=1, top=1, bottom=1 },
    })
    btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local fontFace, _, fontFlags = GameFontHighlightSmall:GetFont()
    btn._label = btn:CreateFontString(nil, "OVERLAY")
    btn._labelSize = fontSize or 10   -- remembered so a custom font keeps this size
    btn._label:SetFont(fontFace, btn._labelSize, fontFlags)
    btn._label._ccsSize = btn._labelSize
    btn._label._ccsDefaultFace = fontFace
    btn._label._ccsDefaultFlags = fontFlags
    -- Register so CCS.RestyleDropdowns can re-font this label later.
    CCS._ddLabels = CCS._ddLabels or {}
    CCS._ddLabels[#CCS._ddLabels + 1] = btn._label
    btn._label:SetPoint("LEFT",  btn, "LEFT",  8,   0)
    btn._label:SetPoint("RIGHT", btn, "RIGHT", -18, 0)
    btn._label:SetJustifyH("LEFT")
    btn._label:SetText("--")

    local arrow = btn:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\AddOns\\CustomCountdownSounds\\media\\down_arrow")
    arrow:SetSize(7, 10)
    arrow:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
    arrow:SetVertexColor(0.8, 0.8, 0.8, 1)
    btn._arrow = arrow

    btn._items    = {}
    btn._value    = nil
    btn._onSelect = nil
    btn._enabled  = true

    btn:SetScript("OnEnter", function(self)
        if self._enabled then self:SetBackdropBorderColor(0.8, 0.8, 0.8, 1) end
    end)
    btn:SetScript("OnLeave", function(self)
        if self._enabled then self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1) end
    end)
    btn:SetScript("OnClick", function(self)
        if not self._enabled then return end
        local popup = CCS_GetOrCreatePopup()
        if popup:IsShown() and popup._owner == self then popup:Hide(); return end

        local MAX_VISIBLE = 13
        local ROW_H    = 16
        local PAD      = 6
        local SCROLL_W = 14
        local SEARCH_H = 22
        local hasSearch = self._widePreview or self._wantSearch

        popup._owner    = self
        popup._allItems = self._items
        popup._items    = self._items
        popup._offset   = 0
        popup._total    = #self._items
        popup._default  = self._defaultSound

        if hasSearch then
            popup._searchBox:Show()
            popup._searchBox:SetText("")
            popup._clipper:SetPoint("TOPLEFT", popup, "TOPLEFT", PAD, -(PAD + SEARCH_H + 4))
        else
            popup._searchBox:Hide()
            popup._clipper:SetPoint("TOPLEFT", popup, "TOPLEFT", PAD, -PAD)
        end

        local visible = math.min(#self._items, MAX_VISIBLE)
        local pw = hasSearch and (math.max(width * 2, 260) + SCROLL_W + PAD)
                             or  ((self._popupWidth or width or 110) + SCROLL_W + PAD)
        local extraH = hasSearch and (SEARCH_H + 4) or 0
        popup:SetSize(pw, PAD*2 + visible*ROW_H + extraH)
        -- popup lives on UIParent, match owner's scale so it resizes with the window
        local ownerEff = self:GetEffectiveScale()
        local puEff    = UIParent:GetEffectiveScale()
        popup:SetScale(ownerEff / puEff)
        popup:ClearAllPoints()
        popup:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
        popup._refresh()
        popup:Show()
        popup._catcher:Show()
        if hasSearch then popup._searchBox:SetFocus() end
    end)

    function btn:SetItems(items)  self._items = items or {} end
    function btn:GetValue()       return self._value end
    function btn:SetOnSelect(fn)  self._onSelect = fn end

    function btn:SetValue(value)
        self._value = value
        for _, item in ipairs(self._items) do
            if item.value == value then
                self._label:SetText(item.shortLabel or item.label)
                if self._noGreen or value == "__default__" then
                    self:SetBackdropColor(0.15, 0.15, 0.15, 1)
                else
                    self:SetBackdropColor(0.05, 0.28, 0.05, 1)
                end
                return
            end
        end
        self._label:SetText("--")
        self:SetBackdropColor(0.15, 0.15, 0.15, 1)
    end

    function btn:SetEnabled(enabled)
        self._enabled = enabled and true or false
        if self._enabled then
            self._label:SetTextColor(1,   1,   1)
            self._arrow:SetVertexColor(0.8, 0.8, 0.8, 1)
            local isOverride = (not self._noGreen) and self._value and self._value ~= "__default__"
            self:SetBackdropColor(isOverride and 0.05 or 0.15, isOverride and 0.28 or 0.15, isOverride and 0.05 or 0.15, 1)
            self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        else
            self._label:SetTextColor(0.5, 0.5, 0.5)
            self._arrow:SetVertexColor(0.4, 0.4, 0.4, 1)
            self:SetBackdropColor(0.1, 0.1, 0.1, 1)
            self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        end
    end

    return btn
end

CCS = CCS or {}
CCS.CreateDropdown = CCS_CreateDropdown