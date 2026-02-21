--- @class muteCatQT: Namespace
local ADDON_NAME, ns = ...

-- =============================================================================
-- CONSTANTS & SETTINGS
-- =============================================================================
local HEADER_FONT_SIZE = 10     -- Font size for module headers (Campaign, Quests, etc.)
local POI_SCALE        = 0.75   -- Scale factor for POI buttons (quest numbers/icons)

-- =============================================================================
-- FONT CUSTOMIZATION
-- =============================================================================

--- Overrides the default ObjectiveFont to add an outline and remove shadows.
--- Improves readability across different background textures.
local function OverrideObjectiveFonts()
    if ObjectiveFont then
        local fontPath, fontSize = ObjectiveFont:GetFont()
        ObjectiveFont:SetFont(fontPath, fontSize, "OUTLINE")
        ObjectiveFont:SetShadowColor(0, 0, 0, 0)
    end
end

-- =============================================================================
-- INTERFACE CLEANUP
-- =============================================================================

--- Hides the main "OBJECTIVES" header of the tracker.
--- We prefer a cleaner look without the default overarching title.
local function HideObjectivesHeader()
    local header = ObjectiveTrackerFrame.Header
    if not header then return end

    header:Hide()
    header:SetAlpha(0)
    header:SetScale(0.001)

    -- Force concealment in case Blizzard logic re-triggers visibility
    if not header.forceHideHooked then
        hooksecurefunc(header, "Show", function(self)
            self:Hide()
        end)
        header.forceHideHooked = true
    end
end

-- =============================================================================
-- POI ICON POSITIONING (Quest Blobs / Shields)
-- =============================================================================

--- Scales and repositions quest POI icons (the numbered buttons on the tracker).
--- Hooks the native POIButtonMixin to apply styling whenever a button is updated.
local function ScalePOIIcons()
    if not (POIButtonMixin and POIButtonMixin.UpdateButtonStyle) then return end
    if ns.__mqtPOIStyleHooked then return end
    ns.__mqtPOIStyleHooked = true

    hooksecurefunc(POIButtonMixin, "UpdateButtonStyle", function(self)
        self:SetScale(POI_SCALE)
    end)
end

-- =============================================================================
-- MODULE SKINNING ENGINE
-- =============================================================================

--- Applies custom aesthetic changes to individual tracker modules.
--- Removes dark backgrounds and adds a subtle gold highlight bar.
--- @param module table The native Blizzard objective tracker module.
local function SkinModule(module)
    if not module or not module.Header then return end

    local header = module.Header

    -- Suppress default header visuals
    if header.Background then
        header.Background:SetTexture(nil)
        header.Background:SetAlpha(0)
    end

    -- Enforce a uniform header height for a tidier layout
    header:SetHeight(18)

    -- Disable default highlight effects
    if header.Glow  then header.Glow:SetAlpha(0)  end
    if header.Shine then header.Shine:SetAlpha(0) end

    -- Inject a 2px custom underline bar (Gold theme)
    if not header.CustomHighlight then
        local hl = header:CreateTexture(nil, "OVERLAY")
        hl:SetHeight(2)
        hl:SetPoint("BOTTOMLEFT",  header, "BOTTOMLEFT",   8, 0)
        hl:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -8, 0)
        hl:SetColorTexture(1, 0.82, 0, 0.6) -- Classic Blizzard Gold with 60% Alpha
        hl:Show()
        header.CustomHighlight = hl
    end

    -- Hook into header animations to ensure backgrounds stay hidden
    if header.AddAnim and not header.__mqtAnimHooked then
        local function SuppressBackground()
            if header.Background then header.Background:SetAlpha(0) end
            if header.Glow       then header.Glow:SetAlpha(0)       end
        end
        header.AddAnim:HookScript("OnPlay",     SuppressBackground)
        header.AddAnim:HookScript("OnFinished", SuppressBackground)
        header.__mqtAnimHooked = true
    end

    -- Refine header text styling
    if header.Text then
        local fontPath = header.Text:GetFont()
        header.Text:SetFont(fontPath, HEADER_FONT_SIZE, "")
        header.Text:SetShadowColor(0, 0, 0, 1)
        header.Text:SetShadowOffset(1, -1)
        
        -- Align text within the custom height
        header.Text:ClearAllPoints()
        header.Text:SetPoint("LEFT", header, "LEFT", 10, 1)
    end
end

-- =============================================================================
-- TRACKER INITIALIZATION
-- =============================================================================

--- Scans for existing tracker modules and sets up hooks for future ones.
local function InitDynamicSkinning()
    if not ObjectiveTrackerManager or not ObjectiveTrackerManager.moduleToContainerMap then return end

    -- Skin all currently active modules
    for module in pairs(ObjectiveTrackerManager.moduleToContainerMap) do
        SkinModule(module)
    end

    -- Intercept modules created in the future (dynamic loading)
    if ObjectiveTrackerManager.SetModuleContainer and not ns.__mqtSetModuleHooked then
        hooksecurefunc(ObjectiveTrackerManager, "SetModuleContainer", function(_, module)
            SkinModule(module)
        end)
        ns.__mqtSetModuleHooked = true
    end
end

-- =============================================================================
-- PUBLIC INTERFACE
-- =============================================================================

--- Main entry point for the skinning module.
--- Called by Core.lua during the ADDON_LOADED event.
function ns:HookBlizzardTracker()
    OverrideObjectiveFonts()
    HideObjectivesHeader()
    ScalePOIIcons()
    InitDynamicSkinning()
end
