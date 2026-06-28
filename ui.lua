-- ui.lua
local addonName = ...

------------------------------------------------------------
-- Tiny utilities
------------------------------------------------------------

local function withCombatGuard(fn)
    if InCombatLockdown() then
        print("|cffffff00CCS:|r Cannot change settings during combat.")
        return
    end
    fn()
end

local function setButtonBg(btn, r, g, b)
    if not btn._bg then
        local tex = btn:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints()
        btn._bg = tex
    end
    btn._bg:SetColorTexture(r, g, b, 1)
end

local function stripButtonBorder(btn)
    if btn.Left   then btn.Left:Hide()   end
    if btn.Middle then btn.Middle:Hide() end
    if btn.Right  then btn.Right:Hide()  end
end

local function stripCheckBorder(cb)
    local nt = cb:GetNormalTexture();    if nt then nt:SetTexture("") end
    local pt = cb:GetPushedTexture();    if pt then pt:SetTexture("") end
    local ht = cb:GetHighlightTexture(); if ht then ht:SetTexture("") end
    local dt = cb:GetDisabledTexture();  if dt then dt:SetTexture("") end
    cb:SetNormalTexture("")
    cb:SetPushedTexture("")
    cb:SetHighlightTexture("")
    cb:SetDisabledTexture("")
    cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    local t = cb:GetCheckedTexture()
    if t then t:SetVertexColor(0.9, 0.9, 0.9, 1) end

    if not cb._ccsBg then
        local bg = cb:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 1)
        cb._ccsBg = bg
    end

    if not cb._ccsBorder then
        local border = CreateFrame("Frame", nil, cb, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
        border:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
        border:SetFrameLevel(cb:GetFrameLevel() + 1)
        cb._ccsBorder = border
    end
end

local function addTooltip(frame, title, body)
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title, 1, 1, 1)
        if body then GameTooltip:AddLine(body, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Preview a sound by value key (LSM name, "file:name", or CCS shortname).
local function previewSound(value)
    if not value or value == "__default__" then return end
    local path = CCS.ResolvePath and CCS.ResolvePath(value)
    if path then PlaySoundFile(path, "Master") end
end

local CATEGORY_NAME = "Custom Countdown Sounds"

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
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets   = { left=3, right=3, top=3, bottom=3 },
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
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets   = { left=3, right=3, top=3, bottom=3 },
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
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 6,
        insets   = { left=2, right=2, top=2, bottom=2 },
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
                row._check:SetText(item.value == (owner and owner._value) and "|cff00ff00*|r" or "")
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT",  clipper, "TOPLEFT",  0, -(i-1)*ROW_H)
                row:SetPoint("TOPRIGHT", clipper, "TOPRIGHT", 0, -(i-1)*ROW_H)
                row:Show()
                row:SetScript("OnClick", function()
                    if owner then
                        owner._value = item.value
                        owner._label:SetText(item.shortLabel or item.label)
                        if item.value == "__default__" then
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
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets   = { left=3, right=3, top=3, bottom=3 },
    })
    btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local fontFace = select(1, GameFontHighlightSmall:GetFont())
    local fontFlags = select(3, GameFontHighlightSmall:GetFont())
    btn._label = btn:CreateFontString(nil, "OVERLAY")
    btn._label:SetFont(fontFace, fontSize or 10, fontFlags)
    btn._label:SetPoint("LEFT",  btn, "LEFT",  8,   0)
    btn._label:SetPoint("RIGHT", btn, "RIGHT", -18, 0)
    btn._label:SetJustifyH("LEFT")
    btn._label:SetText("--")

    local arrow = btn:CreateFontString(nil, "OVERLAY")
    arrow:SetFont(fontFace, fontSize or 10, fontFlags)
    arrow:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
    arrow:SetText("v")
    arrow:SetTextColor(0.8, 0.8, 0.8)
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
        local hasSearch = self._widePreview

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
                if value == "__default__" then
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
            self._arrow:SetTextColor(0.8, 0.8, 0.8)
            local isOverride = self._value and self._value ~= "__default__"
            self:SetBackdropColor(isOverride and 0.05 or 0.15, isOverride and 0.28 or 0.15, isOverride and 0.05 or 0.15, 1)
            self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        else
            self._label:SetTextColor(0.5, 0.5, 0.5)
            self._arrow:SetTextColor(0.4, 0.4, 0.4)
            self:SetBackdropColor(0.1, 0.1, 0.1, 1)
            self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        end
    end

    return btn
end

------------------------------------------------------------
-- Sound / item helpers
------------------------------------------------------------

local COUNTDOWN_KEYS = {
    "file:2s", "file:2,5s",
    "file:3s", "file:3,5s",
    "file:4s", "file:4,5s",
    "file:5s", "file:5,5s",
    "file:6s", "file:6,5s",
    "file:7s", "file:7,5s",
    "file:8s", "file:8,5s",
    "file:9s", "file:9,5s",
    "file:10s","file:10,5s",
    "file:11s","file:11,5s",
    "file:12s","file:12,5s",
    "file:13s",
}
local COUNTDOWN_LABELS = {
    ["file:2s"]="2.0 Seconds",   ["file:2,5s"]="2.5 Seconds",
    ["file:3s"]="3.0 Seconds",   ["file:3,5s"]="3.5 Seconds",
    ["file:4s"]="4.0 Seconds",   ["file:4,5s"]="4.5 Seconds",
    ["file:5s"]="5.0 Seconds",   ["file:5,5s"]="5.5 Seconds",
    ["file:6s"]="6.0 Seconds",   ["file:6,5s"]="6.5 Seconds",
    ["file:7s"]="7.0 Seconds",   ["file:7,5s"]="7.5 Seconds",
    ["file:8s"]="8.0 Seconds",   ["file:8,5s"]="8.5 Seconds",
    ["file:9s"]="9.0 Seconds",   ["file:9,5s"]="9.5 Seconds",
    ["file:10s"]="10.0 Seconds", ["file:10,5s"]="10.5 Seconds",
    ["file:11s"]="11.0 Seconds", ["file:11,5s"]="11.5 Seconds",
    ["file:12s"]="12.0 Seconds", ["file:12,5s"]="12.5 Seconds",
    ["file:13s"]="13.0 Seconds",
    ["file:3sfull"]="3.0 Seconds",
}

local function prettifyKey(key)
    if not key then return "none" end
    local s = key:gsub("^file:", ""):gsub("_", " ")
    -- Capitalise word-initial letters only.
    s = s:gsub("^(%a)", string.upper)
    s = s:gsub("(%s)(%a)", function(sp, ch) return sp .. ch:upper() end)
    return s
end

local function shortCountdownLabel(key)
    if not key then return nil end
    local full = COUNTDOWN_LABELS[key]
    if full then
        local n = full:match("^([%d%.]+)")
        if n then
            n = n:gsub("%.0$", "")  -- "6.0" -> "6"
            return n .. "s"
        end
        return full
    end
    return prettifyKey(key)
end

local function getDefaultWarn(ability)
    local s = ability.soundH or ability.soundM
    if not s then return nil end
    if type(s) == "table" then return s[1] end
    return s
end

local function getDefaultCountdown(ability, diff)
    local s = diff == "M" and ability.soundM or (diff ~= "M" and ability.soundH)
    if type(s) == "table" then return s[2] end
    return nil
end

local function hasHeroic(ability) return ability.soundH ~= nil or CCS.GetCountdownOverride(ability.key, "H") ~= nil end
local function hasMythic(ability)  return ability.soundM ~= nil or CCS.GetCountdownOverride(ability.key, "M") ~= nil end

-- CCS-registered LSM sounds get prettified labels.
-- Raid markers also get the target icon and an "RM" tag.
local RAID_ICON_TEX = " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t"
local RM_ICON_INDEX = {
    star = 1, circle = 2, diamond = 3, triangle = 4,
    moon = 5, square = 6, cross = 7, skull = 8,
}
local function decorateSoundName(name)
    local rest = name:match("^CCS:%s*(.+)$")
    if not rest then return name end
    local pretty = rest:sub(1, 1):upper() .. rest:sub(2)
    local idx = RM_ICON_INDEX[rest:lower()]
    if idx then
        return "CCS: RM " .. pretty .. RAID_ICON_TEX:format(idx)
    end
    return "CCS: " .. pretty
end

local cachedSoundItems    = nil
local _warnItemsCache     = {}
local _countdownItemsCache = {}

