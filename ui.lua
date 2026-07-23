-- ui.lua
local addonName = ...

-- Live search filter for the ability list (lowercased). Empty = no filter.
local searchQuery = ""

------------------------------------------------------------
-- Tiny utilities
------------------------------------------------------------

-- Font registry. Every label the addon creates goes through makeFontString,
-- which remembers it and its default font object. When the user picks a font,
-- applyFont() re-fonts them all in one pass, keeping each one's own size.
local _fontStrings = {}   -- { fs = <fontstring>, bold = <bool>, size = <n> }

-- The addon ships its own font, so there is nothing to resolve or wait for.
-- Bold is used for the large headings (raid names, boss names, window titles);
-- everything else uses the regular weight.
local FONT_REGULAR = CCS.FONT_REGULAR
local FONT_BOLD    = CCS.FONT_BOLD

-- Every heading in the UI is created from a *Large font object, so the object
-- name is enough to pick the weight without touching each call site.
local function wantsBold(fontObject)
    return type(fontObject) == "string" and fontObject:find("Large") ~= nil
end

-- Guard against a nil face or a size of 0 coming back from GetFont. Note that
-- "size or 12" does NOT catch 0, since 0 is truthy in Lua, and a zero size
-- renders nothing.
local DEFAULT_FACE = "Fonts\\FRIZQT__.TTF"
local function okSize(n)
    if type(n) == "number" and n > 0 then return n end
    return 12
end

-- A custom font can be registered (so metrics and GetStringWidth are correct)
-- while its glyphs aren't loaded yet. The string then measures fine and draws
-- nothing, which looks exactly like missing text. Re-issuing SetText forces a
-- redraw once the glyphs are available; clearing first guarantees it isn't
-- optimised away as a no-op.
local function refreshText(fs)
    local t = fs:GetText()
    if t and t ~= "" then
        fs:SetText("")
        fs:SetText(t)
    end
end

local function setFontSafe(fs, path, size, flags, fbFace, fbSize, fbFlags)
    if path and fs:SetFont(path, okSize(size), flags or "") then return end
    fs:SetFont(fbFace or DEFAULT_FACE, okSize(fbSize or size), fbFlags or flags or "")
end

