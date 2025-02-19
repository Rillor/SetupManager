local _, SetupManager = ...


-- Setup Manager Frame Creation
-- Create a container frame for the entire UI
SetupManager.setupManager = CreateFrame("Frame", "BossGroupManagerContainer", UIParent, "BackdropTemplate")
SetupManager.setupManager:SetSize(200, 350) -- Adjusted size for better fit
SetupManager.setupManager:SetPoint("CENTER")
SetupManager.setupManager:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }, })
SetupManager.setupManager:SetBackdropColor(0, 0, 0, 0.8) -- Black background with 30% opacity
SetupManager.setupManager:SetBackdropBorderColor(0, 0, 0) -- Black border

-- Enable dragging for the container frame
SetupManager.setupManager:EnableMouse(true)
SetupManager.setupManager:SetMovable(true)
SetupManager.setupManager:RegisterForDrag("LeftButton")
SetupManager.setupManager:SetScript("OnDragStart", SetupManager.setupManager.StartMoving)
SetupManager.setupManager:SetScript("OnDragStop", SetupManager.setupManager.StopMovingOrSizing)

local backdropData = { bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }, }
-- Import Dialog Frame Creation
-- Create the main frame for the dialog
SetupManager.ImportDialog = CreateFrame("Frame", "ImportDialogFrame", UIParent, "BackdropTemplate")
SetupManager.ImportDialog:SetSize(380, 300) -- Adjusted size for better layout
SetupManager.ImportDialog:SetPoint("CENTER") -- Center the dialog on the screen
SetupManager.ImportDialog:SetMovable(true) -- Make the frame movable
SetupManager.ImportDialog:SetResizable(true) -- Make the frame resizable
SetupManager.ImportDialog:EnableMouse(true) -- Enable mouse interaction
SetupManager.ImportDialog:RegisterForDrag("LeftButton") -- Register the frame for dragging
SetupManager.ImportDialog:SetScript("OnDragStart", SetupManager.ImportDialog.StartMoving) -- Script for dragging
SetupManager.ImportDialog:SetScript("OnDragStop", SetupManager.ImportDialog.StopMovingOrSizing) -- Script to stop moving
SetupManager.ImportDialog:SetBackdrop(backdropData)

-- Create the close button (X)
local CloseButton = CreateFrame("Button", nil, SetupManager.ImportDialog, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", SetupManager.ImportDialog, "TOPRIGHT", -5, -5)

-- Create the title for the dialog
SetupManager.ImportDialog.title = SetupManager.ImportDialog:CreateFontString(nil, "OVERLAY")
SetupManager.ImportDialog.title:SetFontObject("GameFontHighlight")
SetupManager.ImportDialog.title:SetPoint("TOP", SetupManager.ImportDialog, "TOP", 0, -15)
SetupManager.ImportDialog.title:SetText("Import String")
SetupManager.ImportDialog.title:SetFont("Fonts\\FRIZQT__.TTF", 16)

-- Create the frame for the backdrop behind the edit box
local BackdropFrame = CreateFrame("Frame", nil, SetupManager.ImportDialog, "BackdropTemplate")
BackdropFrame:SetSize(320, 150) -- Set size for the backdrop frame
BackdropFrame:SetPoint("TOP", SetupManager.ImportDialog, "TOP", 0, -40)
BackdropFrame:SetBackdrop(backdropData)
BackdropFrame:SetBackdropColor(0.7, 0.7, 0.7, 1)
BackdropFrame:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)

-- Create the scroll frame for the text input
local ScrollFrame = CreateFrame("ScrollFrame", nil, BackdropFrame, "UIPanelScrollFrameTemplate")
ScrollFrame:SetSize(320, 140) -- Adjusted size to fit inside the backdrop frame
ScrollFrame:SetPoint("TOPLEFT", 5, -5) -- Indent within the backdrop frame

-- Create the edit box for input inside the scroll frame
local EditBox = CreateFrame("EditBox", nil, ScrollFrame)
EditBox:SetMultiLine(true)
EditBox:SetFontObject("ChatFontNormal")
EditBox:SetSize(320, 140) -- Adjust size to fit inside the scroll frame
EditBox:SetAutoFocus(true)
EditBox:SetScript("OnEscapePressed", EditBox.ClearFocus)
EditBox:SetScript("OnEnterPressed", EditBox.ClearFocus)
EditBox:SetPoint("TOPLEFT")
EditBox:SetPoint("BOTTOMRIGHT")

ScrollFrame:SetScrollChild(EditBox)

-- Create the import button
local ImportButton = CreateFrame("Button", "ImportButton", SetupManager.ImportDialog, "GameMenuButtonTemplate")
ImportButton:SetSize(100, 25) -- Adjust size as needed
ImportButton:SetPoint("BOTTOM", SetupManager.ImportDialog, "BOTTOM", 0, 10)
ImportButton:SetText("Import")
ImportButton:SetNormalFontObject("GameFontNormalLarge")
ImportButton:SetHighlightFontObject("GameFontHighlightLarge")

-- Create a texture and set it as the button's background
local normalTexture = ImportButton:CreateTexture()
normalTexture:SetAllPoints()
normalTexture:SetColorTexture(0.11, 0.11, 0.11, 1) -- RGB values for #1c1c1c
ImportButton:SetNormalTexture(normalTexture)

-- Create a texture for hover and set it as the highlight texture
local highlightTexture = ImportButton:CreateTexture()
highlightTexture:SetAllPoints()
highlightTexture:SetColorTexture(0.3, 0.3, 0.3, 1) -- Brighter shade for hover
ImportButton:SetHighlightTexture(highlightTexture)

-- Define the function to handle the import
ImportButton:SetScript("OnClick", function()
    local bossString = EditBox:GetText()
    -- Process the imported string as needed
    if bossString == "" then
        SetupManager:customPrint("No String provided", "err")
        return
    end

    if bossString then
        SetupManager:importBosses(bossString)
        bossString = null
        SetupManager.ImportDialog:Hide()
        return
    end

    SetupManager:customPrint("Encountered unexpected scenario. Please contact Rilla#1506","err")

end)

-- Show the dialog
SetupManager.ImportDialog:Hide()