local function getSoundItems()
    if cachedSoundItems then return cachedSoundItems end
    local LSM   = LibStub and LibStub("LibSharedMedia-3.0", true)
    local items = {}
    if LSM then
        -- LSM:List returns its internal table by reference — copy before sorting,
        -- otherwise we'd mutate the list every other addon sees.
        local raw  = LSM:List("sound") or {}
        local list = {}
        for i = 1, #raw do list[i] = raw[i] end
        -- CCS non-RM first (alphabetical), then CCS RM (Skull → Star), then everything else.
        local function sortKey(name)
            local rest = name:match("^CCS:%s*(.+)$")
            if rest then
                local idx = RM_ICON_INDEX[rest:lower()]
                if idx then
                    return "1" .. string.format("%02d", 99 - idx)
                end
                return "0" .. rest:lower()
            end
            return "2" .. name:lower()
        end
        table.sort(list, function(a, b) return sortKey(a) < sortKey(b) end)
        for _, name in ipairs(list) do
            items[#items + 1] = { label = decorateSoundName(name), value = name }
        end
    end
    cachedSoundItems = items
    return items
end

local function buildWarnItems(defaultKey)
    local k = defaultKey or "__nil__"
    if _warnItemsCache[k] then return _warnItemsCache[k] end
    local short = prettifyKey(defaultKey)
    local items = {{ label = short .. " (default)", shortLabel = short, value = "__default__" }}
    for _, item in ipairs(getSoundItems()) do
        items[#items + 1] = { label = item.label, shortLabel = item.label, value = item.value }
    end
    _warnItemsCache[k] = items
    return items
end

local function buildCountdownItems(defaultKey)
    local k = defaultKey or "__nil__"
    if _countdownItemsCache[k] then return _countdownItemsCache[k] end
    -- Always one decimal: "6" -> "6.0", "6.5" -> "6.5".
    local function shortNum(s)
        local n = s:match("^([%d%.]+)")
        if not n then return s end
        if not n:find("%.") then n = n .. ".0" end
        return n
    end
    local shortDef = defaultKey and (COUNTDOWN_LABELS[defaultKey] or prettifyKey(defaultKey)) or "off"
    local items = {{ label = shortDef .. " (default)", shortLabel = shortNum(shortDef), value = "__default__" }}
    for _, ck in ipairs(COUNTDOWN_KEYS) do
        local full = COUNTDOWN_LABELS[ck]
        local num  = shortNum(full)
        items[#items + 1] = { label = num, shortLabel = num, value = ck }
    end
    _countdownItemsCache[k] = items
    return items
end

local function testAbility(ability, difficulty)
    if not CCS.IsAbilityActive(ability.key) then
        print("|cffffff00CCS:|r Test — |cffffffff" .. ability.label .. "|r is hidden by the boss's \"Show all\" toggle.")
        return
    end
    local anySoundPlayed = false
    if CCS.isWarnEnabled(ability.key) then
        local warnSoundField = ability.soundH or ability.soundM
        local defaultWarnKey = type(warnSoundField) == "table" and warnSoundField[1] or warnSoundField
        local resolvedWarnKey = CCS.GetWarnOverride(ability.key) or defaultWarnKey
        local warnSoundPath = CCS.ResolvePath and CCS.ResolvePath(resolvedWarnKey)
        if warnSoundPath then
            PlaySoundFile(warnSoundPath, "Master")
            anySoundPlayed = true
        end
    end
    if CCS.IsCDEnabled(ability.key, difficulty) then
        local cdSoundField = difficulty == "M" and ability.soundM or ability.soundH
        local defaultCDKey = type(cdSoundField) == "table" and cdSoundField[2] or nil
        local ctOn = CCS.GetCustomTimerOverride()
        local resolvedCDKey = (ctOn and CCS.GetCountdownOverride(ability.key, difficulty)) or defaultCDKey
        local cdSoundPath = resolvedCDKey and CCS.ResolvePath and CCS.ResolvePath(resolvedCDKey)
        if cdSoundPath then
            PlaySoundFile(cdSoundPath, "Master")
            anySoundPlayed = true
        end
    end
    if not anySoundPlayed then
        print("|cffffff00CCS:|r Test — |cffffffff" .. ability.label .. "|r: no sounds enabled or resolved for " .. difficulty .. ".")
    end
end



local ROW_HEIGHT = 22
local DROPDOWN_HEIGHT       = 23  -- dropdown height, independent of ROW_HEIGHT
local WARN_DROPDOWN_FONT_SIZE = 11  -- warning dropdown font size
local COUNTDOWN_DROPDOWN_FONT_SIZE   = 13  -- countdown dropdown font size
local SECTION_HEADER_H   = 24
local HEADER_BAR_H = 62  -- height of the column header bar (Warning Sound / Countdown Timer)
local BULK_BOX_H   = 38  -- height of the All Warnings / All Countdowns boxes
local TOP_BLOCK_H  = 66  -- height of the top black block (addon name, description, buttons)
local INDENT     = 12
local CHECKBOX_SIZE    = 18
local WARN_DROPDOWN_W       = 110   -- warn dropdown width
local COUNTDOWN_DROPDOWN_W       = 60    -- countdown dropdown width
local LEFT_PANEL_FRACTION  = 0.50

-- Column offsets
local RIGHT_CELL_PAD      = 20
local TEST_BTN_W          = 36   -- width of "Test" button
local DIFF_LBL_W          = 20   -- width of "HC:" / "M:" labels

-- Raid: HC section
local RAID_HC_LBL_X       = RIGHT_CELL_PAD
local RAID_HC_CHECKBOX_X  = RAID_HC_LBL_X + DIFF_LBL_W
local RAID_HC_DROPDOWN_X  = RAID_HC_CHECKBOX_X + CHECKBOX_SIZE + 4

-- Raid: M section
local RAID_MYTHIC_LBL_X      = RAID_HC_DROPDOWN_X + COUNTDOWN_DROPDOWN_W + 14
local RAID_MYTHIC_CHECKBOX_X = RAID_MYTHIC_LBL_X + DIFF_LBL_W
local RAID_MYTHIC_DROPDOWN_X = RAID_MYTHIC_CHECKBOX_X + CHECKBOX_SIZE + 4

-- Raid: Custom Timer is now a global header checkbox, no per-row X needed

-- M+: section
local MPLUS_CHECKBOX_X    = RIGHT_CELL_PAD
local MPLUS_DROPDOWN_X    = MPLUS_CHECKBOX_X + CHECKBOX_SIZE + 4

-- Raid header colors
local RAID_COLORS = {
    ["March on Quel'Danas"] = "|cff6fcf6f",
    ["The Dreamrift"]       = "|cff6aacdc",
    ["The Voidspire"]       = "|cffc17de8",
    ["Sporefall"]           = "|cffb8c777",
}

------------------------------------------------------------
-- Frame pool
------------------------------------------------------------

local _pool = { rows={}, headers={}, raidBgs={}, seps={}, showAlls={}, divider=nil }

-- Pick one spellID from any privateID shape, for icon/tooltip.
local function getScalarID(pid)
    if not pid then return nil end
    if type(pid) == "table" then
        if pid.H ~= nil or pid.M ~= nil then
            local val = pid.H or pid.M
            return type(val) == "table" and val[1] or val
        end
        return pid[1]  -- plain array
    end
    return pid
end

-- {label, id} pairs for tooltip lines.
local function getPrivateIDLines(pid)
    if not pid then return {} end
    if type(pid) == "table" then
        if pid.H ~= nil or pid.M ~= nil then
            local lines = {}
            local function addLines(label, val)
                if not val then return end
                if type(val) == "table" then
                    for _, id in ipairs(val) do
                        lines[#lines+1] = { label=label, id=id }
                    end
                else
                    lines[#lines+1] = { label=label, id=val }
                end
            end
            addLines("HC", pid.H)
            addLines("M",  pid.M)
            return lines
        end
        local lines = {}
        for _, id in ipairs(pid) do lines[#lines+1] = { label=nil, id=id } end
        return lines
    end
    return {{ label=nil, id=pid }}
end

local function acquireRow(scrollChild, idx)
    if _pool.rows[idx] then return _pool.rows[idx] end

    local leftCell  = CreateFrame("Frame", nil, scrollChild)
    local rightCell = CreateFrame("Frame", nil, scrollChild)

    -- Test button (label set later per module).
    local function makeTestBtn(parent, tooltipText)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(TEST_BTN_W, ROW_HEIGHT)
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(); bg:SetColorTexture(0.06, 0.06, 0.06, 0.95)
        local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
        border:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetAllPoints(); fs:SetJustifyH("CENTER"); fs:SetJustifyV("MIDDLE")
        fs:SetText("|cffaaaaaa Test|r")
        local hl = btn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.08)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn
    end

    local raidTestBtn  = makeTestBtn(leftCell,
        "Tests the sound as it will play in a mythic raid encounter.\nShift-click for heroic.")
    raidTestBtn:SetPoint("RIGHT", leftCell, "RIGHT", -8, 0)
    local mplusTestBtn = makeTestBtn(leftCell,
        "Tests the sound as it will sound when you get this debuff.")
    mplusTestBtn:SetPoint("RIGHT", leftCell, "RIGHT", -8, 0)

    -- warnDD sits left of the test button area so layout is stable when the button hides.
    local warnDD = CCS_CreateDropdown(leftCell, WARN_DROPDOWN_W, DROPDOWN_HEIGHT, WARN_DROPDOWN_FONT_SIZE)
    warnDD:SetPoint("RIGHT", raidTestBtn, "LEFT", -4, 0)
    warnDD._widePreview = true

    local warnCB = CreateFrame("CheckButton", nil, leftCell, "UICheckButtonTemplate")
    warnCB:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE)
    warnCB:SetPoint("RIGHT", warnDD, "LEFT", -4, 0)
    stripCheckBorder(warnCB)

    local warnNoLbl = leftCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    warnNoLbl:SetText("|cff555555No default|r")
    warnNoLbl:SetPoint("RIGHT", raidTestBtn, "LEFT", -4, 0)

    local icon = leftCell:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("LEFT", leftCell, "LEFT", INDENT, 0)

    local lblFrame = CreateFrame("Button", nil, leftCell)
    lblFrame:SetPoint("LEFT",  leftCell, "LEFT", INDENT + 22, 0)
    lblFrame:SetPoint("RIGHT", warnCB,   "LEFT", -6, 0)
    lblFrame:SetHeight(ROW_HEIGHT)
    lblFrame:RegisterForClicks("LeftButtonUp")
    local lbl = lblFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    lbl:SetAllPoints(); lbl:SetJustifyH("LEFT"); lbl:SetJustifyV("MIDDLE")
    local lblHL = lblFrame:CreateTexture(nil, "HIGHLIGHT")
    lblHL:SetAllPoints(); lblHL:SetColorTexture(1, 1, 1, 0.05)

    -- Raid right-cell controls
    local hLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    hLbl:SetText("|cffaaaaaa HC:|r")
    local hCB = CreateFrame("CheckButton", nil, rightCell, "UICheckButtonTemplate")
    hCB:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE); stripCheckBorder(hCB)
    local hDD = CCS_CreateDropdown(rightCell, COUNTDOWN_DROPDOWN_W, DROPDOWN_HEIGHT, COUNTDOWN_DROPDOWN_FONT_SIZE)
    hDD._popupWidth = 130
    local hNoLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    hNoLbl:SetText("|cff555555No default|r")
    local hValLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")

    local mLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    mLbl:SetText("|cffaaaaaa M:|r")
    local mCB = CreateFrame("CheckButton", nil, rightCell, "UICheckButtonTemplate")
    mCB:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE); stripCheckBorder(mCB)
    local mDD = CCS_CreateDropdown(rightCell, COUNTDOWN_DROPDOWN_W, DROPDOWN_HEIGHT, COUNTDOWN_DROPDOWN_FONT_SIZE)
    mDD._popupWidth = 130
    local mNoLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    mNoLbl:SetText("|cff555555No default|r")
    local mValLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")

    -- M+ right-cell controls
    local cdCB = CreateFrame("CheckButton", nil, rightCell, "UICheckButtonTemplate")
    cdCB:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE); stripCheckBorder(cdCB)
    local cdDD = CCS_CreateDropdown(rightCell, COUNTDOWN_DROPDOWN_W, DROPDOWN_HEIGHT, COUNTDOWN_DROPDOWN_FONT_SIZE)
    cdDD._popupWidth = 130
    local cdNoLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    cdNoLbl:SetText("|cff555555No default|r")
    local cdValLbl = rightCell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")

    -- Row state
    local r = {
        leftCell=leftCell, rightCell=rightCell,
        warnDD=warnDD, warnCB=warnCB, warnNoLbl=warnNoLbl, icon=icon, lbl=lbl, lblFrame=lblFrame,
        raidTestBtn=raidTestBtn, mplusTestBtn=mplusTestBtn,
        hLbl=hLbl, hCB=hCB, hDD=hDD, hNoLbl=hNoLbl, hValLbl=hValLbl,
        mLbl=mLbl, mCB=mCB, mDD=mDD, mNoLbl=mNoLbl, mValLbl=mValLbl,
        cdCB=cdCB, cdDD=cdDD, cdNoLbl=cdNoLbl, cdValLbl=cdValLbl,
        _ability=nil, _isMplus=false,
        _hDefaultCD=nil, _mDefaultCD=nil, _cdDefaultCD=nil,
        _hOver=nil, _mOver=nil, _cdOver=nil,
        _warnNoDefault=false, _hNoDefault=false, _mNoDefault=false,
    }

    -- Visibility refreshers.
    local function refreshTestBtn()
        local a = r._ability; if not a then return end
        local hasWarn = not r._warnNoDefault or CCS.isWarnEnabled(a.key)
        local hasSound
        if r._isMplus then
            hasSound = r._cdDefaultCD ~= nil or CCS.IsCDEnabled(a.key, "M")
        else
            hasSound = r._hDefaultCD ~= nil or r._mDefaultCD ~= nil
                    or CCS.IsCDEnabled(a.key, "H") or CCS.IsCDEnabled(a.key, "M")
        end
        local show = hasWarn or hasSound
        raidTestBtn:SetShown(show and not r._isMplus)
        mplusTestBtn:SetShown(show and r._isMplus)
    end
    local function refreshWarnDD()
        local a = r._ability; if not a then return end
        local en = warnCB:GetChecked()
        if not r._warnNoDefault or en or CCS.GetWarnOverride(a.key) then
            warnDD:Show(); warnDD:SetEnabled(en); warnNoLbl:Hide()
        else
            warnDD:Hide(); warnNoLbl:Show()
        end
        refreshTestBtn()
    end
    local function refreshHDD()
        local a = r._ability
        if not a then hLbl:Hide();  hCB:Hide(); hDD:Hide(); hNoLbl:Hide(); hValLbl:Hide(); return end
        local ctOn = CCS.GetCustomTimerOverride()
        local cbOn = hCB:GetChecked()
        local activeKey = ctOn and (r._hOver or r._hDefaultCD) or r._hDefaultCD
        if ctOn and cbOn then
            hLbl:Show(); hCB:Show()
            hDD:Show(); hDD:SetEnabled(true)
            hNoLbl:Hide(); hValLbl:Hide()
        elseif ctOn and not activeKey then
            hLbl:Show(); hCB:Show()
            hNoLbl:Show(); hDD:Hide(); hValLbl:Hide()
        elseif activeKey then
            hLbl:Show(); hCB:Show()
            hValLbl:SetText("|cffcccccc" .. shortCountdownLabel(activeKey) .. "|r")
            hValLbl:Show(); hDD:Hide(); hNoLbl:Hide()
        else
            hLbl:Hide(); hCB:Hide()
            hDD:Hide(); hNoLbl:Hide(); hValLbl:Hide()
        end
        refreshTestBtn()
    end
    local function refreshMDD()
        local a = r._ability
        if not a then mLbl:Hide();  mCB:Hide(); mDD:Hide(); mNoLbl:Hide(); mValLbl:Hide(); return end
        local ctOn = CCS.GetCustomTimerOverride()
        local cbOn = mCB:GetChecked()
        local activeKey = ctOn and (r._mOver or r._mDefaultCD) or r._mDefaultCD
        if ctOn and cbOn then
            mLbl:Show(); mCB:Show()
            mDD:Show(); mDD:SetEnabled(true)
            mNoLbl:Hide(); mValLbl:Hide()
        elseif ctOn and not activeKey then
            mLbl:Show(); mCB:Show()
            mNoLbl:Show(); mDD:Hide(); mValLbl:Hide()
        elseif activeKey then
            mLbl:Show(); mCB:Show()
            mValLbl:SetText("|cffcccccc" .. shortCountdownLabel(activeKey) .. "|r")
            mValLbl:Show(); mDD:Hide(); mNoLbl:Hide()
        else
            mLbl:Hide(); mCB:Hide()
            mDD:Hide(); mNoLbl:Hide(); mValLbl:Hide()
        end
        refreshTestBtn()
    end
    local function refreshCdDD()
        local a = r._ability
        if not a then cdCB:Hide(); cdDD:Hide(); cdNoLbl:Hide(); cdValLbl:Hide(); return end
        local ctOn = CCS.GetCustomTimerOverride()
        local cbOn = cdCB:GetChecked()
        local activeKey = ctOn and (r._cdOver or r._cdDefaultCD) or r._cdDefaultCD
        if ctOn and cbOn then
            cdCB:Show(); cdDD:Show(); cdDD:SetEnabled(true)
            cdNoLbl:Hide(); cdValLbl:Hide()
        elseif ctOn and not activeKey then
            cdCB:Show(); cdNoLbl:Show(); cdDD:Hide(); cdValLbl:Hide()
        elseif activeKey then
            cdCB:Show()
            cdValLbl:SetText("|cffcccccc" .. shortCountdownLabel(activeKey) .. "|r")
            cdValLbl:Show(); cdDD:Hide(); cdNoLbl:Hide()
        else
            cdCB:Hide(); cdDD:Hide(); cdNoLbl:Hide(); cdValLbl:Hide()
        end
        refreshTestBtn()
    end
    r.refreshHDD  = refreshHDD
    r.refreshMDD  = refreshMDD
    r.refreshCdDD = refreshCdDD

    -- Wire tooltips
    addTooltip(warnDD,  "Warning Sound",          "Choose which sound plays when this aura is applied.")
    addTooltip(warnCB,  "Warning Sound",          "Play a sound when this ability's aura is applied to you.")
    addTooltip(hCB,     "Heroic Countdown",       "Play a countdown sound on Heroic difficulty.")
    addTooltip(hDD,     "Heroic Countdown Timer", "Choose the countdown timer for Heroic difficulty.")
    addTooltip(mCB,     "Mythic Countdown",       "Play a countdown sound on Mythic difficulty.")
    addTooltip(mDD,     "Mythic Countdown Timer", "Choose the countdown timer for Mythic difficulty.")
    addTooltip(cdCB,    "Countdown",              "Play a countdown sound when this aura is applied.")
    addTooltip(cdDD,    "Countdown Timer",        "Choose the countdown timer in seconds.")

    lblFrame:EnableMouse(true)
    lblFrame:SetScript("OnEnter", function(self)
        local a = r._ability
        if not a or not a.privateID then return end
        local pid = a.privateID
        local scalarID = getScalarID(pid)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPRIGHT", self:GetParent(), "TOPLEFT", 0, 0)
        if scalarID and C_Spell and C_Spell.DoesSpellExist and C_Spell.DoesSpellExist(scalarID) then
            GameTooltip:SetSpellByID(scalarID)
        else
            GameTooltip:SetText(a.label or a.key, 1, 1, 1)
        end
        GameTooltip:AddLine(" ")
        local idLines = getPrivateIDLines(pid)
        if #idLines == 1 and not idLines[1].label then
            GameTooltip:AddLine("|cffaaaaaa SpellID: " .. idLines[1].id .. "|r")
        else
            for _, line in ipairs(idLines) do
                local prefix = line.label and ("SpellID (" .. line.label .. "): ") or "SpellID: "
                GameTooltip:AddLine("|cffaaaaaa " .. prefix .. line.id .. "|r")
            end
        end
        GameTooltip:Show()
    end)
    lblFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    lblFrame:SetScript("OnClick", function() end)

    -- Test button clicks — wired here so r is in scope
    raidTestBtn:SetScript("OnClick",  function() local a = r._ability; if a then testAbility(a, IsShiftKeyDown() and "H" or "M") end end)
    mplusTestBtn:SetScript("OnClick", function() local a = r._ability; if a then testAbility(a, "M") end end)

    warnCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            local en = self:GetChecked()
            CCS.SetWarnEnabled(a.key, en)
            CCS.RefreshAbility(a.key, a)
            warnDD:SetEnabled(en)
            refreshWarnDD()
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
        end)
    end)
    warnDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetWarnOverride(a.key, v ~= "__default__" and v or nil)
            CCS.RefreshAbility(a.key, a)
        end)
    end)
    hCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "H", self:GetChecked())
            CCS.RefreshAbility(a.key, a); refreshHDD()
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
        end)
    end)
    hDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            r._hOver = v ~= "__default__" and v or nil
            r._hNoDefault = (r._hDefaultCD == nil and r._hOver == nil)
            CCS.SetCountdownOverride(a.key, "H", r._hOver)
            CCS.RefreshAbility(a.key, a); refreshHDD()
        end)
    end)
    mCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "M", self:GetChecked())
            CCS.RefreshAbility(a.key, a); refreshMDD()
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
        end)
    end)
    mDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            r._mOver = v ~= "__default__" and v or nil
            r._mNoDefault = (r._mDefaultCD == nil and r._mOver == nil)
            CCS.SetCountdownOverride(a.key, "M", r._mOver)
            CCS.RefreshAbility(a.key, a); refreshMDD()
        end)
    end)
    cdCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "M", self:GetChecked())
            CCS.RefreshAbility(a.key, a); refreshCdDD()
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
        end)
    end)
    cdDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            r._cdOver = v ~= "__default__" and v or nil
            CCS.SetCountdownOverride(a.key, "M", r._cdOver)
            CCS.RefreshAbility(a.key, a); refreshCdDD()
        end)
    end)

    -- rebind: zero-allocation row reuse.
    function r.rebind(ability, isMplus)
        r._ability = ability
        r._isMplus = isMplus

        local pid = ability.privateID
        local scalarID = getScalarID(pid)
        local texID = scalarID and C_Spell.GetSpellTexture(scalarID)
        if texID then icon:SetTexture(texID); icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        else          icon:SetColorTexture(0.2, 0.2, 0.2, 0.5) end
        lbl:SetText(ability.label)
        if scalarID then C_Spell.RequestLoadSpellData(scalarID) end

        local defaultWarn = getDefaultWarn(ability)
        r._warnNoDefault = (defaultWarn == nil)
        r._warnCtrl.abilityKey = ability.key
        warnDD:SetItems(buildWarnItems(defaultWarn))
        warnDD._defaultWarn  = defaultWarn
        warnDD._defaultSound = defaultWarn
        warnDD._abilityKey   = ability.key
        warnDD:SetValue(CCS.GetWarnOverride(ability.key) or "__default__")
        local warnEn = CCS.isWarnEnabled(ability.key)
        warnCB:SetChecked(warnEn)
        refreshWarnDD()

        if isMplus then
             hLbl:Hide(); hCB:Hide(); hDD:Hide(); hNoLbl:Hide(); hValLbl:Hide()
             mLbl:Hide(); mCB:Hide(); mDD:Hide(); mNoLbl:Hide(); mValLbl:Hide()

            cdCB:ClearAllPoints();      cdCB:SetPoint(     "LEFT", rightCell, "LEFT", MPLUS_CHECKBOX_X, 0)
            cdDD:ClearAllPoints();      cdDD:SetPoint(     "LEFT", rightCell, "LEFT", MPLUS_DROPDOWN_X, 0)
            cdNoLbl:ClearAllPoints();   cdNoLbl:SetPoint(  "LEFT", rightCell, "LEFT", MPLUS_DROPDOWN_X, 0)
            cdValLbl:ClearAllPoints();  cdValLbl:SetPoint( "LEFT", rightCell, "LEFT", MPLUS_DROPDOWN_X, 0)

            r._cdDefaultCD = getDefaultCountdown(ability, "M") or getDefaultCountdown(ability, "H")
            r._cdOver      = CCS.GetCountdownOverride(ability.key, "M")
            r._cdCtrl.abilityKey = ability.key
            cdCB:SetChecked(CCS.IsCDEnabled(ability.key, "M"))
            cdDD:SetItems(buildCountdownItems(r._cdDefaultCD))
            cdDD._defaultSound = r._cdDefaultCD
            cdDD:SetValue(r._cdOver or "__default__")
            cdCB:Show()
            refreshCdDD()
        else
             cdCB:Hide(); cdDD:Hide(); cdNoLbl:Hide(); cdValLbl:Hide()

            r._hDefaultCD  = getDefaultCountdown(ability, "H")
            r._mDefaultCD  = getDefaultCountdown(ability, "M")
            r._hOver       = CCS.GetCountdownOverride(ability.key, "H")
            r._mOver       = CCS.GetCountdownOverride(ability.key, "M")
            r._hNoDefault  = (r._hDefaultCD == nil and r._hOver == nil)
            r._mNoDefault  = (r._mDefaultCD == nil and r._mOver == nil)
            r._hCtrl.abilityKey = ability.key
            r._mCtrl.abilityKey = ability.key

            hCB:SetChecked(CCS.IsCDEnabled(ability.key, "H"))
            hDD:SetItems(buildCountdownItems(r._hDefaultCD))
            hDD._defaultSound = r._hDefaultCD
            hDD:SetValue(r._hOver or "__default__")
            mCB:SetChecked(CCS.IsCDEnabled(ability.key, "M"))
            mDD:SetItems(buildCountdownItems(r._mDefaultCD))
            mDD._defaultSound = r._mDefaultCD
            mDD:SetValue(r._mOver or "__default__")

            local ctOn = CCS.GetCustomTimerOverride()
            if ctOn then
                -- Manual mode.
                hLbl:ClearAllPoints();      hLbl:SetPoint(     "LEFT", rightCell, "LEFT", RAID_HC_LBL_X, 0)
                hCB:ClearAllPoints();       hCB:SetPoint(      "LEFT", rightCell, "LEFT", RAID_HC_CHECKBOX_X, 0)
                hDD:ClearAllPoints();       hDD:SetPoint(      "LEFT", rightCell, "LEFT", RAID_HC_DROPDOWN_X, 0)
                hNoLbl:ClearAllPoints();    hNoLbl:SetPoint(   "LEFT", rightCell, "LEFT", RAID_HC_DROPDOWN_X, 0)
                hValLbl:ClearAllPoints();   hValLbl:SetPoint(  "LEFT", rightCell, "LEFT", RAID_HC_DROPDOWN_X, 0)
                mLbl:ClearAllPoints();      mLbl:SetPoint(     "LEFT", rightCell, "LEFT", RAID_MYTHIC_LBL_X, 0)
                mCB:ClearAllPoints();       mCB:SetPoint(      "LEFT", rightCell, "LEFT", RAID_MYTHIC_CHECKBOX_X, 0)
                mDD:ClearAllPoints();       mDD:SetPoint(      "LEFT", rightCell, "LEFT", RAID_MYTHIC_DROPDOWN_X, 0)
                mNoLbl:ClearAllPoints();    mNoLbl:SetPoint(   "LEFT", rightCell, "LEFT", RAID_MYTHIC_DROPDOWN_X, 0)
                mValLbl:ClearAllPoints();   mValLbl:SetPoint(  "LEFT", rightCell, "LEFT", RAID_MYTHIC_DROPDOWN_X, 0)
            else
                -- Simple mode (refresh handles visibility).
                hLbl:ClearAllPoints();      hLbl:SetPoint(     "LEFT", rightCell, "LEFT", RAID_HC_LBL_X, 0)
                hCB:ClearAllPoints();       hCB:SetPoint(      "LEFT", rightCell, "LEFT", RAID_HC_CHECKBOX_X, 0)
                hDD:ClearAllPoints();       hDD:SetPoint(      "LEFT", rightCell, "LEFT", RAID_HC_DROPDOWN_X, 0)
                hNoLbl:ClearAllPoints();    hNoLbl:SetPoint(   "LEFT", rightCell, "LEFT", RAID_HC_DROPDOWN_X, 0)
                hValLbl:ClearAllPoints();   hValLbl:SetPoint(  "LEFT", rightCell, "LEFT", RAID_HC_DROPDOWN_X, 0)
                mLbl:ClearAllPoints();      mLbl:SetPoint(     "LEFT", rightCell, "LEFT", RAID_MYTHIC_LBL_X, 0)
                mCB:ClearAllPoints();       mCB:SetPoint(      "LEFT", rightCell, "LEFT", RAID_MYTHIC_CHECKBOX_X, 0)
                mDD:ClearAllPoints();       mDD:SetPoint(      "LEFT", rightCell, "LEFT", RAID_MYTHIC_DROPDOWN_X, 0)
                mNoLbl:ClearAllPoints();    mNoLbl:SetPoint(   "LEFT", rightCell, "LEFT", RAID_MYTHIC_DROPDOWN_X, 0)
                mValLbl:ClearAllPoints();   mValLbl:SetPoint(  "LEFT", rightCell, "LEFT", RAID_MYTHIC_DROPDOWN_X, 0)
            end

            refreshHDD(); refreshMDD()
        end
    end

    -- Resync controls from DB without repositioning.
    function r.syncFromDB()
        local a = r._ability; if not a then return end
        local warnEn = CCS.isWarnEnabled(a.key)
        warnCB:SetChecked(warnEn)
        refreshWarnDD()
        if r._isMplus then
            cdCB:SetChecked(CCS.IsCDEnabled(a.key, "M"))
            refreshCdDD()
        else
            hCB:SetChecked(CCS.IsCDEnabled(a.key, "H"))
            mCB:SetChecked(CCS.IsCDEnabled(a.key, "M"))
            refreshHDD(); refreshMDD()
        end
    end

    -- ctrl tables for bulk enable/disable; abilityKey filled in by rebind.
    r._warnCtrl = {
        cb=warnCB, abilityKey=nil,
        syncFromDB = function() r.syncFromDB() end,
        setEnabled = function(en)
            local a = r._ability; if not a then return end
            CCS.SetWarnEnabled(a.key, en); warnCB:SetChecked(en)
            CCS.RefreshAbility(a.key, a); refreshWarnDD()
        end,
    }
    r._cdCtrl = {
        cb=cdCB, diff="M", abilityKey=nil,
        syncFromDB = function() r.syncFromDB() end,
        setEnabled = function(en)
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "M", en); cdCB:SetChecked(en)
            CCS.RefreshAbility(a.key, a); refreshCdDD()
        end,
    }
    r._hCtrl = {
        cb=hCB, diff="H", abilityKey=nil,
        syncFromDB = function() r.syncFromDB() end,
        setEnabled = function(en)
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "H", en); hCB:SetChecked(en)
            CCS.RefreshAbility(a.key, a); refreshHDD()
        end,
    }
    r._mCtrl = {
        cb=mCB, diff="M", abilityKey=nil,
        syncFromDB = function() r.syncFromDB() end,
        setEnabled = function(en)
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "M", en); mCB:SetChecked(en)
            CCS.RefreshAbility(a.key, a); refreshMDD()
        end,
    }

    _pool.rows[idx] = r
    return r
