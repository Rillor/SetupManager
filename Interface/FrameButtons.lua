local _, SetupManager = ...

function SetupManager:UpdateBossButtons()
    for _, child in ipairs({ SetupManager.BossGroupManager:GetChildren() }) do
        if child:GetName() ~= "BossGroupManagerTitle" and child:GetName() ~= nil and not child:GetName():find("TitleIcon") then
            child:Hide()
        end
    end

    local buttonWidth = 100
    local buttonHeight = 30
    local xOffset = 0
    local yOffset = -40
    local index = 0

    for _, boss in ipairs(SetupManager.bosses) do
        local button = CreateFrame("Button", "BossButton" .. index, SetupManager.BossGroupManager)
        button:SetSize(buttonWidth, buttonHeight)
        button:SetText(boss)
        button:SetPoint("TOPLEFT", xOffset, yOffset + (-1 * (buttonHeight + 3) * index))
        button:SetNormalFontObject("GameFontHighlight")

        -- Align the text to the left
        local text = button:GetFontString()
        if text then
            text:ClearAllPoints()
            text:SetPoint("LEFT", 10, 0) -- Adjust '10' for padding from the left edge
            text:SetJustifyH("LEFT")
        end


        -- button background
        local normalTexture = button:CreateTexture()
        normalTexture:SetAllPoints()
        normalTexture:SetColorTexture(46 /255, 46/255, 46/255, 1)
        button:SetNormalTexture(normalTexture)

        -- highlightTexture
        local highlightTexture = button:CreateTexture()
        highlightTexture:SetAllPoints()
        highlightTexture:SetColorTexture(0.2, 0.2, 0.2, 1)
        button:SetHighlightTexture(highlightTexture)

        button:SetScript("OnClick", function()
            SetupManager:AssignPlayersToGroups(boss)
        end)

        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("|cffffffffSet Setup|r")
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        button:Show()


        local borderColor = SetupManager.gs.visual.borderColor
        SetupManager:AddBorder(button)
        button:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

        -- invite button
        local inviteButton = CreateFrame("Button", "InviteButton" .. index, SetupManager.BossGroupManager)
        inviteButton:SetSize(buttonHeight, buttonHeight)
        inviteButton:SetPoint("LEFT", button, "RIGHT", 10, 0)
        inviteButton:SetNormalFontObject("GameFontHighlight")

        -- invite background
        local inviteNormalTexture = inviteButton:CreateTexture()
        inviteNormalTexture:SetAllPoints()
        inviteNormalTexture:SetTexture("Interface/Minimap/Tracking/Mailbox")
        inviteButton:SetNormalTexture(inviteNormalTexture)

        -- highlightTexture
        local inviteHighlightTexture = inviteButton:CreateTexture()
        inviteHighlightTexture:SetAllPoints()
        inviteHighlightTexture:SetColorTexture(0.3, 0.3, 0.3, 1)
        inviteButton:SetHighlightTexture(inviteHighlightTexture)

        inviteButton:SetScript("OnClick", function()
            SetupManager:Invite(boss)
        end)
        inviteButton:Show()

        inviteButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("|cffffffffInvite missing players|r")
            GameTooltip:Show()
        end)
        inviteButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        index = index + 1
    end

end
