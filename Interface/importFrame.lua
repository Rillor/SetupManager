local _, SetupManager = ...

local visual = SetupManager.gs.visual

-- importFrame
SetupManager.ImportDialog = CreateFrame("Frame", "ImportDialogFrame", UIParent)
local ImportFrame = SetupManager.ImportDialog

ImportFrame.texture = ImportFrame:CreateTexture(nil, "OVERLAY")
ImportFrame.texture:SetPoint("TOPLEFT", ImportFrame, "TOPLEFT")
ImportFrame.texture:SetPoint("BOTTOMRIGHT", ImportFrame, "BOTTOMRIGHT")
ImportFrame.texture:SetColorTexture(visual.defaultColor.r, visual.defaultColor.g, visual.defaultColor.b, visual.defaultColor.a)
SetupManager:AddBorder(ImportFrame, 1, 1, 1)
local borderColor = visual.borderColor

ImportFrame:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

ImportFrame:SetSize(360, 240)
ImportFrame:SetPoint("CENTER")
ImportFrame:SetMovable(true)
ImportFrame:EnableMouse(true)
ImportFrame:RegisterForDrag("LeftButton")
ImportFrame:SetScript("OnDragStart", ImportFrame.StartMoving)
ImportFrame:SetScript("OnDragStop", ImportFrame.StopMovingOrSizing)


-- close button
local CloseButton = CreateFrame("Button", nil, ImportFrame, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", ImportFrame, "TOPRIGHT", -5, -5)

-- dialog title
ImportFrame.title = ImportFrame:CreateFontString(nil, "OVERLAY")
ImportFrame.title:SetFontObject("GameFontHighlight")
ImportFrame.title:SetPoint("TOP", ImportFrame, "TOP", 0, -15)
ImportFrame.title:SetText("Import String")
ImportFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 16)

-- scrollFrame
local ScrollFrame = CreateFrame("ScrollFrame", nil, ImportFrame)
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
EditBox:SetAutoFocus(false)
EditBox:SetScript("OnEscapePressed", EditBox.ClearFocus)
EditBox:SetScript("OnEnterPressed", EditBox.ClearFocus)
EditBox:SetPoint("TOPLEFT")
EditBox:SetPoint("BOTTOMRIGHT")

ScrollFrame:SetScrollChild(EditBox)

-- importButton
local ImportButton = CreateFrame("Button", "ImportButton", ImportFrame)
ImportButton:SetSize(100, 25)
ImportButton:SetPoint("BOTTOM", ImportFrame, "BOTTOM", 0, 10)
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

-- handleImport
ImportButton:SetScript("OnClick", function()
    local bossString = EditBox:GetText()
    if bossString == "" then
        SetupManager:customPrint("No String provided", "err")
        return
    end

    if bossString then
        SetupManager:importBosses(bossString)
        bossString = null
        ImportFrame:Hide()
        return
    end

    SetupManager:customPrint("Encountered unexpected scenario. Please contact .rilla","err")

end)

-- Show the dialog
ImportFrame:Hide()