end

local function acquireHeader(scrollChild, idx)
    if not _pool.headers[idx] then
        local frame = CreateFrame("Frame", nil, scrollChild)
        local lbl = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
        lbl:SetPoint("LEFT", frame, "LEFT", 0, 0)
        frame._lbl = lbl
        _pool.headers[idx] = frame
    end
    return _pool.headers[idx]
end

local SHOW_ALL_H = 14  -- height of the Show all row

local function acquireShowAll(scrollChild, idx)
    if not _pool.showAlls[idx] then
        local frame = CreateFrame("Frame", nil, scrollChild)
        frame:SetHeight(SHOW_ALL_H)
        local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        cb:SetSize(14, 14)
        stripCheckBorder(cb)
        cb:SetPoint("LEFT", frame, "LEFT", INDENT, 0)
        local lbl = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        lbl:SetText("|cffaaaaaa Show all|r")
        lbl:SetPoint("LEFT", cb, "RIGHT", 2, 0)
        addTooltip(cb, "Show all", "Show additional trackable private auras for this boss that have no default values set.")
        frame._cb  = cb
        frame._lbl = lbl
        _pool.showAlls[idx] = frame
    end
    return _pool.showAlls[idx]
end

local function acquireRaidBg(scrollChild, idx)
    if not _pool.raidBgs[idx] then
        local bg  = CreateFrame("Frame", nil, scrollChild)
        local tex = bg:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints(); tex:SetColorTexture(0.078, 0.078, 0.078, 1)
        local lbl = bg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        lbl:SetPoint("CENTER"); lbl:SetJustifyH("CENTER")
        bg._lbl = lbl
        _pool.raidBgs[idx] = bg
    end
    return _pool.raidBgs[idx]