local function makeFontString(parent, layer, fontObject)
    local fs = parent:CreateFontString(nil, layer, fontObject)
    -- Keep the template's size and flags; only the face changes. The captured
    -- face is the fallback if our own font ever fails to load.
    local face, size, flags = fs:GetFont()
    local entry = {
        fs = fs, face = face or DEFAULT_FACE, size = okSize(size),
        flags = flags or "", bold = wantsBold(fontObject),
    }
    _fontStrings[#_fontStrings + 1] = entry
    -- Apply straight away, so rows pooled later (during prewarm) match too.
    setFontSafe(fs, entry.bold and FONT_BOLD or FONT_REGULAR,
                entry.size, entry.flags, entry.face, entry.size, entry.flags)
    return fs
end

local _templateBtnFS = {}  -- fontstrings from UIPanelButtonTemplate buttons

local function applyFont()
    for _, e in ipairs(_fontStrings) do
        if e.fs then
            setFontSafe(e.fs, e.bold and FONT_BOLD or FONT_REGULAR,
                        e.size, e.flags, e.face, e.size, e.flags)
            refreshText(e.fs)
        end
    end
    -- Dropdown button labels (created in widgets.lua).
    for _, fs in ipairs(CCS._ddLabels or {}) do
        setFontSafe(fs, FONT_REGULAR, fs._ccsSize or 10, fs._ccsDefaultFlags or "",
                    fs._ccsDefaultFace, fs._ccsSize or 10, fs._ccsDefaultFlags)
        refreshText(fs)
    end
    -- Template button labels (Raid, Mythic+, Help, etc.).
    for _, e in ipairs(_templateBtnFS) do
        if e.fs then
            setFontSafe(e.fs, FONT_REGULAR, e.size, e.flags, e.face, e.size, e.flags)
            refreshText(e.fs)
        end
    end
    -- Boxes that auto-size to their button text must re-measure after a font
    -- change, or wider glyphs overflow their fixed width.
    if CCS._sizeModuleBox then CCS._sizeModuleBox() end
    if CCS._sizeWarnBox   then CCS._sizeWarnBox()   end
    if CCS._sizeCdBox     then CCS._sizeCdBox()     end

end
CCS._applyFont = applyFont
CCS._makeFontString = makeFontString

-- A font file's glyphs can still be loading on the first frames after login,
-- which draws the text blank even though the font applied cleanly. Re-apply a
-- few times early on; each pass just re-issues SetFont and SetText.
local _reapplyScheduled = false
local function scheduleFontReapply()
    if _reapplyScheduled then return end
    _reapplyScheduled = true
    for _, delay in ipairs({ 0.05, 0.15, 0.3, 0.6, 1, 2 }) do
        C_Timer.After(delay, applyFont)
    end
end

-- Register a UIPanelButtonTemplate button's label so applyFont restyles it.
local function registerButtonFont(btn)
    local fs = btn:GetFontString()
    if not fs then return end
    local face, size, flags = fs:GetFont()
    _templateBtnFS[#_templateBtnFS + 1] = {
        fs = fs, face = face or DEFAULT_FACE, size = okSize(size), flags = flags or "",
    }
end
CCS._registerButtonFont = registerButtonFont

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
    -- Every custom button funnels through here, so register its label for
    -- font restyling in the same place.
    registerButtonFont(btn)
end

-- brighten a widget's border on hover.
-- reads the resting colour instead of hardcoding it, or hovering an
-- advanced (green) checkbox would wipe the green on leave.
local function addBorderHighlight(widget, border, r, g, b)
    if not widget or not border then return end
    r, g, b = r or 0.8, g or 0.8, b or 0.8

    widget:HookScript("OnEnter", function()
        if border._ccsHover then return end
        border._ccsHover = true
        border._ccsR, border._ccsG, border._ccsB, border._ccsA = border:GetBackdropBorderColor()
        border:SetBackdropBorderColor(r, g, b, 1)
    end)
    widget:HookScript("OnLeave", function()
        if not border._ccsHover then return end
        border._ccsHover = false
        border:SetBackdropBorderColor(border._ccsR or 0.35, border._ccsG or 0.35,
                                      border._ccsB or 0.35, border._ccsA or 1)
    end)
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
        addBorderHighlight(cb, border)
    end
end

local function setAdvancedCbBorder(cb, isAdvanced)
    if not cb or not cb._ccsBorder then return end
    local b = cb._ccsBorder
    local r, g, bl = 0.35, 0.35, 0.35
    if isAdvanced then r, g, bl = 0.35, 0.55, 0.35 end
    if b._ccsHover then
        -- Rows are pooled: if this one is rebound while the mouse is over it,
        -- update the colour OnLeave will restore, or it would repaint the
        -- previous ability's colour onto the new one.
        b._ccsR, b._ccsG, b._ccsB, b._ccsA = r, g, bl, 1
    else
        b:SetBackdropBorderColor(r, g, bl, 1)
    end
end

-- tooltip on a frame.
-- some widgets set their own OnEnter first (dropdown border highlight), so
-- chain those instead of replacing them.
-- don't switch to HookScript: rebindAll re-tooltips pooled headers every
-- rebuild, so the handlers would stack.
local function addTooltip(frame, title, body, anchorLeft)
    frame:EnableMouse(true)

    if not frame._ccsTipHooked then
        frame._ccsPrevEnter = frame:GetScript("OnEnter")
        frame._ccsPrevLeave = frame:GetScript("OnLeave")
        frame._ccsTipHooked = true
    end

    frame._ccsTipTitle = title
    frame._ccsTipBody  = body
    frame._ccsTipLeft  = anchorLeft

    frame:SetScript("OnEnter", function(self)
        if self._ccsPrevEnter then self._ccsPrevEnter(self) end
        if self._ccsTipLeft then
            -- Open to the left, matching the ability tooltip.
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, 0)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        GameTooltip:AddLine(self._ccsTipTitle, 1, 1, 1)
        if self._ccsTipBody then GameTooltip:AddLine(self._ccsTipBody, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        if self._ccsPrevLeave then self._ccsPrevLeave(self) end
        GameTooltip:Hide()
    end)
end


local CATEGORY_NAME = "Custom Countdown Sounds"

-- dropdown widget lives in widgets.lua
local CCS_CreateDropdown = CCS.CreateDropdown

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
            PlaySoundFile(warnSoundPath, CCS.GetChannel())
            anySoundPlayed = true
        end
    end
    if CCS.IsCDEnabled(ability.key, difficulty) then
        local cdSoundField = difficulty == "M" and ability.soundM or ability.soundH
        local defaultCDKey = type(cdSoundField) == "table" and cdSoundField[2] or nil
        local resolvedCDKey = CCS.GetCountdownOverride(ability.key, difficulty) or defaultCDKey
        local cdSoundPath = resolvedCDKey and CCS.ResolvePath and CCS.ResolvePath(resolvedCDKey)
        if cdSoundPath then
            PlaySoundFile(cdSoundPath, CCS.GetChannel())
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
local ARROW_PATH = "Interface\\AddOns\\CustomCountdownSounds\\media\\"
local LEFT_PANEL_FRACTION  = 0.58  -- wider left panel; right cell padding tightened to suit

-- Column offsets
local RIGHT_CELL_PAD      = 14
local TEST_BTN_W          = 36   -- width of "Test" button
local DIFF_LBL_W          = 20   -- width of "HC:" / "M:" labels

-- Raid: HC section
local RAID_HC_LBL_X       = RIGHT_CELL_PAD
local RAID_HC_CHECKBOX_X  = RAID_HC_LBL_X + DIFF_LBL_W
local RAID_HC_DROPDOWN_X  = RAID_HC_CHECKBOX_X + CHECKBOX_SIZE + 4

-- Raid: M section
local RAID_MYTHIC_LBL_X      = RAID_HC_DROPDOWN_X + COUNTDOWN_DROPDOWN_W + 10
local RAID_MYTHIC_CHECKBOX_X = RAID_MYTHIC_LBL_X + DIFF_LBL_W
local RAID_MYTHIC_DROPDOWN_X = RAID_MYTHIC_CHECKBOX_X + CHECKBOX_SIZE + 4

-- Raid: Custom Timer is now a global header checkbox, no per-row X needed

-- M+: section
local MPLUS_CHECKBOX_X    = RIGHT_CELL_PAD
local MPLUS_DROPDOWN_X    = MPLUS_CHECKBOX_X + CHECKBOX_SIZE + 4

-- Raid header colors
local RAID_COLORS = {
    -- 12.0.x
    ["March on Quel'Danas"] = "|cff6fcf6f",
    ["The Dreamrift"]       = "|cff6aacdc",
    ["The Voidspire"]       = "|cffc17de8",
    ["Sporefall"]           = "|cffb8c777",
    -- 12.1.0
    ["The Venomous Abyss"]  = "|cff7fbf3f",
    ["The Tidebound Grotto"] = "|cff4dabd7",
}

local RAID_ICONS = {
    -- 12.0.x
    ["March on Quel'Danas"] = 7454100,
    ["The Dreamrift"]       = 7448202,
    ["The Voidspire"]       = 7490911,
    ["Sporefall"]           = 7852823,   -- NOTE: given as "Rotmire", verify the name matches
    -- 12.1.0
    ["The Venomous Abyss"]  = 8039569,
    ["The Tidebound Grotto"] = 3012069,  -- placeholder
}

------------------------------------------------------------
-- Frame pool
------------------------------------------------------------

local _pool = { rows={}, headers={}, raidBgs={}, seps={}, divider=nil }

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
        local fs = makeFontString(btn, "OVERLAY", "GameFontNormalSmall")
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
        addBorderHighlight(btn, border)
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

    local warnNoLbl = makeFontString(leftCell, "ARTWORK", "GameFontNormalSmall")
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
    local lbl = makeFontString(lblFrame, "ARTWORK", "GameFontNormal")
    lbl:SetAllPoints(); lbl:SetJustifyH("LEFT"); lbl:SetJustifyV("MIDDLE")
    local lblHL = lblFrame:CreateTexture(nil, "HIGHLIGHT")
    lblHL:SetAllPoints(); lblHL:SetColorTexture(1, 1, 1, 0.05)
    -- Expand arrow for the per-trigger sub-rows. lbl fills the frame, so this
    -- is positioned off the measured text width in rebind rather than anchored
    -- to the label's right edge.
    local chevron = lblFrame:CreateTexture(nil, "ARTWORK")
    chevron:SetSize(8, 8)
    chevron:SetVertexColor(0.44, 0.44, 0.44, 1)
    chevron:Hide()

    -- Raid right-cell controls
    local hLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")
    hLbl:SetText("|cffaaaaaa HC:|r")
    local hCB = CreateFrame("CheckButton", nil, rightCell, "UICheckButtonTemplate")
    hCB:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE); stripCheckBorder(hCB)
    local hDD = CCS_CreateDropdown(rightCell, COUNTDOWN_DROPDOWN_W, DROPDOWN_HEIGHT, COUNTDOWN_DROPDOWN_FONT_SIZE)
    hDD._popupWidth = 130
    local hNoLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")
    hNoLbl:SetText("|cff555555No default|r")
    local hValLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")

    local mLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")
    mLbl:SetText("|cffaaaaaa M:|r")
    local mCB = CreateFrame("CheckButton", nil, rightCell, "UICheckButtonTemplate")
    mCB:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE); stripCheckBorder(mCB)
    local mDD = CCS_CreateDropdown(rightCell, COUNTDOWN_DROPDOWN_W, DROPDOWN_HEIGHT, COUNTDOWN_DROPDOWN_FONT_SIZE)
    mDD._popupWidth = 130
    local mNoLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")
    mNoLbl:SetText("|cff555555No default|r")
    local mValLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")

    -- M+ right-cell controls
    local cdCB = CreateFrame("CheckButton", nil, rightCell, "UICheckButtonTemplate")
    cdCB:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE); stripCheckBorder(cdCB)
    local cdDD = CCS_CreateDropdown(rightCell, COUNTDOWN_DROPDOWN_W, DROPDOWN_HEIGHT, COUNTDOWN_DROPDOWN_FONT_SIZE)
    cdDD._popupWidth = 130
    local cdNoLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")
    cdNoLbl:SetText("|cff555555No default|r")
    local cdValLbl = makeFontString(rightCell, "ARTWORK", "GameFontNormalSmall")

    -- "Set Default" button: resets this spell's ticks, warn sound and timers.
    -- Only shown when the spell carries a custom warn or countdown override.
    local resetBtn = CreateFrame("Button", nil, rightCell)
    resetBtn:SetSize(64, ROW_HEIGHT)
    local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
    resetBg:SetAllPoints(); resetBg:SetColorTexture(0.06, 0.06, 0.06, 0.95)
    local resetBorder = CreateFrame("Frame", nil, resetBtn, "BackdropTemplate")
    resetBorder:SetAllPoints()
    resetBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
    resetBorder:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    local resetFs = makeFontString(resetBtn, "OVERLAY", "GameFontNormalSmall")
    resetFs:SetAllPoints(); resetFs:SetJustifyH("CENTER"); resetFs:SetJustifyV("MIDDLE")
    resetFs:SetText("|cffaaaaaaSet Default|r")
    local resetHl = resetBtn:CreateTexture(nil, "HIGHLIGHT")
    resetHl:SetAllPoints(); resetHl:SetColorTexture(1, 1, 1, 0.08)
    resetBtn:SetPoint("RIGHT", rightCell, "RIGHT", -RIGHT_CELL_PAD, 0)
    addBorderHighlight(resetBtn, resetBorder)
    resetBtn:Hide()

    -- Row state
    local r = {
        leftCell=leftCell, rightCell=rightCell,
        warnDD=warnDD, warnCB=warnCB, warnNoLbl=warnNoLbl, icon=icon, lbl=lbl, lblFrame=lblFrame,
        chevron=chevron,
        raidTestBtn=raidTestBtn, mplusTestBtn=mplusTestBtn,
        hLbl=hLbl, hCB=hCB, hDD=hDD, hNoLbl=hNoLbl, hValLbl=hValLbl,
        mLbl=mLbl, mCB=mCB, mDD=mDD, mNoLbl=mNoLbl, mValLbl=mValLbl,
        cdCB=cdCB, cdDD=cdDD, cdNoLbl=cdNoLbl, cdValLbl=cdValLbl,
        resetBtn=resetBtn,
        _ability=nil, _isMplus=false,
        _hDefaultCD=nil, _mDefaultCD=nil, _cdDefaultCD=nil,
        _hOver=nil, _mOver=nil, _cdOver=nil,
        _warnNoDefault=false,
    }

    -- Visibility refreshers.

    -- True if the user has set any custom warn or countdown sound on this spell.
    local function hasOverride(a)
        if not a then return false end
        if CCS.GetWarnOverride(a.key) ~= nil then return true end
        if CCS.GetCountdownOverride(a.key, "H") ~= nil then return true end
        if CCS.GetCountdownOverride(a.key, "M") ~= nil then return true end
        return false
    end

    -- Show "Set Default" only when a custom sound override exists.
    local function refreshResetBtn()
        local a = r._ability
        resetBtn:SetShown(a ~= nil and hasOverride(a))
    end
    r.refreshResetBtn = refreshResetBtn

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
        if not a or a._event then hLbl:Hide();  hCB:Hide(); hDD:Hide(); hNoLbl:Hide(); hValLbl:Hide(); return end
        local ctOn = CCS.GetCustomTimerOverride()
        local cbOn = hCB:GetChecked()
        local activeKey = r._hOver or r._hDefaultCD
        if ctOn and cbOn then
            hLbl:Show(); hCB:Show()
            hDD:Show(); hDD:SetEnabled(true)
            hNoLbl:Hide(); hValLbl:Hide()
        elseif ctOn and not activeKey then
            hLbl:Show(); hCB:Show()
            hNoLbl:Show(); hDD:Hide(); hValLbl:Hide()
        elseif activeKey then
            hLbl:Show(); hCB:Show()
            local col = r._hOver and "|cff40ff40" or "|cffcccccc"
            hValLbl:SetText(col .. shortCountdownLabel(activeKey) .. "|r")
            hValLbl:Show(); hDD:Hide(); hNoLbl:Hide()
        elseif cbOn then
            -- Ticked but no active key (manual-only CD, manual mode off).
            -- Keep the box visible so it can be unticked; nothing to play.
            hLbl:Show(); hCB:Show()
            hNoLbl:Show(); hDD:Hide(); hValLbl:Hide()
        else
            hLbl:Hide(); hCB:Hide()
            hDD:Hide(); hNoLbl:Hide(); hValLbl:Hide()
        end
        refreshTestBtn()
    end
    local function refreshMDD()
        local a = r._ability
        if not a or a._event then mLbl:Hide();  mCB:Hide(); mDD:Hide(); mNoLbl:Hide(); mValLbl:Hide(); return end
        local ctOn = CCS.GetCustomTimerOverride()
        local cbOn = mCB:GetChecked()
        local activeKey = r._mOver or r._mDefaultCD
        if ctOn and cbOn then
            mLbl:Show(); mCB:Show()
            mDD:Show(); mDD:SetEnabled(true)
            mNoLbl:Hide(); mValLbl:Hide()
        elseif ctOn and not activeKey then
            mLbl:Show(); mCB:Show()
            mNoLbl:Show(); mDD:Hide(); mValLbl:Hide()
        elseif activeKey then
            mLbl:Show(); mCB:Show()
            local col = r._mOver and "|cff40ff40" or "|cffcccccc"
            mValLbl:SetText(col .. shortCountdownLabel(activeKey) .. "|r")
            mValLbl:Show(); mDD:Hide(); mNoLbl:Hide()
        elseif cbOn then
            -- Ticked but no active key (manual-only CD, manual mode off).
            -- Keep the box visible so it can be unticked; nothing to play.
            mLbl:Show(); mCB:Show()
            mNoLbl:Show(); mDD:Hide(); mValLbl:Hide()
        else
            mLbl:Hide(); mCB:Hide()
            mDD:Hide(); mNoLbl:Hide(); mValLbl:Hide()
        end
        refreshTestBtn()
    end
    local function refreshCdDD()
        local a = r._ability
        if not a or a._event then cdCB:Hide(); cdDD:Hide(); cdNoLbl:Hide(); cdValLbl:Hide(); return end
        local ctOn = CCS.GetCustomTimerOverride()
        local cbOn = cdCB:GetChecked()
        local activeKey = r._cdOver or r._cdDefaultCD
        if ctOn and cbOn then
            cdCB:Show(); cdDD:Show(); cdDD:SetEnabled(true)
            cdNoLbl:Hide(); cdValLbl:Hide()
        elseif ctOn and not activeKey then
            cdCB:Show(); cdNoLbl:Show(); cdDD:Hide(); cdValLbl:Hide()
        elseif activeKey then
            cdCB:Show()
            local col = r._cdOver and "|cff40ff40" or "|cffcccccc"
            cdValLbl:SetText(col .. shortCountdownLabel(activeKey) .. "|r")
            cdValLbl:Show(); cdDD:Hide(); cdNoLbl:Hide()
        elseif cbOn then
            -- Ticked but no active key (manual-only CD, manual mode off).
            -- Keep the box visible so it can be unticked; nothing to play.
            cdCB:Show(); cdNoLbl:Show(); cdDD:Hide(); cdValLbl:Hide()
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
        -- Author's note (green), if the data file provides one.
        if a.desc and a.desc ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(a.desc, 0.4, 1, 0.4, true)
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
    lblFrame:SetScript("OnClick", function()
        local a = r._ability
        -- Variant sub-rows aren't expandable; only the base ability row is.
        if not a or a._event then return end
        if not CCS.GetExtraAuraTriggers() then return end
        CCS.SetSpellExpanded(a.key, not CCS.IsSpellExpanded(a.key))
        if CCS._fullRebuild then CCS._fullRebuild() end
    end)

    -- Test button clicks — wired here so r is in scope
    raidTestBtn:SetScript("OnClick",  function() local a = r._ability; if a then testAbility(a, IsShiftKeyDown() and "H" or "M") end end)
    mplusTestBtn:SetScript("OnClick", function() local a = r._ability; if a then testAbility(a, "M") end end)

    -- If a tick change on an advanced ability makes it no longer visible
    -- (Show-non-default off and no more ticks on), rebuild so the row hides.
    local function maybeRebuildForVisibility(a)
        if not a then return end
        -- A sub-row's ticks count toward its parent being opted in, so check
        -- the base ability. Variant keys aren't in the data and would always
        -- report active.
        local isVariant = a._event ~= nil
        if not (a.advanced or isVariant) then return end
        local key = isVariant and CCS.BaseKey(a.key) or a.key
        if not CCS.IsAbilityActive(key) then
            if CCS._fullRebuild then CCS._fullRebuild() end
        end
    end

    -- Every control edits the DB then needs the same follow-up. Centralising it
    -- keeps the six handlers from drifting apart.
    --   changedTick: a warn/countdown checkbox moved (may change visibility)
    local function afterChange(a, changedTick)
        CCS.RefreshAbility(a.key, a)
        r.syncFromDB()
        r.refreshCbBorders()
        refreshResetBtn()
        if changedTick and CCS._refreshBulkUnderlines then
            CCS._refreshBulkUnderlines()
        end
        if changedTick then maybeRebuildForVisibility(a) end
        -- A trigger sub-row is on screen either because its spell is expanded
        -- or because it has a sound set. Once that sound is cleared, rebuild so
        -- the row goes away unless the spell is still expanded.
        if a._event and not CCS.HasTriggerConfig(a.key) then
            local stillOpen = CCS.GetExtraAuraTriggers()
                              and CCS.IsSpellExpanded(CCS.BaseKey(a.key))
            if not stillOpen and CCS._fullRebuild then CCS._fullRebuild() end
        end
    end

    warnCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetWarnEnabled(a.key, self:GetChecked())
            afterChange(a, true)
        end)
    end)
    warnDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetWarnOverride(a.key, v ~= "__default__" and v or nil)
            afterChange(a, false)
        end)
    end)
    hCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "H", self:GetChecked())
            afterChange(a, true)
        end)
    end)
    hDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            r._hOver = v ~= "__default__" and v or nil
            CCS.SetCountdownOverride(a.key, "H", r._hOver)
            afterChange(a, false)
        end)
    end)
    mCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "M", self:GetChecked())
            afterChange(a, true)
        end)
    end)
    mDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            r._mOver = v ~= "__default__" and v or nil
            CCS.SetCountdownOverride(a.key, "M", r._mOver)
            afterChange(a, false)
        end)
    end)
    cdCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            CCS.SetCDEnabled(a.key, "M", self:GetChecked())
            afterChange(a, true)
        end)
    end)
    cdDD:SetOnSelect(function(v)
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            r._cdOver = v ~= "__default__" and v or nil
            CCS.SetCountdownOverride(a.key, "M", r._cdOver)
            afterChange(a, false)
        end)
    end)

    resetBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            local a = r._ability; if not a then return end
            -- Clear the custom warn sound and timers, but leave the tick state
            -- alone. The ticks are what keep the row visible, so an opted-in
            -- advanced spell stays put on its own.
            CCS.SetWarnOverride(a.key, nil)
            CCS.SetCountdownOverride(a.key, "H", nil)
            CCS.SetCountdownOverride(a.key, "M", nil)
            r._hOver, r._mOver, r._cdOver = nil, nil, nil
            warnDD:SetValue("__default__")
            hDD:SetValue("__default__")
            mDD:SetValue("__default__")
            cdDD:SetValue("__default__")
            afterChange(a, false)
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
        -- Sub-rows share their parent's spell, so repeating the icon adds
        -- nothing; the empty space also reads as indentation.
        icon:SetShown(not ability._event)
        lbl:SetText(ability.label)
        -- Arrow marks a row that can open into per-trigger sub-rows.
        if not ability._event and CCS.GetExtraAuraTriggers() then
            local open = CCS.IsSpellExpanded(ability.key)
            chevron:SetTexture(ARROW_PATH .. (open and "down_arrow" or "right_arrow"))
            chevron:ClearAllPoints()
            chevron:SetPoint("LEFT", lblFrame, "LEFT", (lbl:GetStringWidth() or 0) + 6, 0)
            chevron:Show()
        else
            chevron:Hide()
        end
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

        -- Green border marks advanced abilities and any tickbox the user has
        -- set a non-default value on (a warn or countdown override).
        r.refreshCbBorders()
        refreshResetBtn()
    end

    -- Recolour the tickbox borders: green for advanced abilities or any box
    -- carrying a user override. Called on rebind and whenever an override changes.
    function r.refreshCbBorders()
        local a = r._ability; if not a then return end
        -- Stack/remove sub-rows are non-default by nature, so they carry the
        -- same green marker advanced abilities get.
        local adv = a.advanced == true or a._event ~= nil
        setAdvancedCbBorder(warnCB, adv or (CCS.GetWarnOverride(a.key) ~= nil))
        if r._isMplus then
            setAdvancedCbBorder(cdCB, adv or (r._cdOver ~= nil))
        else
            setAdvancedCbBorder(hCB, adv or (r._hOver ~= nil))
            setAdvancedCbBorder(mCB, adv or (r._mOver ~= nil))
        end
    end

    -- Resync controls from DB without repositioning.
    function r.syncFromDB()
        local a = r._ability; if not a then return end
        local warnEn = CCS.isWarnEnabled(a.key)
        warnCB:SetChecked(warnEn)
        warnDD:SetEnabled(warnEn)
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
        local lbl = makeFontString(frame, "ARTWORK", "GameFontHighlightLarge")
        lbl:SetPoint("LEFT", frame, "LEFT", 0, 0)
        frame._lbl = lbl
        -- Expand arrow, sits just after the boss name. White with alpha, so it
        -- can be tinted to whatever colour the boss uses.
        local arrow = frame:CreateTexture(nil, "ARTWORK")
        arrow:SetSize(10, 10)
        arrow:SetPoint("LEFT", lbl, "RIGHT", 5, 0)
        arrow:Hide()
        frame._arrow = arrow
        -- hover highlight, same as the ability rows
        local hl = frame:CreateTexture(nil, "HIGHLIGHT")
        hl:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 2)
        hl:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 3)
        hl:SetColorTexture(1, 1, 1, 0.08)
        frame:EnableMouse(true)
        _pool.headers[idx] = frame
    end
    return _pool.headers[idx]
