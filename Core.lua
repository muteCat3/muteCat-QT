--- @class muteCatQT: Namespace
local ADDON_NAME, ns = ...

-- =============================================================================
-- UTILITY & SLASH COMMANDS
-- =============================================================================

--- Registers slash commands for user interaction.
local function SetupSlashCommand()
    SLASH_MUTECATQT1 = "/mqt"
    SlashCmdList["MUTECATQT"] = function(msg)
        msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
        print("|cFF33CCFFmuteCat QT:|r Native Tracker Skins sind aktiv.")
    end
end

-- =============================================================================
-- BOOTSTRAP
-- =============================================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon ~= ADDON_NAME then return end

        -- Setup simple slash command
        SetupSlashCommand()

        -- Apply Blizzard Objective Tracker Skinning Hook
        if ns.HookBlizzardTracker then
            ns:HookBlizzardTracker()
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end)