end

local function acquireSep(scrollChild, idx)
    if not _pool.seps[idx] then
        local s = scrollChild:CreateTexture(nil, "BACKGROUND")
        s:SetHeight(1)
        _pool.seps[idx] = s
    end
    return _pool.seps[idx]
end

local function acquireDivider(scrollChild)
    if not _pool.divider then
        local d = scrollChild:CreateTexture(nil, "BACKGROUND")
        d:SetColorTexture(0.3, 0.3, 0.3, 0.8)
        d:SetWidth(1)
        _pool.divider = d
    end
    return _pool.divider
end

------------------------------------------------------------
-- One-time frame creation (first panel show)
------------------------------------------------------------

local function BuildFramePool(scrollChild)
    local rowIdx  = 0
    local hdrCount, raidCount, sepCount, showAllCount = 0, 0, 0, 0
    for _, entry in ipairs(CCS_Spells) do
        if entry.abilities then
            hdrCount = hdrCount + 1
            if entry.raid then raidCount = raidCount + 1; sepCount = sepCount + 2 end
            sepCount = sepCount + 1
            for _ in ipairs(entry.abilities) do
                rowIdx = rowIdx + 1
                acquireRow(scrollChild, rowIdx)
            end
            if entry.bossKey then
                local hasAdv = false
                for _, ab in ipairs(entry.abilities) do if ab.advanced then hasAdv = true; break end end
                if hasAdv then showAllCount = showAllCount + 1 end
            end
        end
    end
    for i = 1, hdrCount    do acquireHeader(scrollChild,  i) end
    for i = 1, raidCount   do acquireRaidBg(scrollChild,  i) end
    for i = 1, sepCount    do acquireSep(scrollChild,     i) end
    for i = 1, showAllCount do acquireShowAll(scrollChild, i) end
    acquireDivider(scrollChild)
end

------------------------------------------------------------
-- rebindAll
------------------------------------------------------------

