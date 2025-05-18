local _, SetupManager = ...

local visual = SetupManager.gs.visual
local settings = SetupManager.gs.failedInviteSettings

SetupManager.fi = {}
-- Variables to store the frame and the hide timer handle (store them in your addon's table)
SetupManager.failedInvitesFrame = nil
SetupManager.fi.failedInvitesTimer = nil
SetupManager.fi.failedInvitesTextLines = {} -- To hold the FontString objects we create


function SetupManager:ShowFailedInvites(failedInvites)

    if not mainWindowSM or not mainWindowSM:IsShown() then
        SetupManager:customPrint("Main Window is hidden", "info")
    end

    if not failedInvites or #failedInvites == 0 then
        SetupManager:debug("No failed invites to show because failedInvites is empty")
    end

    if SetupManager.failedInvitesFrame then
        SetupManager.failedInvitesFrame:Hide()
    end

    local frame = SetupManager.failedInvitesFrame

    if not frame then
        frame = CreateFrame("Frame", "FailedInvitesFrame", UIParent)
        frame:SetWidth(settings.FRAME_WIDTH)
        -- frame:SetFrameStrata("MEDIUM")

        frame.texture = frame:CreateTexture(nil, "OVERLAY")
        frame.texture:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
        frame.texture:SetColorTexture(visual.defaultColor.r, visual.defaultColor.g, visual.defaultColor.b, visual.defaultColor.a)

        local borderColor = visual.borderColor
        SetupManager:AddBorder(frame, 1, 1, 1)
        frame:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

        SetupManager.failedInvitesFrame = frame


        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetFontObject(GameFontNormalLarge)
        frame.title:SetJustifyH("CENTER")
        frame.title:SetPoint("TOP", frame, "TOP", 0, -settings.FRAME_PADDING)
        frame.title:SetText("|cffffffffMissing Players|r")
        frame.title:Show()


    end



    for _, textLine in pairs(SetupManager.fi.failedInvitesTextLines) do
        textLine:Hide()
    end
    wipe(SetupManager.fi.failedInvitesTextLines)

    local titleOffset = 25
    local currentY = -settings.FRAME_PADDING - titleOffset
    local totalHeight = settings.FRAME_PADDING + titleOffset


    for i, playername in pairs (failedInvites) do
        local missingPlayer = NSAPI:GetName(playername)
        local failedPlayerName = playername:match("^(.-)%-.+$") or playername
        local failedPlayerGuildInfo = guildInfo[failedPlayerName]
        local fpClass = failedPlayerGuildInfo.class or "ffffff"
        local fphexcode = string.sub(RAID_CLASS_COLORS[fpClass].colorStr,-6)

        local textLine = frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
        textLine:SetText("|cff" .. fphexcode .. missingPlayer .. "|r")
        textLine:SetJustifyH("LEFT")
        textLine:SetWidth(settings.FRAME_WIDTH - (2* settings.FRAME_PADDING))
        textLine:SetPoint("TOPLEFT", frame, "TOPLEFT", settings.X_OFFSET, currentY)

        textLine:Show()
        table.insert(SetupManager.fi.failedInvitesTextLines,textLine)

        local fontHeigth = 14
        currentY = currentY - fontHeigth - settings.LINE_SPACING
        totalHeight = totalHeight + fontHeigth + (i > 1 and settings.LINE_SPACING or 0)
    end

    totalHeight = totalHeight + settings.FRAME_PADDING
    frame:SetHeight(totalHeight)

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", mainWindowSM, "TOPRIGHT", settings.X_OFFSET, 0)
    frame:Show()

    if SetupManager.fi.failedInvitesTimer then
        SetupManager:debug("Cancelling previous timer due to it being overwritten")
        SetupManager.fi.failedInvitesTimer = nil
    end

    SetupManager.fi.failedInvitesTimer = C_Timer.NewTimer(settings.HIDE_DELAY, function()
        if SetupManager.failedInvitesFrame then
            SetupManager.failedInvitesFrame:Hide()
        end
        SetupManager.fi.failedInvitesTimer = nil
    end)
end