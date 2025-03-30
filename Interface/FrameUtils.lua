local _, SetupManager = ...

local visual = SetupManager.gs.visual

-- add 1px border
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