local function rebindAll(scrollChild, totalWidth, leftW, isMplus)
    local rightW = totalWidth - leftW

    local y        = 4
    local rowIdx   = 0
    local hdrIdx   = 0
    local raidIdx  = 0
    local sepIdx   = 0
    local showAllIdx = 0
    local lastRaid = nil
    local divTopY  = nil

    local divider = _pool.divider

    for _, entry in ipairs(CCS_Spells) do
        if entry.abilities then

        local justRaidHdr = false

        if entry.raid and entry.raid ~= lastRaid then
            lastRaid     = entry.raid
            justRaidHdr  = true
            if y < -8 then y = y - 8 end

            sepIdx = sepIdx + 1
            local s1 = acquireSep(scrollChild, sepIdx)
            s1:SetColorTexture(0.4, 0.4, 0.4, 0.5)
            s1:ClearAllPoints()
            s1:SetPoint("TOPLEFT",  scrollChild, "TOPLEFT", 0,          y)
            s1:SetPoint("TOPRIGHT", scrollChild, "TOPLEFT", totalWidth, y)
            s1:Show(); y = y - 1

            raidIdx = raidIdx + 1
            local bg = acquireRaidBg(scrollChild, raidIdx)
            bg:ClearAllPoints()
            bg:SetPoint("TOPLEFT",  scrollChild, "TOPLEFT", 0,          y)
            bg:SetPoint("TOPRIGHT", scrollChild, "TOPLEFT", totalWidth, y)
            bg:SetHeight(32)
            bg._lbl:SetText((entry._color or RAID_COLORS[entry.raid] or "|cffcccccc") .. entry.raid .. "|r")
            bg:Show(); y = y - 32

            sepIdx = sepIdx + 1
            local s2 = acquireSep(scrollChild, sepIdx)
            s2:SetColorTexture(0.4, 0.4, 0.4, 0.5)
            s2:ClearAllPoints()
            s2:SetPoint("TOPLEFT",  scrollChild, "TOPLEFT", 0,          y)
            s2:SetPoint("TOPRIGHT", scrollChild, "TOPLEFT", totalWidth, y)
            s2:Show()
            if not divTopY then divTopY = y - 1 end
            y = y - 8
        end

        if not justRaidHdr and y < -8 then
            sepIdx = sepIdx + 1
            local sep = acquireSep(scrollChild, sepIdx)
            sep:SetColorTexture(0.25, 0.25, 0.25, 0.6)
            sep:ClearAllPoints()
            sep:SetPoint("TOPLEFT",  scrollChild, "TOPLEFT", 0,          y)
            sep:SetPoint("TOPRIGHT", scrollChild, "TOPLEFT", totalWidth, y)
            sep:Show(); y = y - 6
        end

        hdrIdx = hdrIdx + 1
        local hdr = acquireHeader(scrollChild, hdrIdx)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", INDENT, y)
        hdr:SetSize(totalWidth - INDENT * 2, SECTION_HEADER_H)
        local sectionText = entry.section or entry.boss
        if entry._color and sectionText then
            sectionText = entry._color .. sectionText .. "|r"
        end
        hdr._lbl:SetText(sectionText)
        hdr:Show(); y = y - SECTION_HEADER_H

        local bossKey = entry.bossKey
        local hasAdvanced = false
        for _, ab in ipairs(entry.abilities) do
            if ab.advanced then hasAdvanced = true; break end
        end
        local showAll = not bossKey or not hasAdvanced or CCS.GetShowAllBoss(bossKey)

        for _, ability in ipairs(entry.abilities) do
            if ability.advanced and not showAll then
                -- hidden
            else
            rowIdx = rowIdx + 1
            local r = acquireRow(scrollChild, rowIdx)

            r.leftCell:SetSize(leftW, ROW_HEIGHT)
            r.leftCell:ClearAllPoints()
            r.leftCell:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0,     y)
            r.rightCell:SetSize(rightW, ROW_HEIGHT)
            r.rightCell:ClearAllPoints()
            r.rightCell:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", leftW, y)
            r.rebind(ability, isMplus)
            r.leftCell:Show(); r.rightCell:Show()

            y = y - ROW_HEIGHT - 1
            end
        end

        -- "Show all" toggle row, below the boss block.
        if bossKey and hasAdvanced then
            y = y - 2
            showAllIdx = showAllIdx + 1
            local sa = acquireShowAll(scrollChild, showAllIdx)
            sa:ClearAllPoints()
            sa:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, y)
            sa:SetWidth(totalWidth)
            sa._cb:SetChecked(CCS.GetShowAllBoss(bossKey))
            sa._cb:SetScript("OnClick", function(self)
                withCombatGuard(function()
                    CCS.SetShowAllBoss(bossKey, self:GetChecked())
                    if CCS._fullRebuild then CCS._fullRebuild() end
                end)
            end)
            sa:Show()
            y = y - SHOW_ALL_H
        end
        y = y - 8

        end  -- if entry.abilities
    end

    -- Hide leftover pool entries.
    for i = rowIdx + 1, #_pool.rows   do _pool.rows[i].leftCell:Hide(); _pool.rows[i].rightCell:Hide() end
    for i = hdrIdx + 1, #_pool.headers do _pool.headers[i]:Hide() end
    for i = raidIdx + 1, #_pool.raidBgs do _pool.raidBgs[i]:Hide() end
    for i = sepIdx  + 1, #_pool.seps   do _pool.seps[i]:Hide() end
    for i = showAllIdx + 1, #_pool.showAlls do _pool.showAlls[i]:Hide() end

    local contentH = math.abs(y) + 16
    scrollChild:SetHeight(contentH)

    local topY = divTopY or 0
    divider:ClearAllPoints()
    divider:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", leftW, topY)
    local visibleH = scrollChild:GetParent() and scrollChild:GetParent():GetHeight() or 0
    divider:SetHeight(math.max(contentH, visibleH) - math.abs(topY))
    divider:Show()
end

------------------------------------------------------------
-- Options Panel
------------------------------------------------------------

