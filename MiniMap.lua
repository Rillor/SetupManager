local _, SetupManager = ...

-- Create the frame for the Minimap button
SetupManager.MiniMapButton = CreateFrame("Button", "MyMinimapButton", Minimap)
SetupManager.MiniMapButton:SetFrameStrata("MEDIUM")
SetupManager.MiniMapButton:SetWidth(32)
SetupManager.MiniMapButton:SetHeight(32)
SetupManager.MiniMapButton:SetFrameLevel(8)
SetupManager.MiniMapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
SetupManager.MiniMapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- Position the button on the Minimap
local function UpdatePosition()
    local xpos = 52 - (80 * cos(SetupManager.MiniMapButton.angle))
    local ypos = (80 * sin(SetupManager.MiniMapButton.angle)) - 52
    SetupManager.MiniMapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", xpos, ypos)
end

-- Set the default position
SetupManager.MiniMapButton.angle = 45
UpdatePosition()

-- Make the button draggable
SetupManager.MiniMapButton:RegisterForDrag("LeftButton", "RightButton")
SetupManager.MiniMapButton:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
SetupManager.MiniMapButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save the position
    local xpos, ypos = SetupManager.MiniMapButton:GetCenter()
    local minimapCenterX, minimapCenterY = Minimap:GetCenter()
    SetupManager.MiniMapButton.angle = atan2(ypos - minimapCenterY, xpos - minimapCenterX)
    UpdatePosition()
end)

-- Set the texture for the button
local icon = SetupManager.MiniMapButton:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\AddOns\\SetupManager\\constantLogo.tga")
icon:SetAllPoints(SetupManager.MiniMapButton)

-- Set the click function for the button
SetupManager.MiniMapButton:SetScript("OnClick", function(_, button)
    if button == "LeftButton" then
        SetupManager:toggleImportDialog()
    elseif button == "RightButton" then
        SetupManager:toggleWindowVisibility()
    end
end)