end

local function acquireRaidBg(scrollChild, idx)
    if not _pool.raidBgs[idx] then
        local bg  = CreateFrame("Frame", nil, scrollChild)
        local tex = bg:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints(); tex:SetColorTexture(0.078, 0.078, 0.078, 1)
        local lbl = makeFontString(bg, "OVERLAY", "GameFontNormalLarge")
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
-- Deferred pool pre-warm
------------------------------------------------------------

-- rebindAll builds rows on demand, so we don't need the whole pool up front.
-- building all ~225 rows at once was the first-open hitch (only ~66 show by
-- default). instead fill the rest in the background once the window is up.

local PREWARM_PER_TICK = 5   -- rows per frame, small enough to not hitch
local _prewarmTicker

local function StopPrewarm()
    if _prewarmTicker then
        _prewarmTicker:Cancel()
        _prewarmTicker = nil
    end
end

local function StartPrewarm(scrollChild)
    StopPrewarm()

    local total = 0
    for _, entry in ipairs(CCS_Spells) do
        if entry.abilities then total = total + #entry.abilities end
    end
    if #_pool.rows >= total then return end

    local idx = #_pool.rows
    _prewarmTicker = C_Timer.NewTicker(0, function(ticker)
        for _ = 1, PREWARM_PER_TICK do
            idx = idx + 1
            if idx > total then
                ticker:Cancel()
                _prewarmTicker = nil
                return
            end
            local r = acquireRow(scrollChild, idx)
            -- hide until a later rebind positions them
            r.leftCell:Hide()
            r.rightCell:Hide()
        end
    end)
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
    local lastRaid = nil
    local divTopY  = nil

    local divider = acquireDivider(scrollChild)

    local filtering = searchQuery ~= ""
    local function abilityMatches(ability)
        return (ability.label or ""):lower():find(searchQuery, 1, true) ~= nil
    end
    -- True if the query matches the boss/section name (color codes stripped).
    local function bossMatches(entry)
        local name = entry.boss or entry.section or ""
        name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        return name:lower():find(searchQuery, 1, true) ~= nil
    end
    -- An entry is shown when filtering if its boss name matches (whole section)
    -- or any of its abilities match.
    local function entryMatches(entry)
        if bossMatches(entry) then return true end
        for _, ab in ipairs(entry.abilities) do
            if abilityMatches(ab) then return true end
        end
        return false
    end

    for _, entry in ipairs(CCS_Spells) do
        if entry.abilities and (not filtering or entryMatches(entry)) then

        -- When the boss name itself matches, show all its abilities.
        local bossHit = filtering and bossMatches(entry)

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
        -- stop the highlight and click area at the middle divider
        hdr:SetSize(math.max(1, leftW - INDENT), SECTION_HEADER_H)

        local bossKey = entry.bossKey
        local hasAdvanced = false
        for _, ab in ipairs(entry.abilities) do
            if ab.advanced then hasAdvanced = true; break end
        end
        local showAll = not bossKey or CCS.GetShowAllBoss(bossKey)

        local sectionText = entry.section or entry.boss
        if entry._color and sectionText then
            sectionText = entry._color .. sectionText .. "|r"
        end
        hdr._lbl:SetText(sectionText)

        -- Expand arrow: right when collapsed, down when open. Tinted to match
        -- the boss colour, a shade darker so it reads as secondary.
        if bossKey and hasAdvanced then
            local open = CCS.GetShowAllBoss(bossKey)
            hdr._arrow:SetTexture(ARROW_PATH .. (open and "down_arrow" or "right_arrow"))
            local base = entry._color
                         or (entry.section and entry.section:match("(|c%x%x%x%x%x%x%x%x)"))
            local r, g, b = 0.67, 0.67, 0.67
            if base then
                local hr, hg, hb = base:match("^|c%x%x(%x%x)(%x%x)(%x%x)$")
                if hr then
                    local factor = 0.65
                    r = tonumber(hr, 16) / 255 * factor
                    g = tonumber(hg, 16) / 255 * factor
                    b = tonumber(hb, 16) / 255 * factor
                end
            end
            hdr._arrow:SetVertexColor(r, g, b, 1)
            hdr._arrow:Show()
        else
            hdr._arrow:Hide()
        end

        -- Left-click: toggle "Show non-default" (only when there's anything to reveal).
        -- Right-click: open the Encounter Journal to this boss.
        hdr:EnableMouse(true)
        hdr:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" then
                if bossKey and hasAdvanced then
                    withCombatGuard(function()
                        CCS.SetShowAllBoss(bossKey, not CCS.GetShowAllBoss(bossKey))
                        if CCS._fullRebuild then CCS._fullRebuild() end
                    end)
                end
            elseif button == "RightButton" then
                local iid = entry.journalInstanceID
                local eid = entry.journalEncounterID
                if iid and eid then
                    if InCombatLockdown() then
                        print("|cffffff00CCS:|r Can't open the journal in combat.")
                        return
                    end
                    local loadFn = (C_AddOns and C_AddOns.LoadAddOn) or UIParentLoadAddOn or LoadAddOn
                    if loadFn then loadFn("Blizzard_EncounterJournal") end
                    if EncounterJournal_OpenJournal then
                        EncounterJournal_OpenJournal(nil, iid, eid)
                    else
                        print("|cffffff00CCS:|r Encounter Journal isn't available.")
                    end
                else
                    print("|cffffff00CCS:|r No dungeon journal reference set for "
                        .. (entry.boss or entry.section or "this boss")
                        .. ". Add journalInstanceID and journalEncounterID to the entry.")
                end
            end
        end)
        if bossKey and hasAdvanced then
            addTooltip(hdr, entry.boss or entry.section or "",
                "Left-click to " .. (showAll and "hide" or "show") ..
                " non-default abilities.\nRight-click to open the dungeon journal.", true)
        else
            addTooltip(hdr, entry.boss or entry.section or "",
                "Right-click to open the dungeon journal.", true)
        end

        hdr:Show(); y = y - SECTION_HEADER_H

        for _, ability in ipairs(entry.abilities) do
            local visible
            if filtering then
                -- Boss name matched: show the whole section. Otherwise show
                -- only abilities whose name matches, ignoring the advanced gate.
                visible = bossHit or abilityMatches(ability)
            else
                visible = not ability.advanced
                          or showAll
                          or CCS.IsAbilityOptedIn(ability.key)
            end
            if not visible then
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

            -- Sub-rows per extra aura trigger. Same spell, its own storage key,
            -- so each gets an independent warning sound. Shown when the spell is
            -- expanded, and also whenever a trigger already has a sound set, so
            -- an imported profile's settings are never active but hidden.
            if CCS.SupportsAuraTriggers() then
                local expanded = CCS.GetExtraAuraTriggers()
                                 and CCS.IsSpellExpanded(ability.key)
                for _, event in ipairs({ "stack", "remove" }) do
                    local vKey = ability.key .. CCS.EVENT_SUFFIX[event]
                    if expanded or CCS.HasTriggerConfig(vKey) then
                    rowIdx = rowIdx + 1
                    local vr = acquireRow(scrollChild, rowIdx)
                    local vAbility = CCS.MakeEventAbility(ability, event)
                    -- The parent row already names the spell, so a sub-row only
                    -- needs to say which trigger it is.
                    vAbility.label = "   |cff808080-|r |cff80d0ff"
                                     .. CCS.EVENT_LABEL[event] .. "|r"
                    vr.leftCell:SetSize(leftW, ROW_HEIGHT)
                    vr.leftCell:ClearAllPoints()
                    vr.leftCell:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0,     y)
                    vr.rightCell:SetSize(rightW, ROW_HEIGHT)
                    vr.rightCell:ClearAllPoints()
                    vr.rightCell:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", leftW, y)
                    vr.rebind(vAbility, isMplus)
                    -- Right cell stays shown so Set Default is available; its
                    -- countdown controls suppress themselves for variant rows.
                    vr.leftCell:Show(); vr.rightCell:Show()
                    y = y - ROW_HEIGHT - 1
                    end
                end
            end
            end
        end

        y = y - 8

        end  -- if entry.abilities
    end

    -- Hide leftover pool entries.
    for i = rowIdx + 1, #_pool.rows   do _pool.rows[i].leftCell:Hide(); _pool.rows[i].rightCell:Hide() end
    for i = hdrIdx + 1, #_pool.headers do _pool.headers[i]:Hide() end
    for i = raidIdx + 1, #_pool.raidBgs do _pool.raidBgs[i]:Hide() end
    for i = sepIdx  + 1, #_pool.seps   do _pool.seps[i]:Hide() end

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

    local title = makeFontString(topBlock, "ARTWORK", "GameFontNormalLarge")
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
        CCS.ToggleProfiles()
    end)

    local helpBtn = CreateFrame("Button", nil, topBlock, "UIPanelButtonTemplate")
    helpBtn:SetSize(50, 20)
    helpBtn:SetPoint("RIGHT", profilesBtn, "LEFT", -6, 0)
    helpBtn:SetText("Help")
    stripButtonBorder(helpBtn)
    addTooltip(helpBtn, "Help", "How this addon works.")

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

    local confirmText = makeFontString(confirmDialog, "OVERLAY", "GameFontNormalSmall")
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

    -- Help popup
    local helpDialog = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    helpDialog:SetSize(440, 440)
    helpDialog:SetPoint("CENTER", panel, "CENTER", 0, 0)
    helpDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    helpDialog:SetFrameLevel(400)
    helpDialog:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left=4, right=4, top=4, bottom=4 },
    })
    helpDialog:SetBackdropColor(0.06, 0.06, 0.06, 1)
    helpDialog:SetBackdropBorderColor(0.8, 0.6, 0.1, 1)
    helpDialog:EnableMouse(true)
    helpDialog:Hide()

    local helpTitle = makeFontString(helpDialog, "OVERLAY", "GameFontNormalLarge")
    helpTitle:SetPoint("TOP", helpDialog, "TOP", 0, -12)
    helpTitle:SetText("|cffFFD100Custom Countdown Sounds Help|r")

    local helpClose = CreateFrame("Button", nil, helpDialog, "UIPanelButtonTemplate")
    helpClose:SetSize(70, 22)
    helpClose:SetPoint("BOTTOM", helpDialog, "BOTTOM", 0, 12)
    helpClose:SetText("Close")
    stripButtonBorder(helpClose)
    helpClose:SetScript("OnClick", function() helpDialog:Hide() end)

    local helpScroll = CreateFrame("ScrollFrame", nil, helpDialog, "UIPanelScrollFrameTemplate")
    helpScroll:SetPoint("TOPLEFT", helpDialog, "TOPLEFT", 16, -40)
    helpScroll:SetPoint("BOTTOMRIGHT", helpDialog, "BOTTOMRIGHT", -32, 42)
    local helpContent = CreateFrame("Frame", nil, helpScroll)
    helpContent:SetSize(380, 10)
    helpScroll:SetScrollChild(helpContent)

    local helpText = makeFontString(helpContent, "ARTWORK", "GameFontHighlightSmall")
    helpText:SetPoint("TOPLEFT", helpContent, "TOPLEFT", 0, 0)
    helpText:SetWidth(376)
    helpText:SetJustifyH("LEFT")
    helpText:SetJustifyV("TOP")
    helpText:SetSpacing(3)
    helpText:SetText(table.concat({
        "|cffFFD100What this addon does|r",
        "It plays a sound when a boss ability lands on you, and can also play a spoken countdown as the effect is about to expire. This helps you react without staring at your debuffs.",
        " ",
        "|cffFFD100The two columns|r",
        "Each ability has two independent halves.",
        "|cff80d0ffWarning|r (left): a sound the moment the aura is applied to you.",
        "|cff80d0ffCountdown|r (right): a spoken timer as it runs out.",
        "Tick either, both, or neither. They don't depend on each other. Click the |cffccccccTest|r button to preview what sounds will play in a Mythic encounter.",
        " ",
        "|cffFFD100Raid vs Mythic+|r",
        "Use the |cffccccccModule|r buttons to switch between raid and Mythic+ data. In raid, abilities have separate countdown boxes for Heroic (HC) and Mythic (M) difficulty, since durations sometimes differ. Mythic+ only uses one tickbox.",
        " ",
        "|cffFFD100The ability list|r",
        "Most bosses already come with sensible defaults. You just need to enable them by ticking the boxes, and you can pick a different sound in the dropdown next to each one.",
        "Extra abilities that don't have a default are hidden to keep the list clean. |cff80d0ffClick a boss name|r to show or hide them. A small |cffffffff v |r means it can be expanded, |cffffffff ^ |r means it's open.",
        " ",
        "|cffFFD100Profiles|r",
        "Use |cffccccccProfiles|r to keep different setups (e.g. one per character or per role). You can also export a profile as a string to share it with someone else. |cffccccccDefaults|r resets your current profile back to the built-in settings.",
        " ",
        "|cffFFD100Advanced|r",
        "|cff80d0ffManual Timers|r lets you override a countdown's duration if a timer is ever wrong, and add countdowns to abilities that don't have one.",
        "|cff80d0ffExtra aura triggers|r lets an ability also play a sound when it gains a stack or drops off, not just when it lands. Tick it, then click a spell name to open its triggers.",
        " ",
        "|cffFFD100Tips|r",
        "|cff80d0ffRight-click a boss name|r to open the Dungeon Journal to that boss.",
        "|cff80d0ffAll Warnings / All Countdowns|r flip every visible ability at once, so you can silence or enable a whole section quickly.",
        "|cff80d0ffSearch|r filters the list by ability name, including ones hidden under a collapsed boss.",
        "|cff80d0ffSound output|r sets which audio channel these sounds use, so you can control their volume from WoW's own audio panel.",
        " ",
        "|cffFFD100Questions or feedback?|r",
        "Leave a comment on CurseForge, or contact the following.",
        "|cff80d0ffDiscord:|r knofle   |cff80d0ffBattle.net:|r knofle#2235",
    }, "\n"))

    helpContent:SetHeight(helpText:GetStringHeight() + 10)

    helpBtn:SetScript("OnClick", function()
        if helpDialog:IsShown() then
            helpDialog:Hide()
        else
            helpContent:SetHeight(helpText:GetStringHeight() + 10)
            helpDialog:Show()
        end
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
    local moduleLbl = makeFontString(moduleBox, "ARTWORK", "GameFontNormalSmall")
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
    -- auto-size module buttons and box; re-runs when the font changes
    local function sizeModuleBox()
        local lblW   = moduleLbl:GetStringWidth()
        local raidW  = raidBtn:GetFontString()  and raidBtn:GetFontString():GetStringWidth()  + 16 or 50
        local mplusW = mplusBtn:GetFontString() and mplusBtn:GetFontString():GetStringWidth() + 16 or 60
        raidBtn:SetWidth(raidW); mplusBtn:SetWidth(mplusW)
        -- box is anchored BOTTOMRIGHT, so growing the width extends it leftward
        moduleBox:SetSize(14 + lblW + 8 + raidW + 2 + mplusW + 4, 24)
    end
    moduleBox:SetScript("OnShow", function()
        sizeModuleBox()
        moduleBox:SetScript("OnShow", nil)
    end)
    CCS._sizeModuleBox = sizeModuleBox
    local function clearSearch()
        searchQuery = ""
        if CCS._searchBox then CCS._searchBox:SetText("") end
    end
    raidBtn:SetScript("OnClick",  function() clearSearch(); CCS.SetModule("raid")  end)
    mplusBtn:SetScript("OnClick", function() clearSearch(); CCS.SetModule("mplus") end)

    -- Output channel dropdown (below the title) + scale slider (next to title).
    local settingsBox = CreateFrame("Frame", nil, topBlock)
    settingsBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    settingsBox:SetSize(410, 24)

    local chanLbl = makeFontString(settingsBox, "ARTWORK", "GameFontNormalSmall")
    chanLbl:SetText("|cffccccccSound output|r")
    chanLbl:SetPoint("LEFT", settingsBox, "LEFT", 0, 0)

    local CHANNEL_ITEMS = {
        { label = "Master",   value = "Master"   },
        { label = "Music",    value = "Music"    },
        { label = "Effects",  value = "SFX"      },
        { label = "Ambience", value = "Ambience" },
        { label = "Dialog",   value = "Dialog"   },
    }
    local chanDD = CCS_CreateDropdown(settingsBox, 90, 20, 11)
    chanDD._noGreen = true
    chanDD:SetPoint("LEFT", chanLbl, "RIGHT", 6, 0)
    chanDD:SetItems(CHANNEL_ITEMS)
    chanDD:SetValue(CCS.GetChannel())
    chanDD:SetOnSelect(function(v)
        withCombatGuard(function()
            CCS.SetChannel(v)
            CCS.RefreshSounds()  -- re-register through the new channel
        end)
    end)
    addTooltip(chanDD, "Sound output channel",
        "Which volume slider these sounds follow. 'Effects' uses your Sound Effects volume; the rest match their name.")

    local scaleSlider, scaleValue
    if isStandalone then
        local scaleLbl = makeFontString(topBlock, "ARTWORK", "GameFontNormalSmall")
        scaleLbl:SetText("|cffccccccScale|r")
        scaleLbl:SetPoint("LEFT", title, "RIGHT", 20, 0)

        local minV, maxV, step = 0.75, 2.0, 0.05
        local TW, INSET = 46, 2

        local s = CreateFrame("Frame", nil, topBlock, "BackdropTemplate")
        s:SetSize(120, 18)
        s:SetPoint("TOPLEFT", scaleLbl, "TOPRIGHT", 8, 2)
        s:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8X8", edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1 })
        s:SetBackdropColor(0.05, 0.05, 0.05, 1)
        s:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        s:EnableMouse(true)

        local thumb = CreateFrame("Frame", nil, s, "BackdropTemplate")
        thumb:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8X8", edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1 })
        thumb:SetBackdropColor(0.22, 0.22, 0.22, 1)
        thumb:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)

        local text = makeFontString(thumb, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("CENTER", thumb, "CENTER", 0, 0)

        s._value = CCS.GetScale()
        local function clampStep(v)
            v = minV + math.floor((v - minV) / step + 0.5) * step
            return math.max(minV, math.min(maxV, v))
        end
        local function refresh()
            local w = s:GetWidth() or 0
            local travel = math.max(0, w - 2 * INSET - TW)
            local frac = (s._value - minV) / (maxV - minV)
            thumb:SetSize(TW, (s:GetHeight() or 18) - 2 * INSET)
            thumb:ClearAllPoints()
            thumb:SetPoint("TOPLEFT", s, "TOPLEFT", INSET + travel * frac, -INSET)
            text:SetText(("%d%%"):format(math.floor(s._value * 100 + 0.5)))
        end

        local function valueFromCursor()
            local left = s:GetLeft(); if not left then return s._value end
            local x = GetCursorPosition() / s:GetEffectiveScale()
            local w = s:GetWidth(); if not w or w <= 0 then w = 1 end
            local travel = math.max(1, w - 2 * INSET - TW)
            local frac = (x - left - INSET - TW / 2) / travel
            return clampStep(minV + math.max(0, math.min(1, frac)) * (maxV - minV))
        end

        local dragging = false
        -- Preview the thumb + % while dragging, but don't apply the scale
        -- (SetScale) until the mouse is released.
        local function preview(v)
            s._value = v
            refresh()
        end
        local function commit(v)
            s._value = v
            CCS.SetScale(v)
            refresh()
            if CCS._applyWindowScale then CCS._applyWindowScale(v) end
            if CCS._applyProfilesScale then CCS._applyProfilesScale(v) end
        end
        s:SetScript("OnMouseDown", function(self, btn)
            if btn ~= "LeftButton" then return end
            dragging = true
            preview(valueFromCursor())
            self:SetScript("OnUpdate", function() preview(valueFromCursor()) end)
        end)
        s:SetScript("OnMouseUp", function(self)
            if not dragging then return end
            dragging = false
            self:SetScript("OnUpdate", nil)
            commit(valueFromCursor())
        end)
        thumb:EnableMouse(false)
        s:SetScript("OnSizeChanged", refresh)

        scaleSlider = s
        scaleValue = text
        s.refresh = refresh
        refresh()
        addTooltip(s, "Window scale", "Resize the whole window.")
    end

    CCS._syncSettingsBox = function()
        chanDD:SetValue(CCS.GetChannel())
        if scaleSlider then
            scaleSlider._value = CCS.GetScale()
            if scaleSlider.refresh then scaleSlider:refresh() end
            scaleValue:SetText(("%d%%"):format(math.floor(CCS.GetScale() * 100 + 0.5)))
        end
    end

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

    -- Global "Manual Timers (Advanced)" checkbox
    local durationOverrideCB = CreateFrame("CheckButton", nil, headerBar, "UICheckButtonTemplate")
    durationOverrideCB:SetSize(16, 16)
    stripCheckBorder(durationOverrideCB)
    local durationOverrideLbl = makeFontString(headerBar, "ARTWORK", "GameFontNormalSmall")
    durationOverrideLbl:SetText("|cffaaaaaa Manual Timers (Advanced)|r")
    durationOverrideLbl:SetPoint("LEFT", durationOverrideCB, "RIGHT", 2, 0)
    addTooltip(durationOverrideCB, "Manual Timers (Advanced)",
        "Check this if a debuff duration is wrong, you need to manually adjust it, or if you need them customized for some other reason.\nContact me if you want a default value changed.")

    -- Global "Extra aura triggers" checkbox, sits left of Manual Timers.
    local extraTriggersCB = CreateFrame("CheckButton", nil, headerBar, "UICheckButtonTemplate")
    extraTriggersCB:SetSize(16, 16)
    stripCheckBorder(extraTriggersCB)
    local extraTriggersLbl = makeFontString(headerBar, "ARTWORK", "GameFontNormalSmall")
    extraTriggersLbl:SetText("|cffaaaaaa Extra aura triggers|r")
    extraTriggersLbl:SetPoint("LEFT", extraTriggersCB, "RIGHT", 2, 0)
    addTooltip(extraTriggersCB, "Extra aura triggers",
        "Lets each spell also play a sound when it gains a stack or drops off, not just when it lands.\nClick a spell name to open its triggers.")
    extraTriggersCB:SetScript("OnClick", function(self)
        withCombatGuard(function()
            local on = self:GetChecked()
            CCS.SetExtraAuraTriggers(on)
            if not on then CCS.ClearSpellExpansions() end
            fullRebuild()
        end)
    end)

    -- Search box (filters the ability list live). Lives in the header bar on
    -- the same baseline as Manual Timers, left side, ~30% width.
    local searchBox = CreateFrame("EditBox", nil, headerBar, "SearchBoxTemplate")
    searchBox:SetHeight(18)
    if searchBox.Instructions then searchBox.Instructions:SetText("Search abilities...") end
    CCS._searchBox = searchBox
    searchBox:HookScript("OnTextChanged", function(self)
        local q = (self:GetText() or ""):lower()
        if q ~= searchQuery then
            searchQuery = q
            if CCS._fullRebuild then CCS._fullRebuild() end
        end
    end)

    -- Bulk action boxes inside headerBar
    local warnBox = makeGroupBox(headerBar, headerBar, "BOTTOMLEFT", 0, 0, "BOTTOMLEFT")
    warnBox:SetBackdropBorderColor(0, 0, 0, 0)
    warnBox:SetSize(140, BULK_BOX_H)
    local warnBoxLbl = makeFontString(warnBox, "ARTWORK", "GameFontNormalSmall")
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
    local function sizeWarnBox()
        local lblW = warnBoxLbl:GetStringWidth()
        local enW  = enableWarnBtn:GetFontString() and enableWarnBtn:GetFontString():GetStringWidth() + 16 or 68
        local disW = disableWarnBtn:GetFontString() and disableWarnBtn:GetFontString():GetStringWidth() + 16 or 68
        enableWarnBtn:SetWidth(enW); disableWarnBtn:SetWidth(disW)
        local w = math.max(enW + disW + 8, lblW + 16)
        warnBox:SetSize(w, BULK_BOX_H)
    end
    warnBox:SetScript("OnShow", function()
        sizeWarnBox()
        warnBox:SetScript("OnShow", nil)
    end)
    CCS._sizeWarnBox = sizeWarnBox

    local cdBox = makeGroupBox(headerBar, headerBar, "BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT")
    cdBox:SetBackdropBorderColor(0, 0, 0, 0)
    cdBox:SetSize(140, BULK_BOX_H)
    local cdBoxLbl = makeFontString(cdBox, "ARTWORK", "GameFontNormalSmall")
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
    local function sizeCdBox()
        local lblW = cdBoxLbl:GetStringWidth()
        local enW  = enableCDBtn:GetFontString() and enableCDBtn:GetFontString():GetStringWidth() + 16 or 68
        local disW = disableCDBtn:GetFontString() and disableCDBtn:GetFontString():GetStringWidth() + 16 or 68
        enableCDBtn:SetWidth(enW); disableCDBtn:SetWidth(disW)
        local w = math.max(enW + disW + 8, lblW + 16)
        cdBox:SetSize(w, BULK_BOX_H)
    end
    cdBox:SetScript("OnShow", function()
        sizeCdBox()
        cdBox:SetScript("OnShow", nil)
    end)
    CCS._sizeCdBox = sizeCdBox

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
    local TAB_ICON = 24   -- dungeon icon size in the tab strip (tabs are TAB_H tall)

    local allTab = CreateFrame("Button", nil, tabStrip, "UIPanelButtonTemplate")
    allTab:SetHeight(TAB_H)
    allTab:SetPoint("TOPLEFT",  tabStrip, "TOPLEFT",  4,  -TAB_PAD)
    allTab:SetPoint("TOPRIGHT", tabStrip, "TOPRIGHT", -4, -TAB_PAD)
    allTab:SetText("All")
    stripButtonBorder(allTab)
    local allFs = allTab:GetFontString()
    if allFs then
        -- line up with the dungeon tabs' icon space
        allFs:SetPoint("LEFT",  allTab, "LEFT",  5 + TAB_ICON + 4, 0)
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
        if dungeon.icon then
            local ic = tab:CreateTexture(nil, "ARTWORK")
            ic:SetSize(TAB_ICON, TAB_ICON)
            ic:SetPoint("LEFT", tab, "LEFT", 5, 0)
            ic:SetTexture(dungeon.icon)
            ic:SetTexCoord(0.07, 0.93, 0.07, 0.93)  -- trim border
            tab._icon = ic
        end
        local fs = tab:GetFontString()
        if fs then
            fs:SetPoint("LEFT",  tab, "LEFT",  5 + TAB_ICON + 4, 0)
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
        local w = maxW + 5 + TAB_ICON + 4 + 6 + 4 + 4
        self:SetWidth(w)
        self:SetScript("OnShow", nil)
    end)

    local function refreshTabs()
        local active = CCS.GetActiveDungeon()
        for key, tab in pairs(tabButtons) do
            local isActive = key == active
            setButtonBg(tab, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08)
            tab:SetAlpha(isActive and 1.0 or 0.75)
            if tab._icon then
                    if tab._icon.SetDesaturation then
                    tab._icon:SetDesaturation(isActive and 0 or 0.4)
                else
                    tab._icon:SetDesaturated(not isActive)
                end
                tab._icon:SetAlpha(isActive and 1.0 or 0.85)
            end
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
        -- line up with the raid tabs' icon space
        raidAllFs:SetPoint("LEFT",  raidAllTab, "LEFT",  5 + TAB_ICON + 4, 0)
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
        local raidIcon = RAID_ICONS[raidName]
        if raidIcon then
            local ic = tab:CreateTexture(nil, "ARTWORK")
            ic:SetSize(TAB_ICON, TAB_ICON)
            ic:SetPoint("LEFT", tab, "LEFT", 5, 0)
            ic:SetTexture(raidIcon)
            ic:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            tab._icon = ic
        end
        local fs = tab:GetFontString()
        if fs then
            fs:SetPoint("LEFT",  tab, "LEFT",  5 + TAB_ICON + 4, 0)
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
        self:SetWidth(maxW + 5 + TAB_ICON + 4 + 6 + 4 + 4)
        self:SetScript("OnShow", nil)
    end)

    local function refreshRaidTabs()
        local active = CCS.GetActiveRaid()
        for name, tab in pairs(raidTabButtons) do
            local isActive = name == active
            setButtonBg(tab, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08, isActive and 0.28 or 0.08)
            tab:SetAlpha(isActive and 1.0 or 0.75)
            if tab._icon then
                if tab._icon.SetDesaturation then
                    tab._icon:SetDesaturation(isActive and 0 or 0.4)
                else
                    tab._icon:SetDesaturated(not isActive)
                end
                tab._icon:SetAlpha(isActive and 1.0 or 0.85)
            end
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
        scroll.ScrollBar:SetPoint("TOPRIGHT",    scroll, "TOPRIGHT",    0, -2)
        scroll.ScrollBar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0,  2)

        -- Modernize the default UIPanel scrollbar: drop the arrow buttons and
        -- beveled art, leaving a thin flat track with a flat thumb.
        local sb = scroll.ScrollBar
        sb:SetWidth(8)

        local up   = sb.ScrollUpButton   or _G[(sb:GetName() or "") .. "ScrollUpButton"]
        local down = sb.ScrollDownButton or _G[(sb:GetName() or "") .. "ScrollDownButton"]
        if up   then up:Hide();   up:SetHeight(0.01)   end
        if down then down:Hide(); down:SetHeight(0.01) end

        -- Hide the stock track/thumb textures.
        if sb.SetThumbTexture then sb:SetThumbTexture("Interface\\Buttons\\WHITE8X8") end
        local thumb = sb.ThumbTexture or (sb.GetThumbTexture and sb:GetThumbTexture())
        if thumb then
            thumb:SetColorTexture(0.5, 0.5, 0.5, 0.7)
            thumb:SetWidth(8)
        end

        -- Flat track behind the thumb.
        local track = sb:CreateTexture(nil, "BACKGROUND")
        track:SetColorTexture(1, 1, 1, 0.04)
        track:SetPoint("TOPLEFT",     sb, "TOPLEFT",     0, 0)
        track:SetPoint("BOTTOMRIGHT", sb, "BOTTOMRIGHT", 0, 0)
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

    local function updateHeaders(totalWidth)
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

        extraTriggersLbl:ClearAllPoints()
        extraTriggersLbl:SetPoint("RIGHT", durationOverrideCB, "LEFT", -14, 0)
        extraTriggersCB:ClearAllPoints()
        extraTriggersCB:SetPoint("RIGHT", extraTriggersLbl, "LEFT", 0, 0)
        extraTriggersCB:SetChecked(CCS.GetExtraAuraTriggers())
        -- Only offer it on clients whose API can play on stack/removal.
        local canTrigger = not CCS.SupportsAuraTriggers or CCS.SupportsAuraTriggers()
        extraTriggersCB:SetShown(canTrigger)
        extraTriggersLbl:SetShown(canTrigger)

        if CCS._searchBox then
            CCS._searchBox:ClearAllPoints()
            CCS._searchBox:SetPoint("BOTTOMLEFT", headerBar, "BOTTOMLEFT", 20, 6)
            CCS._searchBox:SetWidth(math.max(120, math.floor((totalWidth or 700) * 0.30)))
        end
    end

    local _leftW = nil  -- set on first build, stable thereafter

    fullRebuild = function()
        if not built or not _leftW then return end
        local w = scroll:GetWidth()
        moduleBox:SetShown(CCS.MPLUS_ENABLED)
        rebindAll(scrollChild, w, _leftW, CCS.GetModule() == "mplus")
        updateHeaders(w)
        syncTabVisibility()
        updateScrollBar()
        if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
    end

    -- Profile change: full rebuild so per-profile show-non-default and
    -- opt-in visibility both take effect immediately.
    local _prevOnProfileChange = CCS._onProfileChange
    CCS._onProfileChange = function()
        if _prevOnProfileChange then _prevOnProfileChange() end
        if built then
            fullRebuild()
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end
            if CCS._syncSettingsBox then CCS._syncSettingsBox() end
            if CCS._applyWindowScale then CCS._applyWindowScale(CCS.GetScale()) end
            if CCS._applyProfilesScale then CCS._applyProfilesScale(CCS.GetScale()) end
            if CCS._applyFont then CCS._applyFont() end
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
            fullRebuild()
            CCS.RefreshSounds()
            refreshBulkUnderlines()
        end)
    end)
    disableWarnBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            CCS.SetAllWarn(false)
            fullRebuild()
            CCS.RefreshSounds()
            refreshBulkUnderlines()
        end)
    end)
    enableCDBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            CCS.SetAllCD(true)
            fullRebuild()
            CCS.RefreshSounds()
            refreshBulkUnderlines()
        end)
    end)
    disableCDBtn:SetScript("OnClick", function()
        withCombatGuard(function()
            CCS.SetAllCD(false)
            fullRebuild()
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

        -- Clear any stale search filter.
        searchQuery = ""
        if searchBox then searchBox:SetText("") end

        if not built then
            built = true
            local w = scroll:GetWidth()
            scrollChild:SetWidth(w)
            _leftW = math.floor(w * LEFT_PANEL_FRACTION)

            -- rebindAll creates only the rows it actually shows.
            rebindAll(scrollChild, w, _leftW, CCS.GetModule() == "mplus")
            updateHeaders(w)
            updateScrollBar()
            if CCS._refreshBulkUnderlines then CCS._refreshBulkUnderlines() end

            -- Cache the chosen font path first, then start prewarm, so rows
            -- created in the background pick it up. applyFont fonts what exists.
            StartPrewarm(scrollChild)
            applyFont()  -- match any saved font choice on first open
            scheduleFontReapply()
        else
            -- Already built; re-apply module then resync.
            if CCS.ApplyModule then CCS.ApplyModule() end
            fullRebuild()
        end
        if CCS._syncSettingsBox then CCS._syncSettingsBox() end
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

    local title = makeFontString(panel, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText(CATEGORY_NAME)

    local desc = makeFontString(panel, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetWidth(500); desc:SetJustifyH("LEFT"); desc:SetWordWrap(true)
    desc:SetText(
        "Custom Countdown Sounds lets you configure sounds that play automatically when private auras " ..
        "land on you during Heroic and Mythic raid encounters. Each ability can have an independent " ..
        "warning sound (plays on aura apply) and a countdown sound (plays at a set interval before " ..
        "the ability fires). Sounds can be customised per-ability and saved into profiles."
    )

    local slashTitle = makeFontString(panel, "ARTWORK", "GameFontNormal")
    slashTitle:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    slashTitle:SetText("Slash Commands")

    local prev = slashTitle
    for _, entry in ipairs({
        { cmd="/ccs",          desc="Open the options window."         },
        { cmd="/ccs reset",    desc="Reset window position and size."  },
        { cmd="/ccs sounds",   desc="Debug registered sounds."         },
        { cmd="/ccs minimap",  desc="Toggle the minimap button."       },
    }) do
        local line = makeFontString(panel, "ARTWORK", "GameFontHighlight")
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

    local closeBtn = CreateFrame("Button", nil, win)
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", win, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() win:Hide() end)
    -- Plain X, no background circle.
    local cbX = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    cbX:SetPoint("CENTER")
    cbX:SetText("|cffb0b0b0\195\151|r")  -- multiplication sign, reads as a clean X
    closeBtn:SetScript("OnEnter", function() cbX:SetText("|cffffffff\195\151|r") end)
    closeBtn:SetScript("OnLeave", function() cbX:SetText("|cffb0b0b0\195\151|r") end)

    -- Resize handle
    local handle = CreateFrame("Frame", nil, win)
    handle:SetHeight(8)
    handle:SetWidth(100)
    handle:SetPoint("BOTTOM", win, "BOTTOM", 0, 2)
    handle:EnableMouse(true)

    local handleTex = handle:CreateTexture(nil, "BACKGROUND")
    handleTex:SetAllPoints()
    handleTex:SetColorTexture(0.5, 0.5, 0.5, 0.3)

    local grip = makeFontString(handle, "OVERLAY", "GameFontNormalSmall")
    grip:SetPoint("CENTER")
    grip:SetText("|cff666666· · · · ·|r")

    handle:SetScript("OnEnter", function() handleTex:SetColorTexture(0.8, 0.8, 0.8, 0.4) end)
    handle:SetScript("OnLeave", function() handleTex:SetColorTexture(0.5, 0.5, 0.5, 0.3) end)

    handle:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "LeftButton" then return end
        -- Re-anchor by TOPLEFT so height changes grow downward, keeping the
        -- top edge fixed. Work in the window's own scale throughout.
        local eff  = win:GetEffectiveScale()
        local left = win:GetLeft()
        local top  = win:GetTop()
        win:ClearAllPoints()
        win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
        handle:SetScript("OnUpdate", function()
            -- Cursor pixels -> window scale (not UIParent scale).
            local curY = select(2, GetCursorPosition()) / eff
            local newH = math.max(MIN_H, math.min(MAX_H, win:GetTop() - curY))
            win:SetHeight(newH)
        end)
    end)
    handle:SetScript("OnMouseUp", function()
        handle:SetScript("OnUpdate", nil)
    end)

    -- Apply scale while keeping the window's top-left screen position fixed.
    local function applyScaleKeepTopLeft(v)
        local left, top = win:GetLeft(), win:GetTop()
        if not (left and top) then win:SetScale(v); return end
        -- Absolute screen position of the top-left corner (in pixels).
        local sx = left * win:GetEffectiveScale()
        local sy = top  * win:GetEffectiveScale()
        win:SetScale(v)
        -- Re-anchor so that same screen pixel maps to the new top-left.
        local newEff = win:GetEffectiveScale()
        win:ClearAllPoints()
        win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", sx / newEff, sy / newEff)
    end

    win:SetScale(CCS.GetScale and CCS.GetScale() or 1.0)
    CCS._applyWindowScale = applyScaleKeepTopLeft

    return BuildCCSOptions(win, true)
end

local standaloneWindow

-- built at PLAYER_LOGIN to keep it off the loading screen.
-- fallback build here in case /ccs somehow fires first.
local function ensureStandaloneWindow()
    if not standaloneWindow then
        standaloneWindow = CreateStandaloneWindow()
    end
    return standaloneWindow
end

toggleStandalone = function()
    if InCombatLockdown() then
        print("|cffffff00CCS:|r Cannot open settings during combat.")
        return
    end
    local win = ensureStandaloneWindow()
    if not win then return end
    win:SetShown(not win:IsShown())
end

SLASH_CCS1 = "/ccs"
SlashCmdList["CCS"] = function(msg)
    local arg = msg and msg:match("^%s*(%S+)") or ""
    arg = arg:lower()

    if arg == "ejid" then
        if not EncounterJournal or not EncounterJournal:IsShown() then
            print("|cffffff00CCS:|r Open the Encounter Journal on a boss first, then run this.")
            return
        end
        local iid = EncounterJournal.instanceID
        local eid = EncounterJournal.encounterID
        print("|cffffff00CCS:|r journalInstanceID = " .. tostring(iid)
            .. ", journalEncounterID = " .. tostring(eid))
        return
    end

    if arg == "plexus" then
        -- Follower-dungeon test mode. Session-only; resets every /reload.
        CCS._followerTestMode = not CCS._followerTestMode
        if CCS._followerTestMode then
            print("|cffffff00CCS:|r Follower dungeon test mode |cff00ff00enabled|r. Any party instance is treated as Mythic.")
        else
            print("|cffffff00CCS:|r Follower dungeon test mode |cffff5555disabled|r.")
        end
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
        local hasGeneral = (C_UnitAuras.AddAuraSound or C_UnitAuras.AddAuraAppliedSound) ~= nil
        local failed = 0
        local sources = { { label = "Raid", data = CCS_Spells_Raid } }
        for _, dungeon in ipairs(CCS.MplusDungeons) do
            local data = dungeon.data()
            if data then sources[#sources + 1] = { label = dungeon.label, data = data } end
        end
        for _, src in ipairs(sources) do
            for _, entry in ipairs(src.data) do
                if entry.abilities then
                    for _, ability in ipairs(entry.abilities) do
                        for _, line in ipairs(getPrivateIDLines(ability.privateID)) do
                            local id = line.id
                            if id and id ~= 0 then
                                if hasGeneral then
                                    if C_Spell and C_Spell.DoesSpellExist and not C_Spell.DoesSpellExist(id) then
                                        print("|cffff9900CCS spelltest:|r |cffff5555UNKNOWN spellID:|r " ..
                                            ability.key .. " (spellID " .. id .. ") [" .. src.label .. "]")
                                        failed = failed + 1
                                    end
                                elseif not C_UnitAuras.AuraIsPrivate(id) then
                                    print("|cffff9900CCS privatetest:|r |cffff5555NOT private:|r " ..
                                        ability.key .. " (spellID " .. id .. ") [" .. src.label .. "]")
                                    failed = failed + 1
                                end
                            end
                        end
                    end
                end
            end
        end
        local tag = hasGeneral and "spelltest" or "privatetest"
        if failed == 0 then
            local msg2 = hasGeneral and "All spell IDs exist." or "All spell IDs are private auras."
            print("|cffffff00CCS " .. tag .. ":|r |cff00ff00" .. msg2 .. "|r")
        else
            local msg2 = hasGeneral and " unknown spell ID(s) found." or " non-private spell ID(s) found."
            print("|cffffff00CCS " .. tag .. ":|r " .. failed .. msg2)
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
        -- scale back to 100%
        CCS.SetScale(1.0)
        if CCS._applyWindowScale then CCS._applyWindowScale(1.0) end
        if CCS._syncSettingsBox then CCS._syncSettingsBox() end
        if standaloneWindow then
            standaloneWindow:ClearAllPoints()
            standaloneWindow:SetPoint("CENTER")
            standaloneWindow:SetSize(780, 600)
        end
        -- reset the profile window position and scale too
        if CCS.ResetProfilesPosition then CCS.ResetProfilesPosition() end
        print("|cffffff00CCS:|r Window position, size and scale reset.")
        return
    end

    toggleStandalone()
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addonName then return end
        -- register the options category early so it shows in the list
        Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(CreateStubPanel(), CATEGORY_NAME))
        CreateMinimapButton()
        self:UnregisterEvent("ADDON_LOADED")
        return
    end

    if event == "PLAYER_LOGIN" then
        -- build the window now, after the loading screen
        ensureStandaloneWindow()
        self:UnregisterEvent("PLAYER_LOGIN")
        return
    end
end)