local function BuildCCSOptions(panel, isStandalone)
    -- Forward declarations
    local built, scrollChild, fullRebuild

    -- Top block
    local topBlock = CreateFrame("Frame", nil, panel)
    topBlock:SetPoint("TOPLEFT",  panel, "TOPLEFT",   6, -6)
    topBlock:SetPoint("TOPRIGHT", panel, "TOPRIGHT", isStandalone and -6 or -36, -6)
    topBlock:SetHeight(TOP_BLOCK_H)
    local topBlockBg = topBlock:CreateTexture(nil, "BACKGROUND")
    topBlockBg:SetAllPoints()
    topBlockBg:SetColorTexture(0.078, 0.078, 0.078, 1)

    local title = topBlock:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -12)
    title:SetText(CATEGORY_NAME)

    local loadDefaultsBtn = CreateFrame("Button", nil, topBlock, "UIPanelButtonTemplate")
    loadDefaultsBtn:SetSize(70, 20)
    loadDefaultsBtn:SetPoint("RIGHT", topBlock, "TOPRIGHT", -42, -14)
    loadDefaultsBtn:SetText("Defaults")
    stripButtonBorder(loadDefaultsBtn)
    addTooltip(loadDefaultsBtn, "Load Default Configuration",
        "Resets all settings on your current profile back to the default settings.")

    local profilesBtn = CreateFrame("Button", nil, topBlock, "UIPanelButtonTemplate")
    profilesBtn:SetSize(60, 20)
    profilesBtn:SetPoint("RIGHT", loadDefaultsBtn, "LEFT", -6, 0)
    profilesBtn:SetText("Profiles")
    stripButtonBorder(profilesBtn)
    addTooltip(profilesBtn, "Profiles", "Open the profile manager.")

    profilesBtn:SetScript("OnClick", function()
        local AceConfigDialog = LibStub("AceConfigDialog-3.0")
        local AceConfig       = LibStub("AceConfig-3.0")
        local AceDBOptions    = LibStub("AceDBOptions-3.0")
        if not CCS._profileOptionsRegistered then
            AceConfig:RegisterOptionsTable("CCSProfiles", AceDBOptions:GetOptionsTable(CCS.GetDB()))
            CCS._profileOptionsRegistered = true
        end
        if AceConfigDialog.OpenFrames["CCSProfiles"] then
            AceConfigDialog:Close("CCSProfiles")
        else
            AceConfigDialog:Open("CCSProfiles")
        end
    end)

    local inst = topBlock:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    inst:SetPoint("TOPLEFT",  title,    "BOTTOMLEFT", 0,    -6)
    inst:SetPoint("TOPRIGHT", topBlock, "TOPRIGHT",  -16,    0)
    inst:SetJustifyH("LEFT"); inst:SetWordWrap(true)
    inst:SetText(
        "Choose sounds that play automatically when a private aura lands on you in Heroic or Mythic raid.\n" ..
        "Warning sounds (left side) and countdown sounds (right side) are toggled independently."
    )

    -- Confirm dialog (for Defaults button)
    local confirmDialog = CreateFrame("Frame", nil, topBlock, "BackdropTemplate")
    confirmDialog:SetSize(260, 70)
    confirmDialog:SetPoint("TOPRIGHT", topBlock, "TOPRIGHT", -12, -36)
    confirmDialog:SetFrameStrata("HIGH")
    confirmDialog:SetFrameLevel(150)
    confirmDialog:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10, insets = { left=3, right=3, top=3, bottom=3 },
    })
    confirmDialog:SetBackdropColor(0.08, 0.08, 0.08, 1)
    confirmDialog:SetBackdropBorderColor(0.8, 0.6, 0.1, 1)
    confirmDialog:Hide()

    local confirmText = confirmDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    confirmText:SetPoint("TOP", confirmDialog, "TOP", 0, -10)
    confirmText:SetText("|cffffff00This will remove your custom settings\nand load the built-in defaults.|r")
    confirmText:SetJustifyH("CENTER")

    local yesBtn = CreateFrame("Button", nil, confirmDialog, "UIPanelButtonTemplate")
    yesBtn:SetSize(60, 20)
    yesBtn:SetPoint("BOTTOMLEFT", confirmDialog, "BOTTOMLEFT", 14, 8)
    yesBtn:SetText("Yes")

    local noBtn = CreateFrame("Button", nil, confirmDialog, "UIPanelButtonTemplate")
    noBtn:SetSize(60, 20)
    noBtn:SetPoint("BOTTOMRIGHT", confirmDialog, "BOTTOMRIGHT", -14, 8)
    noBtn:SetText("No")
    noBtn:SetScript("OnClick", function() confirmDialog:Hide() end)

    loadDefaultsBtn:SetScript("OnClick", function()
        if confirmDialog:IsShown() then confirmDialog:Hide() else confirmDialog:Show() end
    end)

    -- Bulk action group boxes
    local function makeGroupBox(parent, anchor, anchorPt, xOff, yOff, selfPt)
        local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        box:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
        box:SetBackdropColor(0, 0, 0, 0)
        box:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        box:SetPoint(selfPt or "TOPLEFT", anchor, anchorPt, xOff, yOff)
        return box
    end


    local moduleBox = makeGroupBox(topBlock, topBlock, "BOTTOMRIGHT", -6, 6, "BOTTOMRIGHT")
    moduleBox:SetSize(170, 24)  -- initial size, overridden by OnShow
    local moduleLbl = moduleBox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    moduleLbl:SetText("|cffcccccc Module|r")
    moduleLbl:SetPoint("TOPLEFT", moduleBox, "TOPLEFT", 14, -7)
    local raidBtn = CreateFrame("Button", nil, moduleBox, "UIPanelButtonTemplate")
    raidBtn:SetSize(50, 20); raidBtn:SetPoint("LEFT", moduleLbl, "RIGHT", 8, 0)
    raidBtn:SetText("Raid"); stripButtonBorder(raidBtn)
    addTooltip(raidBtn, "Raid Module", "Switch to raid spell data.")
    local mplusBtn = CreateFrame("Button", nil, moduleBox, "UIPanelButtonTemplate")
    mplusBtn:SetSize(60, 20); mplusBtn:SetPoint("LEFT", raidBtn, "RIGHT", 2, 0)
    mplusBtn:SetText("Mythic+"); stripButtonBorder(mplusBtn)
    addTooltip(mplusBtn, "Mythic+ Module", "Switch to Mythic+ spell data.")
    -- auto-size module buttons and box
    moduleBox:SetScript("OnShow", function()
        local lblW   = moduleLbl:GetStringWidth()
        local raidW  = raidBtn:GetFontString()  and raidBtn:GetFontString():GetStringWidth()  + 16 or 50
        local mplusW = mplusBtn:GetFontString() and mplusBtn:GetFontString():GetStringWidth() + 16 or 60
        raidBtn:SetWidth(raidW); mplusBtn:SetWidth(mplusW)
        moduleBox:SetSize(14 + lblW + 8 + raidW + 2 + mplusW + 4, 24)
        moduleBox:SetScript("OnShow", nil)
    end)
    raidBtn:SetScript("OnClick",  function() CCS.SetModule("raid")  end)
    mplusBtn:SetScript("OnClick", function() CCS.SetModule("mplus") end)

    local function refreshModuleBtns()
        local m = CCS.GetModule()
        local activeC,  inactiveC  = 0.28, 0.10
        setButtonBg(raidBtn,  m == "raid"  and activeC or inactiveC, m == "raid"  and activeC or inactiveC, m == "raid"  and activeC or inactiveC)
        setButtonBg(mplusBtn, m == "mplus" and activeC or inactiveC, m == "mplus" and activeC or inactiveC, m == "mplus" and activeC or inactiveC)
    end
    refreshModuleBtns()
    moduleBox:SetShown(CCS.MPLUS_ENABLED)

    -- Divider below top block
    local topDivider = panel:CreateTexture(nil, "ARTWORK")
    topDivider:SetColorTexture(0.35, 0.35, 0.35, 0.8)
    topDivider:SetHeight(1)
    topDivider:SetPoint("TOPLEFT",  topBlock, "BOTTOMLEFT",  0, 0)
    topDivider:SetPoint("TOPRIGHT", topBlock, "BOTTOMRIGHT", 0, 0)

    -- Column header bar
    local headerBar = CreateFrame("Frame", nil, panel)
    headerBar:SetHeight(HEADER_BAR_H)
    headerBar:SetPoint("TOPLEFT",  topBlock, "BOTTOMLEFT",  0, 0)
    headerBar:SetPoint("TOPRIGHT", topBlock, "BOTTOMRIGHT", 0, 0)

    local leftHdrTitle = headerBar:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    leftHdrTitle:SetText("|cffFFD100Warning Sound|r")
    local rightHdrTitle = headerBar:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    rightHdrTitle:SetText("|cffFFD100Countdown Timer|r")
    local rightHdrSub = headerBar:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    rightHdrSub:SetText("|cffaaaaaa HC: Heroic          M: Mythic|r")

    -- Global "Manual Mode (Advanced)" checkbox
    local durationOverrideCB = CreateFrame("CheckButton", nil, headerBar, "UICheckButtonTemplate")
    durationOverrideCB:SetSize(16, 16)
    stripCheckBorder(durationOverrideCB)
    local durationOverrideLbl = headerBar:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    durationOverrideLbl:SetText("|cffaaaaaa Manual Mode (Advanced)|r")
    durationOverrideLbl:SetPoint("LEFT", durationOverrideCB, "RIGHT", 2, 0)
    addTooltip(durationOverrideCB, "Manual Mode (Advanced)",
        "Check this if a debuff duration is wrong, you need to manually adjust it, or if you need them customized for some other reason.\nContact me if you want a default value changed.")

    -- Bulk action boxes inside headerBar
    local warnBox = makeGroupBox(headerBar, headerBar, "BOTTOMLEFT", 0, 0, "BOTTOMLEFT")
    warnBox:SetBackdropBorderColor(0, 0, 0, 0)
    warnBox:SetSize(140, BULK_BOX_H)
    local warnBoxLbl = warnBox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    warnBoxLbl:SetText("|cffcccccc All Warnings|r")
    warnBoxLbl:SetPoint("TOP", warnBox, "TOP", 0, -4)
    warnBoxLbl:SetJustifyH("CENTER")
    local enableWarnBtn = CreateFrame("Button", nil, warnBox, "UIPanelButtonTemplate")
    enableWarnBtn:SetSize(68, 18); enableWarnBtn:SetPoint("BOTTOMLEFT", warnBox, "BOTTOMLEFT", 4, 4)
    enableWarnBtn:SetText("Enable"); stripButtonBorder(enableWarnBtn)
    addTooltip(enableWarnBtn, "Enable", "Turn on the default or user-set warning sounds for every ability.")
    local enableWarnULine = enableWarnBtn:CreateTexture(nil, "OVERLAY")
    enableWarnULine:SetColorTexture(0.8, 0.8, 0.8, 1)
    enableWarnULine:SetHeight(1)
    enableWarnULine:SetPoint("BOTTOMLEFT",  enableWarnBtn, "BOTTOMLEFT",  4, 1)
    enableWarnULine:SetPoint("BOTTOMRIGHT", enableWarnBtn, "BOTTOMRIGHT", -4, 1)
    enableWarnULine:Hide()

    local disableWarnBtn = CreateFrame("Button", nil, warnBox, "UIPanelButtonTemplate")
    disableWarnBtn:SetSize(68, 18); disableWarnBtn:SetPoint("BOTTOMRIGHT", warnBox, "BOTTOMRIGHT", -4, 4)
    disableWarnBtn:SetText("Disable"); stripButtonBorder(disableWarnBtn)
    addTooltip(disableWarnBtn, "Disable", "Turn off all warning sounds for every ability.")
    local disableWarnULine = disableWarnBtn:CreateTexture(nil, "OVERLAY")
    disableWarnULine:SetColorTexture(0.8, 0.8, 0.8, 1)
    disableWarnULine:SetHeight(1)
    disableWarnULine:SetPoint("BOTTOMLEFT",  disableWarnBtn, "BOTTOMLEFT",  4, 1)
    disableWarnULine:SetPoint("BOTTOMRIGHT", disableWarnBtn, "BOTTOMRIGHT", -4, 1)
    disableWarnULine:Hide()
    warnBox:SetScript("OnShow", function()
        local lblW = warnBoxLbl:GetStringWidth()
        local enW  = enableWarnBtn:GetFontString() and enableWarnBtn:GetFontString():GetStringWidth() + 16 or 68
        local disW = disableWarnBtn:GetFontString() and disableWarnBtn:GetFontString():GetStringWidth() + 16 or 68
        enableWarnBtn:SetWidth(enW); disableWarnBtn:SetWidth(disW)
        local w = math.max(enW + disW + 8, lblW + 16)
        warnBox:SetSize(w, BULK_BOX_H)
        warnBox:SetScript("OnShow", nil)
    end)

    local cdBox = makeGroupBox(headerBar, headerBar, "BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT")
    cdBox:SetBackdropBorderColor(0, 0, 0, 0)
    cdBox:SetSize(140, BULK_BOX_H)
    local cdBoxLbl = cdBox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    cdBoxLbl:SetText("|cffcccccc All Countdowns|r")
    cdBoxLbl:SetPoint("TOP", cdBox, "TOP", 0, -4)
    cdBoxLbl:SetJustifyH("CENTER")
    local enableCDBtn = CreateFrame("Button", nil, cdBox, "UIPanelButtonTemplate")
    enableCDBtn:SetSize(68, 18); enableCDBtn:SetPoint("BOTTOMLEFT", cdBox, "BOTTOMLEFT", 4, 4)
    enableCDBtn:SetText("Enable"); stripButtonBorder(enableCDBtn)
    addTooltip(enableCDBtn, "Enable", "Turn on the default or user-set countdown sounds for every ability.")
    local enableCDULine = enableCDBtn:CreateTexture(nil, "OVERLAY")
    enableCDULine:SetColorTexture(0.8, 0.8, 0.8, 1)
    enableCDULine:SetHeight(1)
    enableCDULine:SetPoint("BOTTOMLEFT",  enableCDBtn, "BOTTOMLEFT",  4, 1)
    enableCDULine:SetPoint("BOTTOMRIGHT", enableCDBtn, "BOTTOMRIGHT", -4, 1)
    enableCDULine:Hide()

    local disableCDBtn = CreateFrame("Button", nil, cdBox, "UIPanelButtonTemplate")
    disableCDBtn:SetSize(68, 18); disableCDBtn:SetPoint("BOTTOMRIGHT", cdBox, "BOTTOMRIGHT", -4, 4)
    disableCDBtn:SetText("Disable"); stripButtonBorder(disableCDBtn)
    addTooltip(disableCDBtn, "Disable", "Turn off all countdown sounds.")
    local disableCDULine = disableCDBtn:CreateTexture(nil, "OVERLAY")
    disableCDULine:SetColorTexture(0.8, 0.8, 0.8, 1)
    disableCDULine:SetHeight(1)
    disableCDULine:SetPoint("BOTTOMLEFT",  disableCDBtn, "BOTTOMLEFT",  4, 1)
    disableCDULine:SetPoint("BOTTOMRIGHT", disableCDBtn, "BOTTOMRIGHT", -4, 1)
    disableCDULine:Hide()
    cdBox:SetScript("OnShow", function()
        local lblW = cdBoxLbl:GetStringWidth()
        local enW  = enableCDBtn:GetFontString() and enableCDBtn:GetFontString():GetStringWidth() + 16 or 68
        local disW = disableCDBtn:GetFontString() and disableCDBtn:GetFontString():GetStringWidth() + 16 or 68
        enableCDBtn:SetWidth(enW); disableCDBtn:SetWidth(disW)
        local w = math.max(enW + disW + 8, lblW + 16)
        cdBox:SetSize(w, BULK_BOX_H)
        cdBox:SetScript("OnShow", nil)
    end)

    -- Dungeon tab strip (M+ only)
    local TAB_H   = 28
    local TAB_PAD = 4
    local TAB_GAP = 2
    local tabStrip = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    tabStrip:SetSize(110, TAB_PAD + ((#CCS.MplusDungeons + 1) * (TAB_H + TAB_GAP)) - TAB_GAP + TAB_PAD)
    tabStrip:SetPoint("TOPLEFT", headerBar, "TOPRIGHT", 4, 0)
    tabStrip:SetBackdrop({ edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
    tabStrip:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.8)
    local tabBg = tabStrip:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints(); tabBg:SetColorTexture(0.078, 0.078, 0.078, 1)

    local tabButtons = {}

    -- "All" tab at the top
    local allTab = CreateFrame("Button", nil, tabStrip, "UIPanelButtonTemplate")
    allTab:SetHeight(TAB_H)
    allTab:SetPoint("TOPLEFT",  tabStrip, "TOPLEFT",  4,  -TAB_PAD)
    allTab:SetPoint("TOPRIGHT", tabStrip, "TOPRIGHT", -4, -TAB_PAD)
    allTab:SetText("All")
    stripButtonBorder(allTab)
    local allFs = allTab:GetFontString()
    if allFs then
        allFs:SetPoint("LEFT",  allTab, "LEFT",  6, 0)
        allFs:SetPoint("RIGHT", allTab, "RIGHT", -6, 0)
        allFs:SetJustifyH("LEFT"); allFs:SetWordWrap(false); allFs:SetNonSpaceWrap(false)
    end
    allTab:SetScript("OnClick", function() CCS.SetDungeon("__all__") end)
    tabButtons["__all__"] = allTab

    for i, dungeon in ipairs(CCS.MplusDungeons) do
        local tab = CreateFrame("Button", nil, tabStrip, "UIPanelButtonTemplate")
        tab:SetHeight(TAB_H)
        tab:SetPoint("TOPLEFT",  tabStrip, "TOPLEFT",  4,  -i*(TAB_H+TAB_GAP) - TAB_PAD)
        tab:SetPoint("TOPRIGHT", tabStrip, "TOPRIGHT", -4, -i*(TAB_H+TAB_GAP) - TAB_PAD)
        tab:SetText((dungeon.color or "") .. dungeon.label .. "|r")
        stripButtonBorder(tab)
        local fs = tab:GetFontString()
        if fs then
            fs:SetPoint("LEFT",  tab, "LEFT",  6, 0)
            fs:SetPoint("RIGHT", tab, "RIGHT", -6, 0)
            fs:SetJustifyH("LEFT"); fs:SetWordWrap(false); fs:SetNonSpaceWrap(false)
        end
        tab:SetScript("OnClick", function() CCS.SetDungeon(dungeon.key) end)
        tabButtons[dungeon.key] = tab
    end

    tabStrip:SetScript("OnShow", function(self)
        local maxW = 0
        for _, tab in pairs(tabButtons) do
            local fs = tab:GetFontString()
            if fs then maxW = math.max(maxW, fs:GetStringWidth()) end
        end
        local w = maxW + 6 + 4 + 4
        self:SetWidth(w)
        self:SetScript("OnShow", nil)
    end)

    local function refreshTabs()
        local active = CCS.GetActiveDungeon()
        for key, tab in pairs(tabButtons) do
            local isActive = key == active
            setButtonBg(tab, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08)
            tab:SetAlpha(isActive and 1.0 or 0.75)
        end
    end

    -- Raid tab strip
    local raidList = CCS.GetRaidList()
    local raidTabStrip = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    raidTabStrip:SetSize(110, TAB_PAD + ((#raidList + 1) * (TAB_H + TAB_GAP)) - TAB_GAP + TAB_PAD)
    raidTabStrip:SetPoint("TOPLEFT", headerBar, "TOPRIGHT", 4, 0)
    raidTabStrip:SetBackdrop({ edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
    raidTabStrip:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.8)
    local raidTabBg = raidTabStrip:CreateTexture(nil, "BACKGROUND")
    raidTabBg:SetAllPoints(); raidTabBg:SetColorTexture(0.078, 0.078, 0.078, 1)

    local raidTabButtons = {}

    -- "All" tab at the top
    local raidAllTab = CreateFrame("Button", nil, raidTabStrip, "UIPanelButtonTemplate")
    raidAllTab:SetHeight(TAB_H)
    raidAllTab:SetPoint("TOPLEFT",  raidTabStrip, "TOPLEFT",  4,  -TAB_PAD)
    raidAllTab:SetPoint("TOPRIGHT", raidTabStrip, "TOPRIGHT", -4, -TAB_PAD)
    raidAllTab:SetText("All")
    stripButtonBorder(raidAllTab)
    local raidAllFs = raidAllTab:GetFontString()
    if raidAllFs then
        raidAllFs:SetPoint("LEFT",  raidAllTab, "LEFT",  6, 0)
        raidAllFs:SetPoint("RIGHT", raidAllTab, "RIGHT", -6, 0)
        raidAllFs:SetJustifyH("LEFT"); raidAllFs:SetWordWrap(false); raidAllFs:SetNonSpaceWrap(false)
    end
    raidAllTab:SetScript("OnClick", function() CCS.SetRaid("__all__") end)
    raidTabButtons["__all__"] = raidAllTab

    for i, raidName in ipairs(raidList) do
        local tab = CreateFrame("Button", nil, raidTabStrip, "UIPanelButtonTemplate")
        tab:SetHeight(TAB_H)
        tab:SetPoint("TOPLEFT",  raidTabStrip, "TOPLEFT",  4,  -i*(TAB_H+TAB_GAP) - TAB_PAD)
        tab:SetPoint("TOPRIGHT", raidTabStrip, "TOPRIGHT", -4, -i*(TAB_H+TAB_GAP) - TAB_PAD)
        local color = RAID_COLORS[raidName] or "|cffcccccc"
        tab:SetText(color .. raidName .. "|r")
        stripButtonBorder(tab)
        local fs = tab:GetFontString()
        if fs then
            fs:SetPoint("LEFT",  tab, "LEFT",  6, 0)
            fs:SetPoint("RIGHT", tab, "RIGHT", -6, 0)
            fs:SetJustifyH("LEFT"); fs:SetWordWrap(false); fs:SetNonSpaceWrap(false)
        end
        tab:SetScript("OnClick", function() CCS.SetRaid(raidName) end)
        raidTabButtons[raidName] = tab
    end

    raidTabStrip:SetScript("OnShow", function(self)
        local maxW = 0
        for _, tab in pairs(raidTabButtons) do
            local fs = tab:GetFontString()
            if fs then maxW = math.max(maxW, fs:GetStringWidth()) end
        end
        self:SetWidth(maxW + 6 + 4 + 4)
        self:SetScript("OnShow", nil)
    end)

    local function refreshRaidTabs()
        local active = CCS.GetActiveRaid()
        for name, tab in pairs(raidTabButtons) do
            local isActive = name == active
            setButtonBg(tab, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08)
            tab:SetAlpha(isActive and 1.0 or 0.75)
        end
    end


    local function syncTabVisibility()
        local isMplus = CCS.MPLUS_ENABLED and CCS.GetModule() == "mplus"
        tabStrip:SetShown(isMplus)
        raidTabStrip:SetShown(not isMplus and #CCS.GetRaidList() > 1)
        if isMplus then refreshTabs() else refreshRaidTabs() end
        refreshModuleBtns()
    end
    syncTabVisibility()

    -- Fixed divider under header bar (stays visible while scrolling)
    local headerDivider = panel:CreateTexture(nil, "OVERLAY", nil, 7)
    headerDivider:SetColorTexture(0.35, 0.35, 0.35, 1)
    headerDivider:SetHeight(1)
    headerDivider:SetPoint("TOPLEFT",  headerBar, "BOTTOMLEFT",  0, 0)
    headerDivider:SetPoint("TOPRIGHT", headerBar, "BOTTOMRIGHT", 0, 0)

    -- Scroll frame
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",     headerBar, "BOTTOMLEFT",  0,  -1)
    scroll:SetPoint("BOTTOMRIGHT", panel,     "BOTTOMRIGHT", -6,  10)

    if scroll.ScrollBar then
        scroll.ScrollBar:ClearAllPoints()
        scroll.ScrollBar:SetPoint("TOPRIGHT",    scroll, "TOPRIGHT",    0, -16)
        scroll.ScrollBar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0,  16)
    end

    local function updateScrollBar()
        if not scroll.ScrollBar then return end
        local contentH = scrollChild and scrollChild:GetHeight() or 0
        local viewH    = scroll:GetHeight()
        local range    = math.max(0, contentH - viewH)
        local needs    = range > 0
        scroll.ScrollBar:SetShown(needs)
        if needs then
            scroll.ScrollBar:SetMinMaxValues(0, range)
            scroll.ScrollBar:SetValueStep(ROW_HEIGHT)
            scroll.ScrollBar:SetValue(math.min(scroll:GetVerticalScroll(), range))
        else
            scroll:SetVerticalScroll(0)
        end
    end

    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local max = math.max(0, scrollChild:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScroll() - delta * ROW_HEIGHT * 3, max)))
        if scroll.ScrollBar then scroll.ScrollBar:SetValue(self:GetVerticalScroll()) end
    end)

    if scroll.ScrollBar then
        scroll.ScrollBar:SetScript("OnValueChanged", function(self, value)
            scroll:SetVerticalScroll(value)
        end)
    end
    scroll:HookScript("OnShow",        updateScrollBar)
    scroll:HookScript("OnSizeChanged", updateScrollBar)

    scrollChild = CreateFrame("Frame")
    scrollChild:SetWidth(1); scrollChild:SetHeight(1)
    scroll:SetScrollChild(scrollChild)

    local function updateHeaders(leftW, cdCx, totalWidth)
        local warnDDCx = leftW - 8 - WARN_DROPDOWN_W / 2
        leftHdrTitle:ClearAllPoints()
        leftHdrTitle:SetPoint("CENTER", headerBar, "LEFT", warnDDCx - 20, 8)
        rightHdrSub:ClearAllPoints()
        rightHdrTitle:ClearAllPoints()

        warnBox:ClearAllPoints()
        warnBox:SetPoint("TOPLEFT", headerBar, "TOPLEFT", 0, 0)
        warnBox:SetHeight(BULK_BOX_H)

        cdBox:ClearAllPoints()
        cdBox:SetPoint("TOPRIGHT", headerBar, "TOPRIGHT", 0, 0)
        cdBox:SetHeight(BULK_BOX_H)

        durationOverrideLbl:ClearAllPoints()
        durationOverrideLbl:SetPoint("BOTTOMRIGHT", headerBar, "BOTTOMRIGHT", -8, 6)
        durationOverrideCB:ClearAllPoints()
        durationOverrideCB:SetPoint("RIGHT", durationOverrideLbl, "LEFT", 0, 0)
        durationOverrideCB:SetChecked(CCS.GetCustomTimerOverride())

        if CCS.GetModule() == "mplus" then
            rightHdrSub:Hide()
            rightHdrTitle:SetPoint("CENTER", headerBar, "LEFT", leftW + cdCx, 8)
        else
            rightHdrSub:Show()
            rightHdrSub:SetPoint("CENTER",  headerBar, "LEFT", leftW + cdCx, -6)
            rightHdrTitle:SetPoint("BOTTOM", rightHdrSub, "TOP", 0, 1)
        end
    end

    local _leftW = nil  -- set on first build, stable thereafter

    fullRebuild = function()
        if not built or not _leftW then return end
        local w = scroll:GetWidth()
        local cdCx = (RAID_HC_CHECKBOX_X + RAID_MYTHIC_DROPDOWN_X + COUNTDOWN_DROPDOWN_W) / 2
        moduleBox:SetShown(CCS.MPLUS_ENABLED)
        rebindAll(scrollChild, w, _leftW, CCS.GetModule() == "mplus")
        updateHeaders(_leftW, cdCx, w)
        syncTabVisibility()
        updateScrollBar()
        if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
    end

    -- Profile change: in-place resync if already built.
    local _prevOnProfileChange = CCS._onProfileChange
    CCS._onProfileChange = function()
        if _prevOnProfileChange then _prevOnProfileChange() end
        if built then
            for _, r in ipairs(_pool.rows) do r.syncFromDB() end
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
        end
    end

    CCS._fullRebuild = function() fullRebuild() end

    local function refreshBulkUnderlines()
        local ws = CCS.GetBulkWarnState()
        enableWarnULine:SetShown(ws == "all_on")
        disableWarnULine:SetShown(ws == "all_off")
        local cs = CCS.GetBulkCDState()
        enableCDULine:SetShown(cs == "all_on")
        disableCDULine:SetShown(cs == "all_off")
    end
    CCS._refreshBulkUnderlines = refreshBulkUnderlines

    enableWarnBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            CCS.SetAllWarn(true)
            for _, r in ipairs(_pool.rows) do r.syncFromDB() end
            CCS.RefreshSounds()
            refreshBulkUnderlines()
        end)
    end)
    disableWarnBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            CCS.SetAllWarn(false)
            for _, r in ipairs(_pool.rows) do r.syncFromDB() end
            CCS.RefreshSounds()
            refreshBulkUnderlines()
        end)
    end)
    enableCDBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            CCS.SetAllCD(true)
            for _, r in ipairs(_pool.rows) do r.syncFromDB() end
            CCS.RefreshSounds()
            refreshBulkUnderlines()
        end)
    end)
    disableCDBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            CCS.SetAllCD(false)
            for _, r in ipairs(_pool.rows) do r.syncFromDB() end
            CCS.RefreshSounds()
            refreshBulkUnderlines()
        end)
    end)

    -- Global Manual mode (advanced) checkbox
    durationOverrideCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            CCS.SetCustomTimerOverride(self:GetChecked())
            CCS.RefreshSounds()
            fullRebuild()
        end)
    end)

    yesBtn:SetScript("OnClick", function()
        confirmDialog:Hide()
        withCombatGuard(function()
            CCS.ResetProfile()
            fullRebuild()
        end)
    end)

    panel:SetScript("OnShow", function()
        -- Invalidate caches so newly installed LSM sounds show up.
        cachedSoundItems = nil
        wipe(_warnItemsCache)

        if not built then
            built = true
            local w = scroll:GetWidth()
            scrollChild:SetWidth(w)
            _leftW = math.floor(w * LEFT_PANEL_FRACTION)

            BuildFramePool(scrollChild)

            local cdCx = (RAID_HC_CHECKBOX_X + RAID_MYTHIC_DROPDOWN_X + COUNTDOWN_DROPDOWN_W) / 2
            rebindAll(scrollChild, w, _leftW, CCS.GetModule() == "mplus")
            updateHeaders(_leftW, cdCx, w)
            updateScrollBar()
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
        else
            -- Already built; re-apply module then resync.
            if CCS.ApplyModule then CCS.ApplyModule() end
            fullRebuild()
        end
    end)

    return panel
