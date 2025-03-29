local _, SetupManager = ...

-- custom print by type in formatted String
function SetupManager:customPrint(message, type)
    local printHeader = "==== Rilla's Setup Manager ===="
    if type == "err" then
        print(printHeader)
        print("|cffee5555" .. message .. "|r")
    elseif type == "success" then
        print(printHeader)
        print("|cff55ee55" .. message .. "|r")
    elseif type == "info" then
        print("|cff00ffff".. message .."|r")
    end
end

-- get ClassColorForPlayer
function SetupManager:GetClassColor(player)
    -- TOOD: get rid of this function
    -- It'll only work for players who are known to the player (guild,raid, friendList) so default to white is afaik what has to be done

    for i = 1, GetNumGroupMembers() do
        local unitName = GetRaidRosterInfo(i)
        if unitName == player then
            local _, classFileName = UnitClass(unitName)
            local color = RAID_CLASS_COLORS[classFileName]

            return format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, player)
        end
    end
    return player
end

-- Helper: normalize names (trim and lower-case)
function SetupManager:normalize(name)
    return (name and name:match("^%s*(.-)%s*$") or ""):lower()
end

-- Function to strip server name from a full player name
function SetupManager:stripServer(name)
    local baseName = name:match("^(.-)%-.+$") or name  -- Strip server if present
    return baseName
end

function SetupManager:getGuildInfo()
    -- Build guildInfo table from the guild roster.
    local guildInfo = {}
    local numMembers = GetNumGuildMembers()
    for i = 1, numMembers do
        local fullName, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
        if fullName then
            local nameWithoutServer = SetupManager:stripServer(fullName)
            guildInfo[nameWithoutServer] = { online = online, fullName = fullName }
        end
    end
    return guildInfo
end

function SetupManager:debug(variable, text)
    if SetupManager.gs.debug then
        if C_AddOns.IsAddOnLoaded("DevTool") then
            DevTool:AddData(variable, text)
        end
    end
end

function SetupManager:AddBorder(parent, thickness, horizontalOffset, verticalOffset)
    if not thickness then thickness = 1 end
    if not horizontalOffset then horizontalOffset = 0 end
    if not verticalOffset then verticalOffset = 0 end

    parent.border = {
        top = parent:CreateTexture(nil, "OVERLAY"),
        bottom = parent:CreateTexture(nil, "OVERLAY"),
        left = parent:CreateTexture(nil, "OVERLAY"),
        right = parent:CreateTexture(nil, "OVERLAY"),
    }

    parent.border.top:SetHeight(thickness)
    parent.border.top:SetPoint("TOPLEFT", parent, "TOPLEFT", -horizontalOffset, verticalOffset)
    parent.border.top:SetPoint("TOPRIGHT", parent, "TOPRIGHT", horizontalOffset, verticalOffset)
    parent.border.top:SetSnapToPixelGrid(false)
    parent.border.top:SetTexelSnappingBias(0)

    parent.border.bottom:SetHeight(thickness)
    parent.border.bottom:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", -horizontalOffset, -verticalOffset)
    parent.border.bottom:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", horizontalOffset, -verticalOffset)
    parent.border.bottom:SetSnapToPixelGrid(false)
    parent.border.bottom:SetTexelSnappingBias(0)

    parent.border.left:SetWidth(thickness)
    parent.border.left:SetPoint("TOPLEFT", parent, "TOPLEFT", -horizontalOffset, verticalOffset)
    parent.border.left:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", -horizontalOffset, -verticalOffset)
    parent.border.left:SetSnapToPixelGrid(false)
    parent.border.left:SetTexelSnappingBias(0)

    parent.border.right:SetWidth(thickness)
    parent.border.right:SetPoint("TOPRIGHT", parent, "TOPRIGHT", horizontalOffset, verticalOffset)
    parent.border.right:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", horizontalOffset, -verticalOffset)
    parent.border.right:SetSnapToPixelGrid(false)
    parent.border.right:SetTexelSnappingBias(0)

    function parent:SetBorderColor(r, g, b)
        for _, tex in pairs(parent.border) do
            tex:SetColorTexture(r, g, b)
        end
    end

    function parent:ShowBorder()
        for _, tex in pairs(parent.border) do
            tex:Show()
        end
    end

    function parent:HideBorder()
        for _, tex in pairs(parent.border) do
            tex:Hide()
        end
    end

    function parent:SetBorderShown(shown)
        if shown then
            parent:ShowBorder()
        else
            parent:HideBorder()
        end
    end

    parent:SetBorderColor(0, 0, 0)
end

