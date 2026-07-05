-- =====================================================================
-- CCNS v11 — mod-of-origin label (v6, unchanged) + LIVE click-to-apply
--            Hair & Head search panel, polished + grid highlight.
--
-- v6 bake: writes "Name\nModName" into each modded hair/head DisplayName
-- handle so the in-grid tile shows its source mod.
--
-- v11 panel: an Ext.IMGUI window that reads the LIVE character-creation
-- picker (gui::DCCharacterCreation), scoped to the active Head/Hair tab,
-- searchable by name + filterable by an alphabetical, searchable source-mod
-- list (in its own scroll box so results stay visible). Clicking a result
-- APPLIES it (sets SelectedHair/SelectedHead). A "Highlight" button bakes a
-- star marker onto matching tiles in the grid (reversible). Shown only while
-- in character creation. Dark + gold theming (IMGUI can't match Larian chrome).
-- =====================================================================

local TAG = "[CCNS] "
local function log(m) Ext.Utils.Print(TAG .. tostring(m)) end

local TYPES = { "CharacterCreationAppearanceVisual", "CharacterCreationSharedVisual" }
local SLOTS = { Hair = true, Head = true }
local UNKNOWN = "ls::TranslatedStringRepository::s_HandleUnknown"
local STAR = "\u{2605} "   -- the highlight marker
local BASE = {
    ["Shared"] = true, ["SharedDev"] = true, ["Gustav"] = true, ["GustavDev"] = true,
    ["GustavX"] = true, ["Honour"] = true, ["HonourX"] = true, ["MainUI"] = true,
    ["ModBrowser"] = true, ["PhotoMode"] = true, ["CrossplayUI"] = true,
    ["Game"] = true, ["Engine"] = true,
}

local function now()
    local ok, t = pcall(function() return Ext.Utils.MonotonicTime() end)
    return ok and t or 0
end

local function firstLine(s)
    s = s or ""
    local nl = s:find("\n", 1, true)
    if nl then return s:sub(1, nl - 1) end
    return s
end

-- Strip any leading "#<n> " number prefix and/or STAR highlight prefix (repeated,
-- in any order) so the panel name/sort stays clean once tiles are numbered.
local function stripPrefixes(s)
    s = s or ""
    local prev
    repeat prev = s; s = s:gsub("^" .. STAR, ""):gsub("^#%d+%s+", "") until s == prev
    return s
end

-- ===================== v6 mod-of-origin bake (unchanged) =====================

local function collectType(appType, onlyMod, handleMods)
    local ok, sources = pcall(Ext.StaticData.GetSources, appType)
    if not ok then log("GetSources ERROR (" .. appType .. "): " .. tostring(sources)); return end
    local function consider(modName, rg)
        local okr, res = pcall(Ext.StaticData.Get, tostring(rg), appType)
        if not okr or res == nil then return end
        local slot = res.SlotName
        if not (slot and SLOTS[tostring(slot)]) then return end
        local dn = res.DisplayName
        local h = dn and dn.Handle and dn.Handle.Handle
        if h == nil then return end
        h = tostring(h)
        if h == UNKNOWN or h == "" then return end
        local set = handleMods[h]
        if not set then set = {}; handleMods[h] = set end
        set[modName] = true
    end
    pcall(function()
        for modGuid, resList in pairs(sources) do
            local mod = Ext.Mod.GetMod(modGuid)
            local name = (mod and mod.Info and mod.Info.Name) or tostring(modGuid)
            local want
            if onlyMod then want = (name == onlyMod) else want = (BASE[name] ~= true) end
            if want then
                local okI = pcall(function() for _, rg in ipairs(resList) do consider(name, rg) end end)
                if not okI then pcall(function() for _, rg in pairs(resList) do consider(name, rg) end end) end
            end
        end
    end)
end

local function pickWinner(ownerSet)
    local cands = {}
    for nm in pairs(ownerSet) do cands[#cands + 1] = nm end
    if #cands == 0 then return nil end
    if #cands == 1 then return cands[1] end
    local nonPatch = {}
    for _, nm in ipairs(cands) do
        if not string.find(string.lower(nm), "patch", 1, true) then nonPatch[#nonPatch + 1] = nm end
    end
    local pool = (#nonPatch > 0) and nonPatch or cands
    table.sort(pool)
    return pool[1]
end

local function doBake(onlyMod)
    local t0 = now()
    local handleMods = {}
    for _, appType in ipairs(TYPES) do collectType(appType, onlyMod, handleMods) end
    local handles, baked, already, multi = 0, 0, 0, 0
    for h, owners in pairs(handleMods) do
        handles = handles + 1
        local cnt = 0
        for _ in pairs(owners) do cnt = cnt + 1 end
        if cnt > 1 then multi = multi + 1 end
        local winner = pickWinner(owners)
        if winner then
            local cur = Ext.Loca.GetTranslatedString(h) or ""
            local suffix = "\n" .. winner
            if cur:find(suffix, 1, true) then already = already + 1
            elseif Ext.Loca.UpdateTranslatedString(h, cur .. suffix) then baked = baked + 1 end
        end
    end
    log(string.format("bake(%s) v6: handles=%d baked=%d already=%d multi=%d elapsed=%dms",
        tostring(onlyMod or "ALL non-base"), handles, baked, already, multi, (now() - t0)))
end

function CCNS_BakeAll() doBake(nil) end
function CCNS_BakeMod(n) doBake(n) end

CCNS_HandleMod = {}
local function buildHandleMod()
    local t0 = now()
    local hm = {}
    for _, appType in ipairs(TYPES) do collectType(appType, nil, hm) end
    local map, n = {}, 0
    for h, owners in pairs(hm) do local w = pickWinner(owners); if w then map[h] = w; n = n + 1 end end
    CCNS_HandleMod = map
    log(string.format("handle->mod map: %d handles, %dms", n, (now() - t0)))
end

-- ===================== v11 live access, filter, apply, highlight =====================

CCNS_Entries = {}          -- rows for the active slot: {name,lname,mod,slot,handle,count}
CCNS_Mods = {}             -- {name,count} source mods for the active slot (alphabetical)
CCNS_ActiveSlot = nil      -- "Hair" | "Head" | nil(both)
CCDC = nil

local query = ""
local modSearchQuery = ""
local selectedMods = {}    -- modName -> true ; EMPTY = all
local highlighted = {}     -- handle -> originalText (for reversible star marking)

-- forward declarations (assigned in the UI section)
local setStatus, refreshDisplay, rebuildModChecks, applyModSearch

local function passes(e)
    if query ~= "" and not e.lname:find(query, 1, true) then return false end
    if next(selectedMods) ~= nil and not selectedMods[e.mod] then return false end
    return true
end

local function readColl(dc, prop)
    local c; pcall(function() c = dc[prop] end); return c
end

-- One-shot guarded walk from UI root to the FIRST picker ListBox; returns the
-- nearest inherited DataContext (CC view-model) + which slot's box was found.
local function acquireCC()
    local FW, foundDC, foundSlot, count = nil, nil, nil, 0
    local function F(w, dc)
        if not w or FW or count > 60000 then return end
        count = count + 1
        local d; pcall(function() d = w.DataContext end); if d then dc = d end
        local nm; pcall(function() nm = w.Name end)
        if nm == "SelectableHairListBox" then FW = true; foundDC = dc; foundSlot = "Hair"; return end
        if nm == "SelectableHeadsListBox" then FW = true; foundDC = dc; foundSlot = "Head"; return end
        local c = 0; pcall(function() c = w.VisualChildrenCount end)
        for i = 1, (c or 0) do local ch; pcall(function() ch = w:VisualChild(i) end); F(ch, dc) end
    end
    local root; pcall(function() root = Ext.UI.GetRoot() end)
    if not root then return nil end
    F(root, nil)
    if not foundDC then return nil end
    return { dc = foundDC, slot = foundSlot }
end

-- Bake "#<i> " (the live-collection 1-based position, == the search panel's #idx)
-- onto EVERY hair/head tile, rewriting its DisplayName loca string to
-- "#i <name>" (vanilla) or "#i <name>\n<mod>" (modded). Pure loca, no XAML.
-- v11.13: vanilla tiles are numbered too (previously modded-only) so the unlock-all
-- vanilla hair/head roster is reachable by tile-# / Prev-Next. Reversible: loca edits
-- are per-session, so a vanilla relaunch restores originals. Returns the count baked.
local function numberTilesFromCC(cc)
    if not cc then return 0 end
    local numbered = 0
    local function numberColl(coll)
        if not coll then return end
        local n = 0; pcall(function() n = #coll end)
        for i = 1, (n or 0) do
            local it; pcall(function() it = coll[i] end)
            local h; if it then pcall(function() h = it.Name end) end
            if h then h = tostring(h) end
            if h and h ~= "" and h ~= UNKNOWN then
                local mod = CCNS_HandleMod[h]          -- v11.13: nil = base/vanilla -> STILL number (no mod line)
                local cur = Ext.Loca.GetTranslatedString(h) or ""
                local nm = stripPrefixes(firstLine(cur)); if nm == "" then nm = "(unnamed)" end
                local newStr = "#" .. i .. " " .. nm
                if mod then newStr = newStr .. "\n" .. mod end
                if cur ~= newStr and Ext.Loca.UpdateTranslatedString(h, newStr) then numbered = numbered + 1 end
            end
        end
    end
    if cc.slot == "Hair" or cc.slot == nil then numberColl(readColl(cc.dc, "SelectableHair")) end
    if cc.slot == "Head" or cc.slot == nil then numberColl(readColl(cc.dc, "SelectableHeads")) end
    return numbered
end

-- Console probe: number the live grid on demand and report. If the grid doesn't
-- repaint, switch tab or rescroll -- that tells us the tile re-render behavior.
function CCNS_NumberProbe()
    local cc = acquireCC()
    if not cc then log("number probe: not in CC (open Hair/Head first)"); return 0 end
    local n = numberTilesFromCC(cc)
    log("number probe: baked #idx onto " .. n .. " modded " .. tostring(cc.slot) .. " tiles")
    return n
end

-- Rebuild rows + the per-slot mod list from the LIVE picker.
function CCNS_Refresh()
    local cc = acquireCC()
    if not cc then
        CCNS_Entries = {}; CCNS_Mods = {}; CCNS_ActiveSlot = nil; CCDC = nil
        if setStatus then setStatus("Open character creation (Head/Hair), then Refresh.") end
        if rebuildModChecks then rebuildModChecks() end
        if refreshDisplay then refreshDisplay() end
        return
    end
    CCDC = cc.dc; CCNS_ActiveSlot = cc.slot
    pcall(function() numberTilesFromCC(cc) end)   -- v11.7: number modded tiles (#i) before reading rows
    local uniq = {}
    local function add(slot, coll)
        if not coll then return end
        local n = 0; pcall(function() n = #coll end)
        for i = 1, (n or 0) do
            local it; pcall(function() it = coll[i] end)
            local h; if it then pcall(function() h = it.Name end) end
            if h then h = tostring(h) end
            if h and h ~= "" and h ~= UNKNOWN then
                local nm = stripPrefixes(firstLine(Ext.Loca.GetTranslatedString(h) or "")); if nm == "" then nm = "(unnamed)" end
                local mod = CCNS_HandleMod[h] or "Vanilla"
                local lname = string.lower(nm)
                local key = slot .. "|" .. lname .. "|" .. mod
                local u = uniq[key]
                if u then u.count = u.count + 1
                else uniq[key] = { name = nm, lname = lname, mod = mod, slot = slot, handle = h, count = 1, idx = i } end
            end
        end
    end
    if cc.slot == "Hair" or cc.slot == nil then add("Hair", readColl(cc.dc, "SelectableHair")) end
    if cc.slot == "Head" or cc.slot == nil then add("Head", readColl(cc.dc, "SelectableHeads")) end

    local entries = {}
    for _, u in pairs(uniq) do entries[#entries + 1] = u end
    table.sort(entries, function(a, b) if a.lname ~= b.lname then return a.lname < b.lname end return a.mod < b.mod end)
    CCNS_Entries = entries

    local mc = {}
    for _, e in ipairs(entries) do mc[e.mod] = (mc[e.mod] or 0) + 1 end
    local mods = {}
    for nm, c in pairs(mc) do mods[#mods + 1] = { name = nm, count = c } end
    table.sort(mods, function(a, b) return a.name:lower() < b.name:lower() end)  -- ALPHABETICAL
    CCNS_Mods = mods
    selectedMods = {}

    log("Refresh: slot=" .. tostring(cc.slot) .. " styles=" .. #entries .. " mods=" .. #mods)
    if setStatus then setStatus("Loaded " .. #entries .. " " .. (cc.slot or "hair+head") .. " styles.") end
    if rebuildModChecks then rebuildModChecks() end
    if refreshDisplay then refreshDisplay() end
end

local function applyEntry(e)
    if not e then return end
    local cc = acquireCC()
    if not cc then if setStatus then setStatus("Open character creation first.") end return end
    local prop = (e.slot == "Hair") and "SelectableHair" or "SelectableHeads"
    local selProp = (e.slot == "Hair") and "SelectedHair" or "SelectedHead"
    local coll = readColl(cc.dc, prop)
    if not coll then return end
    local n = 0; pcall(function() n = #coll end)
    for i = 1, (n or 0) do
        local it; pcall(function() it = coll[i] end)
        local h; if it then pcall(function() h = it.Name end) end
        if it and h and tostring(h) == e.handle then
            local ok, err = pcall(function() cc.dc[selProp] = it end)
            log("apply " .. e.slot .. " '" .. e.name .. "' ok=" .. tostring(ok) .. (err and (" err=" .. tostring(err)) or ""))
            if setStatus then setStatus((ok and "Applied: " or "Apply FAILED: ") .. e.name) end
            return
        end
    end
    if setStatus then setStatus("Not in current picker: " .. e.name) end
end

-- Step the SELECTION through the current filtered matches (the one live grid-
-- reactive channel): applies each match to the character + frames its tile.
local matchIdx = 0
local function findStep(dir)
    local m = {}
    for _, e in ipairs(CCNS_Entries) do if passes(e) then m[#m + 1] = e end end
    if #m == 0 then if setStatus then setStatus("No matches to step through.") end return end
    matchIdx = matchIdx + dir
    if matchIdx < 1 then matchIdx = #m end
    if matchIdx > #m then matchIdx = 1 end
    local e = m[matchIdx]
    applyEntry(e)
    if setStatus then setStatus("Match " .. matchIdx .. "/" .. #m .. ": " .. e.name .. (e.idx and ("  (tile #" .. e.idx .. ")") or "")) end
end

-- ===================== v11 IMGUI panel (themed) =====================

local MAXROWS = 150
local panelBuilt = false
local win, searchInput, statusText, countText, slotText
local modChild, resultsChild
local resultButtons, rowEntry = {}, {}
local modCheckboxes = {}     -- { {cb=, name=} }

local GOLD   = { 0.78, 0.65, 0.32, 1.0 }
local GOLDHL = { 0.92, 0.80, 0.45, 1.0 }
local DARK   = { 0.30, 0.24, 0.10, 1.0 }
local PANEL  = { 0.07, 0.06, 0.05, 0.96 }

local function theme(w)
    pcall(function()
        w:SetStyle("WindowRounding", 8); w:SetStyle("ChildRounding", 6); w:SetStyle("FrameRounding", 4)
        w:SetStyle("WindowPadding", 12, 10); w:SetStyle("WindowBorderSize", 1)
        w:SetColor("WindowBg", PANEL); w:SetColor("ChildBg", { 0.10, 0.09, 0.07, 0.96 })
        w:SetColor("Border", GOLD); w:SetColor("Text", { 0.92, 0.88, 0.78, 1.0 })
        w:SetColor("TitleBg", { 0.12, 0.10, 0.05, 1.0 }); w:SetColor("TitleBgActive", DARK)
        w:SetColor("Button", DARK); w:SetColor("ButtonHovered", GOLDHL); w:SetColor("ButtonActive", GOLD)
        w:SetColor("Header", DARK); w:SetColor("HeaderHovered", GOLDHL); w:SetColor("HeaderActive", GOLD)
        w:SetColor("FrameBg", { 0.16, 0.14, 0.10, 1.0 }); w:SetColor("CheckMark", GOLDHL)
        w:SetColor("Separator", GOLD); w:SetColor("ScrollbarGrab", DARK)
    end)
end

setStatus = function(s) if statusText then statusText.Label = s end end

applyModSearch = function()
    for _, m in ipairs(modCheckboxes) do
        local vis = (modSearchQuery == "" or m.name:lower():find(modSearchQuery, 1, true) ~= nil)
        pcall(function() m.cb.Visible = vis end)
    end
end

rebuildModChecks = function()
    for _, m in ipairs(modCheckboxes) do pcall(function() m.cb:Destroy() end) end
    modCheckboxes = {}
    if not modChild then return end
    for _, mod in ipairs(CCNS_Mods) do
        local modName = mod.name
        local cb = modChild:AddCheckbox(modName .. " (" .. mod.count .. ")", false)
        cb.OnChange = function(h) if h.Checked then selectedMods[modName] = true else selectedMods[modName] = nil end refreshDisplay() end
        modCheckboxes[#modCheckboxes + 1] = { cb = cb, name = modName }
    end
    applyModSearch()
end

refreshDisplay = function()
    matchIdx = 0
    if slotText then slotText.Label = "Showing: " .. (CCNS_ActiveSlot or "Hair + Head") end
    local shown, total = 0, 0
    for _, e in ipairs(CCNS_Entries) do
        if passes(e) then
            total = total + 1
            if shown < MAXROWS then
                shown = shown + 1
                local tail = (e.count and e.count > 1) and ("  (x" .. e.count .. ")") or ""
                local pos = e.idx and ("#" .. e.idx .. "  ") or ""
                local b = resultButtons[shown]
                if b then b.Label = pos .. "[" .. e.slot .. "] " .. e.name .. "  -  " .. e.mod .. tail; pcall(function() b.Visible = true end) end
                rowEntry[shown] = e
            end
        end
    end
    for i = shown + 1, MAXROWS do
        local b = resultButtons[i]
        if b then b.Label = ""; pcall(function() b.Visible = false end) end
        rowEntry[i] = nil
    end
    if countText then countText.Label = "Matches: " .. total .. (total > MAXROWS and ("  (showing " .. MAXROWS .. ")") or "") end
end

local function buildPanel()
    if panelBuilt then return end
    if type(Ext.IMGUI) ~= "table" then log("Ext.IMGUI unavailable; panel skipped"); return end
    panelBuilt = true
    local ok, err = pcall(function()
        win = Ext.IMGUI.NewWindow("CCNS - Hair & Head Search")
        win.Closeable = true
        theme(win)
        local vp = Ext.IMGUI.GetViewportSize()
        local h = (vp and vp[2]) and math.floor(vp[2] * 0.42) or 460
        win:SetSize({ 440, h }, "FirstUseEver")
        win:SetPos({ 40, 90 }, "FirstUseEver")
        win.Open = false   -- hidden until opened by the Ctrl+Shift+H hotkey

        win:AddText("Search this character's hair/head. Click a result to apply it.")
        searchInput = win:AddInputText("search", "")
        searchInput.OnChange = function(hh) query = string.lower(hh.Text or ""); refreshDisplay() end
        local rb = win:AddButton("Refresh"); rb.OnClick = function() CCNS_Refresh() end
        slotText = win:AddText("Showing: -"); slotText.SameLine = true
        statusText = win:AddText("Press Refresh while in character creation.")

        win:AddSeparatorText("Filter by source mod (A-Z)")
        local mfind = win:AddInputText("find mod", "")
        mfind.OnChange = function(hh) modSearchQuery = string.lower(hh.Text or ""); applyModSearch() end
        local clr = win:AddButton("Show all mods"); clr.OnClick = function()
            selectedMods = {}; for _, m in ipairs(modCheckboxes) do pcall(function() m.cb.Checked = false end) end refreshDisplay()
        end
        modChild = win:AddChildWindow("modlist"); modChild.Size = { 0, 130 }; modChild.Border = true

        win:AddSeparatorText("Step through matches (previews on character)")
        local pv = win:AddButton("< Prev match"); pv.OnClick = function() findStep(-1) end
        local nx = win:AddButton("Next match >"); nx.SameLine = true; nx.OnClick = function() findStep(1) end

        win:AddSeparatorText("Results - click to apply")
        countText = win:AddText("Matches: 0")
        resultsChild = win:AddChildWindow("results"); resultsChild.Size = { 0, 0 }; resultsChild.Border = true
        for i = 1, MAXROWS do
            local b = resultsChild:AddButton("")
            b.OnClick = function() applyEntry(rowEntry[i]) end
            pcall(function() b.Visible = false end)
            resultButtons[i] = b
        end
    end)
    if not ok then panelBuilt = false; log("buildPanel error: " .. tostring(err)); return end
    log("panel built (themed, child-scroll, per-slot)")
end

local function openPanel()  if win then win.Open = true end end
local function closePanel() if win then win.Open = false end end
function CCNS_Search()      openPanel(); CCNS_Refresh() end
function CCNS_SearchClose() closePanel() end

-- ===================== lifecycle =====================
Ext.Events.StatsLoaded:Subscribe(function()
    doBake(nil)        -- v6 mod-of-origin label line (unchanged)
    buildHandleMod()   -- handle -> source-mod map
    buildPanel()       -- IMGUI panel (once); hidden until opened by the hotkey
end)

-- v11.11: HOTKEY-ONLY. The Tick heartbeat, poll-window auto-open, auto-numbering, and
-- the GameStateChanged subscriber are all REMOVED. That heartbeat ran a full UI-tree
-- walk (~4ms) every 2s and tripped SE's per-tick profiler ("Dispatching event Tick ...
-- took N ms"), spamming the log. The panel is now summoned only by Ctrl+Shift+H, whose
-- handler runs a SINGLE on-demand acquireCC walk to gate opening to the Hair/Head
-- picker. Tile numbering happens on demand inside CCNS_Refresh when the panel opens.
-- Only two persistent subscriptions remain: StatsLoaded (above) and KeyInput (below).

-- ===================== hotkey toggle (works on ANY screen) =====================
-- Ctrl+Shift+H toggles the search panel from CC, Magic Mirror, AEE, or anywhere.
-- Uses Ext.Events.KeyInput (client). e.Key = SDLScanCode bare string ("H").
-- e.Event = "KeyDown"/"KeyUp". Modifiers = bitmask (LCtrl 64|RCtrl 128, LShift 1|RShift 2)
-- OR a flag-set userdata depending on build -> handle both. v11.6 does NOT call
-- e:PreventAction()/e:StopPropagation() (suppression REMOVED to isolate the v11.5
-- in-game action-lock; the keystroke passes through to the game untouched).
local HOTKEY_KEY = "H"            -- change letter here to rebind
local CTRL_MASK  = 64 | 128
local SHIFT_MASK = 1 | 2
local hotkeyDumped = false
local function modOn(mods, mask, names)
    if type(mods) == "number" then return (mods & mask) ~= 0 end
    if mods ~= nil then
        for _, n in ipairs(names) do local v; pcall(function() v = mods[n] end); if v == true then return true end end
    end
    return false
end
local function togglePanel()
    if not win then pcall(buildPanel) end
    if not win then return end
    local open = false; pcall(function() open = win.Open end)
    if open then
        pcall(function() win.Open = false end)   -- v11.11: close allowed anywhere
    else
        -- v11.11: OPEN only while the Hair/Head picker is present. One on-demand
        -- acquireCC walk per keypress (no heartbeat). Silent no-op elsewhere.
        local cc = acquireCC()
        if not cc then return end
        pcall(function() win:SetPos({ 40, 90 }, "Always") end)
        pcall(function() win.Open = true end)
        CCNS_Refresh()
    end
end
_G.CCNS_Toggle = togglePanel
pcall(function()
    Ext.Events.KeyInput:Subscribe(function(e)
        if not hotkeyDumped then
            hotkeyDumped = true
            pcall(function() log("first key: key=" .. tostring(e.Key) .. " event=" .. tostring(e.Event) .. " modType=" .. type(e.Modifiers) .. " mod=" .. tostring(e.Modifiers)) end)
        end
        local down, rep, k
        pcall(function() down = (tostring(e.Event) == "KeyDown") end)
        pcall(function() rep = e.Repeat end)
        pcall(function() k = tostring(e.Key) end)
        if down and not rep and k == HOTKEY_KEY then
            if modOn(e.Modifiers, CTRL_MASK, { "LCtrl", "RCtrl" }) and modOn(e.Modifiers, SHIFT_MASK, { "LShift", "RShift" }) then
                togglePanel()
                -- v11.6: NO e:PreventAction()/e:StopPropagation(). Suppression removed on
                -- purpose so the key is NOT consumed from the game -- this is the test
                -- that isolates whether suppression caused the v11.5 action-lock.
            end
        end
    end)
end)

-- Console helpers (client context): CCNS_Search() force-opens + loads.
pcall(function()
    _G.CCNS_Search = CCNS_Search
    _G.CCNS_SearchClose = CCNS_SearchClose
    _G.CCNS_Refresh = CCNS_Refresh
    _G.CCNS_BakeAll = CCNS_BakeAll
    _G.CCNS_NumberProbe = CCNS_NumberProbe
end)

log("CCNS v11.13 loaded (HOTKEY-ONLY: Ctrl+Shift+H toggles the search panel; open gated to the Hair/Head picker via one on-demand walk; no Tick heartbeat, no auto-open, no per-tick logging; labels + mod-of-origin; on-demand tile numbering of ALL tiles incl. vanilla; CCNS_Search()/CCNS_Toggle(); v11.13 = v11.12 + number vanilla hairs/heads too).")