end

------------------------------------------------------------
-- Minimap Button
------------------------------------------------------------

local toggleStandalone

local function CreateMinimapButton()
    local DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not DBIcon then return end

    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then return end

    -- Spaceless key — button-manager addons sometimes miss names with spaces.
    local LDB_KEY = "CustomCountdownSounds"

    local dataObject = LDB:NewDataObject(LDB_KEY, {
        type  = "launcher",
        label = CATEGORY_NAME,
        icon  = "Interface\\AddOns\\" .. addonName .. "\\icon.tga",
        OnClick = function(_, btn)
            if InCombatLockdown() then
                print("|cffffff00CCS:|r Cannot open settings during combat.")
                return
            end
            if btn == "RightButton" and IsShiftKeyDown() then
                local char = CCS.GetChar()
                char.minimap.hide = true
                DBIcon:Hide(LDB_KEY)
                print("|cffffff00CCS:|r Minimap button hidden. Use |cffffffff/ccs minimap|r to restore.")
                return
            end
            toggleStandalone()
        end,
        OnTooltipShow = function(tt)
            tt:AddLine(CATEGORY_NAME, 1, 1, 1)
            tt:AddLine("Click to open settings.", 0.8, 0.8, 0.8)
            tt:AddLine("Drag to reposition.", 0.8, 0.8, 0.8)
            tt:AddLine("Shift+Right-click to hide.", 0.8, 0.8, 0.8)
        end,
    })

    local minimapDB = CCS.GetChar().minimap
    if not DBIcon:IsRegistered(LDB_KEY) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_LOGIN")
        f:SetScript("OnEvent", function(self)
            DBIcon:Register(LDB_KEY, dataObject, minimapDB)
            self:UnregisterEvent("PLAYER_LOGIN")
        end)
    end
