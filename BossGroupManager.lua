local _, SetupManager = ...

-- Define the bosses table
SetupManager.bosses = {"Vexie","Cauldron","Rik","Stix","Lockenstock","Bandit","Mug'Zee","Gallywix"}


-- Initialize playersByBoss
if not playersByBoss then
    playersByBoss = {}
end

local setupManager = SetupManager.setupManager

-- Create the main frame inside the container
SetupManager.BossGroupManager = CreateFrame("Frame", "BossGroupManagerFrame", setupManager)
SetupManager.BossGroupManager:SetSize(180, 330) -- Adjusted size for the new layout
SetupManager.BossGroupManager:SetPoint("TOPLEFT", setupManager, "TOPLEFT", 10, -10) -- Adjust position for border

-- Container for the title and icon
SetupManager.titleContainer = CreateFrame("Frame", nil, SetupManager.BossGroupManager)
SetupManager.titleContainer:SetSize(160, 40) -- Adjust size as needed
SetupManager.titleContainer:SetPoint("TOP", SetupManager.BossGroupManager, "TOP", 0, 0) -- Center the container and adjust position

-- Icon to the left of the title
local titleIcon = SetupManager.titleContainer:CreateTexture(nil, "OVERLAY")
titleIcon:SetSize(32, 32) -- Adjust size as needed
titleIcon:SetTexture("Interface\\AddOns\\SetupManager\\Interface\\constantLogo.tga") -- Adjust path as needed
titleIcon:SetPoint("LEFT", 8, 0)

-- Title for the main frame
local title = SetupManager.titleContainer:CreateFontString("BossGroupManagerTitle", "OVERLAY", "GameFontNormal")
title:SetPoint("LEFT", titleIcon, "RIGHT") -- Position title to the right of the icon
title:SetText("|cFFFFFFFFSetup Manager|r")
title:SetFont("Fonts\\FRIZQT__.TTF", 16) -- Set font size to 14, no outline

-- Register events and set up event handler
SetupManager.BossGroupManager:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "SetupManager" then
        if BossGroupManagerSaved == nil then
            BossGroupManagerSaved = {}
        end
        playersByBoss = BossGroupManagerSaved.playersByBoss or {}
        SetupManager:UpdateBossButtons()
    elseif event == "PLAYER_LOGOUT" then
        BossGroupManagerSaved.playersByBoss = playersByBoss
    end
end)
SetupManager.BossGroupManager:RegisterEvent("ADDON_LOADED")
SetupManager.BossGroupManager:RegisterEvent("PLAYER_LOGOUT")

function SetupManager:toggleWindowVisibility()
    if setupManager:IsShown() then
        setupManager:Hide()
    else
        setupManager:Show()
    end
end



-- Slash command handling
SLASH_RILLA1 = "/rilla"
SlashCmdList["RILLA"] = function(input)
    local command, data = input:match("^(%S+)%s*(.*)$")
    if command == "import" then
        SetupManager:ImportPlayers(data)
    elseif command == "delete" then
        SetupManager:DeleteBoss(data)
    elseif command == "toggle" then
        SetupManager:toggleWindowVisibility()
    elseif command == "s" then
        SetupManager:toggleImportDialog()
    elseif command == "clear" then
        SetupManager:ClearBosses()
    else
        print("Unknown command. Use /rilla import [BossName];[Players], /rilla delete [BossName], or /rilla toggle")
    end
end


-- Ensure UpdateBossButtons is called to initialize the buttons
SetupManager:UpdateBossButtons()
setupManager:Hide()
