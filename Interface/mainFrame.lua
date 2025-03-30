local _, SetupManager = ...

local visual = SetupManager.gs.visual
-- setup frame

SetupManager.setupManager = CreateFrame("Frame", "mainWindowSM", UIParent)

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