end

------------------------------------------------------------
-- Register, slash, init
------------------------------------------------------------

local function CreateStubPanel()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel.name  = CATEGORY_NAME

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText(CATEGORY_NAME)

    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetWidth(500); desc:SetJustifyH("LEFT"); desc:SetWordWrap(true)
    desc:SetText(
        "Custom Countdown Sounds lets you configure sounds that play automatically when private auras " ..
        "land on you during Heroic and Mythic raid encounters. Each ability can have an independent " ..
        "warning sound (plays on aura apply) and a countdown sound (plays at a set interval before " ..
        "the ability fires). Sounds can be customised per-ability and saved into profiles."
    )

    local slashTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    slashTitle:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    slashTitle:SetText("Slash Commands")

    local prev = slashTitle
    for _, entry in ipairs({
        { cmd="/ccs",          desc="Open the options window."         },
        { cmd="/ccs reset",    desc="Reset window position and size."  },
        { cmd="/ccs sounds",   desc="Debug registered sounds."         },
        { cmd="/ccs minimap",  desc="Toggle the minimap button."       },
    }) do
        local line = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        line:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, prev == slashTitle and -8 or -4)
        line:SetJustifyH("LEFT")
        line:SetText("|cffffffff" .. entry.cmd .. "|r  —  " .. entry.desc)
        prev = line
    end

    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(120, 24); btn:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
    btn:SetText("Open Options")
    btn:SetScript("OnClick", function() toggleStandalone() end)

    return panel
end

local function CreateStandaloneWindow()
    local MIN_H = 300
    local MAX_H = 1200

    local win = CreateFrame("Frame", "CCSStandaloneWindow", UIParent, "BackdropTemplate")
    win:SetSize(780, 600); win:SetPoint("CENTER")
    win:SetFrameStrata("HIGH"); win:SetFrameLevel(10); win:SetMovable(true); win:EnableMouse(true)
    win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", function(self) self:StartMoving() end)
    win:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local left = self:GetLeft()
        local top  = self:GetTop()
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    end)
    win:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10, insets = { left=3, right=3, top=3, bottom=3 },
    })
    win:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    local bg = win:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetColorTexture(0.1, 0.1, 0.1, 0.98)
    win:Hide()
    tinsert(UISpecialFrames, "CCSStandaloneWindow")

    local closeBtn = CreateFrame("Button", nil, win, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", win, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() win:Hide() end)

    -- Resize handle
    local handle = CreateFrame("Frame", nil, win)
    handle:SetHeight(8)
    handle:SetWidth(100)
    handle:SetPoint("BOTTOM", win, "BOTTOM", 0, 2)
    handle:EnableMouse(true)

    local handleTex = handle:CreateTexture(nil, "BACKGROUND")
    handleTex:SetAllPoints()
    handleTex:SetColorTexture(0.5, 0.5, 0.5, 0.3)

    local grip = handle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    grip:SetPoint("CENTER")
    grip:SetText("|cff666666· · · · ·|r")

    handle:SetScript("OnEnter", function() handleTex:SetColorTexture(0.8, 0.8, 0.8, 0.4) end)
    handle:SetScript("OnLeave", function() handleTex:SetColorTexture(0.5, 0.5, 0.5, 0.3) end)

    handle:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "LeftButton" then return end
        local left = win:GetLeft()
        local top  = win:GetTop()
        win:ClearAllPoints()
        win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
        handle:SetScript("OnUpdate", function()
            local curY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local newH = math.max(MIN_H, math.min(MAX_H, win:GetTop() - curY))
            win:SetHeight(newH)
        end)
    end)
    handle:SetScript("OnMouseUp", function()
        handle:SetScript("OnUpdate", nil)
    end)

    return BuildCCSOptions(win, true)
end

local standaloneWindow

toggleStandalone = function()
    if InCombatLockdown() then
        print("|cffffff00CCS:|r Cannot open settings during combat.")
        return
    end
    if not standaloneWindow then return end
    standaloneWindow:SetShown(not standaloneWindow:IsShown())
end

SLASH_CCS1 = "/ccs"
SlashCmdList["CCS"] = function(msg)
    local arg = msg and msg:match("^%s*(%S+)") or ""
    arg = arg:lower()

    if arg == "plexus" then
        if not CCS._plexusTestEntry then
            print("|cffffff00CCS:|r Plexus test entry not loaded (data file missing).")
            return
        end
        local idx
        for i, entry in ipairs(CCS_Spells_Raid) do
            if entry.bossKey == "plexus_sentinel" then idx = i; break end
        end
        if idx then
            table.remove(CCS_Spells_Raid, idx)
            print("|cffffff00CCS:|r Plexus Sentinel test |cffff5555disabled|r.")
        else
            table.insert(CCS_Spells_Raid, 1, CCS._plexusTestEntry)
            print("|cffffff00CCS:|r Plexus Sentinel test |cff00ff00enabled|r.")
        end
        if CCS._fullRebuild then CCS._fullRebuild() end
        CCS.RefreshAll()
        return
    end

    if arg == "minimap" then
        local char = CCS.GetChar()
        char.minimap.hide = not char.minimap.hide
        local DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
        if DBIcon then
            if char.minimap.hide then
                DBIcon:Hide("CustomCountdownSounds")
            else
                DBIcon:Show("CustomCountdownSounds")
            end
        end
        print("|cffffff00CCS:|r Minimap button " .. (char.minimap.hide
            and "hidden. Use |cffffffff/ccs minimap|r to restore."
            or  "shown."))
        return
    end

    if arg == "debug"       then CCS.DebugProfile(); return end
    if arg == "sounds"      then CCS.DebugSounds();  return end
    if arg == "debugsounds" then CCS.DebugSounds();  return end

    if arg == "mplus" then
        CCS.MPLUS_ENABLED = not CCS.MPLUS_ENABLED
        if not CCS.MPLUS_ENABLED and CCS.GetModule() == "mplus" then
            CCS.SetModule("raid")
        end
        if CCS.ApplyModule then CCS.ApplyModule() end
        print("|cffffff00CCS:|r Mythic+ module " .. (CCS.MPLUS_ENABLED and "|cff00ff00enabled|r." or "|cffff5555disabled|r."))
        if CCS._fullRebuild then CCS._fullRebuild() end
        return
    end

    if arg == "module" then
        local module = msg:match("^%s*%S+%s+(%S+)")
        if module then
            CCS.SetModule(module:lower())
        else
            print("|cffffff00CCS:|r Active module: |cffffffff" .. CCS.GetModule() ..
                  "|r. Use '/ccs module raid' or '/ccs module mplus'.")
        end
        return
    end

    if arg == "privatetest" then
        local failed = 0
        local sources = {
            { label = "Raid",  data = CCS_Spells_Raid },
        }
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then
                sources[#sources + 1] = { label = dungeon.label, data = data }
            end
        end
        for _, src in ipairs(sources) do
            for _, entry in ipairs(src.data) do
                if entry.abilities then
                    for _, ability in ipairs(entry.abilities) do
                        local pid = ability.privateID
                        local ids = type(pid) == "table" and {} or { pid }
                        if type(pid) == "table" then
                            if pid.H or pid.M then
                                for _, v in pairs(pid) do
                                    if type(v) == "table" then
                                        for _, id in ipairs(v) do ids[#ids+1] = id end
                                    elseif type(v) == "number" then
                                        ids[#ids+1] = v
                                    end
                                end
                            else
                                for _, id in ipairs(pid) do ids[#ids+1] = id end
                            end
                        end
                        for _, id in ipairs(ids) do
                            if id and id ~= 0 and not C_UnitAuras.AuraIsPrivate(id) then
                                print("|cffff9900CCS privatetest:|r |cffff5555NOT private:|r " ..
                                    ability.key .. " (spellID " .. id .. ") [" .. src.label .. "]")
                                failed = failed + 1
                            end
                        end
                    end
                end
            end
        end
        if failed == 0 then
            print("|cffffff00CCS privatetest:|r |cff00ff00All spell IDs are private auras.|r")
        else
            print("|cffffff00CCS privatetest:|r " .. failed .. " non-private spell ID(s) found.")
        end
        return
    end

    if arg == "testh" or arg == "testm" then
        local difficulty = arg == "testh" and "H" or "M"
        local targetSpellID = tonumber(msg:match("^%s*%S+%s+(%S+)"))
        if not targetSpellID then
            print("|cffffff00CCS:|r Usage: /ccs testH [spellID] or /ccs testM [spellID]")
            return
        end
        local matchedAbility = nil
        for _, entry in ipairs(CCS_Spells) do
            if entry.abilities then
                for _, ability in ipairs(entry.abilities) do
                    local pid = ability.privateID
                    local ids = getPrivateIDLines(pid)
                    local match = false
                    for _, line in ipairs(ids) do
                        if line.id == targetSpellID then match = true; break end
                    end
                    if match then
                        matchedAbility = ability
                        break
                    end
                end
            end
            if matchedAbility then break end
        end
        if not matchedAbility then
            print("|cffffff00CCS:|r No ability found with spellID " .. targetSpellID)
            return
        end
        print("|cffffff00CCS:|r Test — |cffffffff" .. matchedAbility.label .. "|r (" .. difficulty .. ")")
        testAbility(matchedAbility, difficulty)
        return
    end

    if arg == "reset" then
        if standaloneWindow then
            standaloneWindow:ClearAllPoints()
            standaloneWindow:SetPoint("CENTER")
            standaloneWindow:SetSize(780, 600)
            print("|cffffff00CCS:|r Window position and size reset.")
        end
        return
    end

    toggleStandalone()
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, _, name)
    if name ~= addonName then return end
    standaloneWindow = CreateStandaloneWindow()
    Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(CreateStubPanel(), CATEGORY_NAME))
    CreateMinimapButton()

    self:UnregisterEvent("ADDON_LOADED")
end)