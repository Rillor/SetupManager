local _, SetupManager = ...

local visual = SetupManager.gs.visual

-- setup frame
SetupManager.setupManager = CreateFrame("Frame", nil, UIParent)

SetupManager.setupManager.texture = SetupManager.setupManager:CreateTexture(nil, "OVERLAY")
SetupManager.setupManager.texture:SetPoint("TOPLEFT", SetupManager.setupManager, "TOPLEFT")
SetupManager.setupManager.texture:SetPoint("BOTTOMRIGHT", SetupManager.setupManager, "BOTTOMRIGHT")
SetupManager.setupManager.texture:SetColorTexture(visual.defaultColor.r, visual.defaultColor.g, visual.defaultColor.b, visual.defaultColor.a)
SetupManager.setupManager:SetSize(200, 350)
SetupManager.setupManager:SetPoint("CENTER")


local borderColor = visual.borderColor
SetupManager:AddBorder(SetupManager.setupManager, 1, 1, 1)
SetupManager.setupManager:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

SetupManager.setupManager:EnableMouse(true)
SetupManager.setupManager:SetMovable(true)
SetupManager.setupManager:RegisterForDrag("LeftButton")
SetupManager.setupManager:SetScript("OnDragStart", SetupManager.setupManager.StartMoving)
SetupManager.setupManager:SetScript("OnDragStop", SetupManager.setupManager.StopMovingOrSizing)


-- Create the main frame for the dialog
SetupManager.ImportDialog = CreateFrame("Frame", "ImportDialogFrame", UIParent)
SetupManager.ImportDialog.texture = SetupManager.ImportDialog:CreateTexture(nil, "OVERLAY")
SetupManager.ImportDialog.texture:SetPoint("TOPLEFT", SetupManager.ImportDialog, "TOPLEFT")
SetupManager.ImportDialog.texture:SetPoint("BOTTOMRIGHT", SetupManager.ImportDialog, "BOTTOMRIGHT")
SetupManager.ImportDialog.texture:SetColorTexture(visual.defaultColor.r, visual.defaultColor.g, visual.defaultColor.b, visual.defaultColor.a)
SetupManager:AddBorder(SetupManager.ImportDialog, 1, 1, 1)
SetupManager.ImportDialog:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

SetupManager.ImportDialog:SetSize(380, 240)
SetupManager.ImportDialog:SetPoint("CENTER")
SetupManager.ImportDialog:SetMovable(true)
SetupManager.ImportDialog:EnableMouse(true)
SetupManager.ImportDialog:RegisterForDrag("LeftButton")
SetupManager.ImportDialog:SetScript("OnDragStart", SetupManager.ImportDialog.StartMoving)
SetupManager.ImportDialog:SetScript("OnDragStop", SetupManager.ImportDialog.StopMovingOrSizing)


-- close button
local CloseButton = CreateFrame("Button", nil, SetupManager.ImportDialog, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", SetupManager.ImportDialog, "TOPRIGHT", -5, -5)

-- dialog title
SetupManager.ImportDialog.title = SetupManager.ImportDialog:CreateFontString(nil, "OVERLAY")
SetupManager.ImportDialog.title:SetFontObject("GameFontHighlight")
SetupManager.ImportDialog.title:SetPoint("TOP", SetupManager.ImportDialog, "TOP", 0, -15)
SetupManager.ImportDialog.title:SetText("Import String")
SetupManager.ImportDialog.title:SetFont("Fonts\\FRIZQT__.TTF", 16)

-- scrollFrame
local ScrollFrame = CreateFrame("ScrollFrame", nil, SetupManager.ImportDialog)
ScrollFrame:SetSize(320, 140)
ScrollFrame:SetPoint("TOP", 0, -45)
ScrollFrame.texture = ScrollFrame:CreateTexture(nil, "OVERLAY")
ScrollFrame.texture:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT")
ScrollFrame.texture:SetPoint("BOTTOMRIGHT", ScrollFrame, "BOTTOMRIGHT")
ScrollFrame.texture:SetColorTexture(visual.defaultHighlightColor.r, visual.defaultHighlightColor.g, visual.defaultHighlightColor.b, visual.defaultHighlightColor.a)
SetupManager:AddBorder(ScrollFrame, 1, 1, 1)
ScrollFrame:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

-- editBox
local EditBox = CreateFrame("EditBox", nil, ScrollFrame)
EditBox:SetMultiLine(true)
EditBox:SetFontObject("ChatFontNormal")
EditBox:SetSize(320, 140)
EditBox:SetAutoFocus(true)
EditBox:SetScript("OnEscapePressed", EditBox.ClearFocus)
EditBox:SetScript("OnEnterPressed", EditBox.ClearFocus)
EditBox:SetPoint("TOPLEFT")
EditBox:SetPoint("BOTTOMRIGHT")

-- importButton
local ImportButton = CreateFrame("Button", "ImportButton", SetupManager.ImportDialog)
ImportButton:SetSize(100, 25)
ImportButton:SetPoint("BOTTOM", SetupManager.ImportDialog, "BOTTOM", 0, 10)
ImportButton:SetText("Import")
ImportButton:SetNormalFontObject("GameFontHighlight")
ImportButton:SetHighlightFontObject("GameFontHighlight")

-- button background
local normalTexture = ImportButton:CreateTexture()
normalTexture:SetAllPoints()
normalTexture:SetColorTexture(visual.buttonColor.r, visual.buttonColor.g, visual.buttonColor.b,visual.buttonColor.a)
ImportButton:SetNormalTexture(normalTexture)

-- highlightTexture
local highlightTexture = ImportButton:CreateTexture()
highlightTexture:SetAllPoints()
highlightTexture:SetColorTexture(0.2, 0.2, 0.2, 1)
ImportButton:SetHighlightTexture(highlightTexture)


SetupManager:AddBorder(ImportButton,1,1,1)
ImportButton:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

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

