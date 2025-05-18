local _, SetupManager = ...
-- TODO: build function to verify majority is from guild (either NS aura_env or hardcode)

-- open importDialog
function SetupManager:toggleImportDialog()
    if SetupManager.ImportDialog:IsShown() then
        SetupManager.ImportDialog:Hide()
    else
        SetupManager.ImportDialog:Show()
    end
end

-- TODO: make sure that alt-checking is completely integrated and not some normalize vs nonNormalized bullshit
-- Function to print players missing from a specific boss setup
function SetupManager:EvaluateMissingPlayers(boss)
    if not playersByBoss[boss] then
        print("Early cancel: No setup found for boss '" .. boss .. "'")
        return
    end

    if not NSPAI then
        return
    end

    for _, setupPlayer in ipairs(playersByBoss[boss]) do
        if setupPlayer then
            local found = false
            local nickname = NSAPI:GetName(setupPlayer) -- Rilla TODO: update this to include addon name(?)

            for i = 1, GetNumGroupMembers() do
                local unitName = GetRaidRosterInfo(i) -- Rillap-Blackrock
                local gmNickname = NSAPI:GetName(unitName) -- Rilla

                if nickname == gmNickname then
                    found = true
                    break
                end

                if not found then
                    table.insert(missingPlayers, setupPlayer)
                end
            end
        end

        if #missingPlayers > 0 then
            SetupManager:ShowFailedInvites(missingPlayers)
        end
    end
end

-- Function to invite missing players
local failedInvites = {} -- List to store players who couldn't be invited
-- TODO: api limitation read (check what kind of message it is)
-- check for api limitation call and then pass call again after a while (check if api limit is exposed to be checkable)
-- ^- pass playersByBoss[boss]


-- Function to handle system messages
local function SystemMessageHandler(msg)
    local playerName = msg:match("Cannot find player '([^']+)'") -- Adjust pattern to extract player name

    if not playerName then
        return
    end

    if not strfind(playerName, "-") then
        playerName = playerName .. "-Blackrock"
    end

    if playerName then
        table.insert(failedInvites, playerName)
    end
end


-- Register for system messages
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        SystemMessageHandler(msg)
    end
end)

function SetupManager:Invite(boss)
    if not playersByBoss[boss] then
        return
    end

    failedInvites = {}

    for _, player in ipairs(playersByBoss[boss]) do
        if player then
            local found = false
            local nickname = NSAPI:GetName(player) -- Rilla TODO: update this to include addon name(?)

            for i = 1, GetNumGroupMembers() do
                local unitName = GetRaidRosterInfo(i) -- Rillap-Blackrock
                local gmNickname = NSAPI:GetName(unitName) -- Rilla

                if nickname == gmNickname then
                    found = true
                    break
                end
            end

            if not found then
                C_PartyInfo.InviteUnit(player)
            end
        end
    end

    C_Timer.After(1, function()
        -- convert group to raid
        if IsInGroup() and not IsInRaid() then
            C_PartyInfo.ConvertToRaid()
        end

        if #failedInvites > 0 then
            local guildInfo = SetupManager:getGuildInfo()

            -- TODO: register nickname in failedInvites instead of characterName
            for _, failedPlayer in ipairs(failedInvites) do
                DevTool:AddData(failedPlayer, "failedPlayer")
                local fpNickname = NSAPI:GetName(failedPlayer) -- Rilla

                local altList = NSAPI:GetCharacters(fpNickname)
                DevTool:AddData(altList, "altList for player")

                if altList then
                    local invitedAny = false
                    for _, characterName in ipairs(altList) do
                        local charName = characterName:match("^(.-)%-.+$") or characterName -- strip server from characterName as guildInfo does not include it in key
                        local altInfo = guildInfo[charName]
                        if altInfo and altInfo.online then
                            invitedAny = true
                            C_PartyInfo.InviteUnit(altInfo.fullName)
                            break
                        end
                    end
                    if not invitedAny then
                        SetupManager:customPrint("No character online for " .. failedPlayer, "err")
                    end
                end
            end
            SetupManager:ShowFailedInvites(failedInvites)
            failedInvites = {}
        end
    end)
end

SetupManager.currentBoss = nil
function SetupManager:AssignPlayersToGroups(boss)
    if not playersByBoss then
        SetupManager:customPrint("There have been no setups provided yet. Please copy sheet Input.", "err")
        return
    end

    if not playersByBoss[boss] then
        SetupManager:customPrint("No Setup for " .. boss, "err")
        return
    end

    if not NSAPI then
        return
    end

    SetupManager.currentBoss = boss  -- Store the current boss identifier
    local maxGroupMembers = 5
    local totalGroups = 8
    local raidMembers = {}
    local unassignedPlayers = {}
    local assignedPlayers = {}
    local groupCounts = {}

    -- Initialize group counts
    for i = 1, totalGroups do
        groupCounts[i] = 0
    end

    for i = 1, GetNumGroupMembers() do
        local unitName, _, subgroup = GetRaidRosterInfo(i)
        local found = false
        DevTool:AddData(unitName, "unitName")
        local gmNickname = NSAPI:GetName(unitName)
        DevTool:AddData(gmNickname, "gmNickname")

        if subgroup and type(subgroup) == "number" then
            raidMembers[unitName] = { index = i, group = subgroup }
            groupCounts[subgroup] = groupCounts[subgroup] + 1

            for _, player in ipairs(playersByBoss[boss]) do
                if player then
                    local setupNickname = NSAPI:GetName(player)

                    if setupNickname == gmNickname then
                        found = true
                        assignedPlayers[unitName] = i
                        break
                    end
                end
            end

            if not found then
                unassignedPlayers[unitName] = i
            end
        end
    end

    -- move unassignedPlayers to group 5-8
    for unitName, index in pairs(unassignedPlayers) do
        local currentGroup = raidMembers[unitName].group
        if currentGroup <= 4 then
            for newGroup = 8, 5, -1 do
                if groupCounts[newGroup] < maxGroupMembers then
                    SetRaidSubgroup(index, newGroup)
                    groupCounts[newGroup] = groupCounts[newGroup] + 1
                    groupCounts[currentGroup] = groupCounts[currentGroup] - 1
                    break
                end
            end
        end
    end

    -- create groupLayout for group 1-4
    local groupLayout = {}
    for i = 1, totalGroups do
        groupLayout[i] = {}
    end

    -- prepare groupLayout for assigned players
    for player, index in pairs(assignedPlayers) do
        local targetGroup = math.ceil(index / maxGroupMembers)
        local targetSlot = index % maxGroupMembers

        if targetSlot == 0 then
            targetSlot = maxGroupMembers
        end

        if targetGroup <= 4 then
            groupLayout[targetGroup][targetSlot] = player
        end
    end

    DevTool:AddData(groupLayout, "reworked GroupLayout")

    -- move players to correct group and slot
    for group, slots in ipairs(groupLayout) do
        if group <= 4 then
            for slot, player in pairs(slots) do
                if player and raidMembers[player] then
                    local currentGroup = raidMembers[player].group
                    local currentIndex = raidMembers[player].index

                    if currentGroup ~= group then
                        SetRaidSubgroup(currentIndex, group)
                    end
                end
            end
        end
    end

    SetupManager:EvaluateMissingPlayers(boss)
end

-- Ulgrax:Rillasp+2,Rilladk+1,Fyfan,Rillaschwanß,Rillad+4
-- Function to import bosses from and prepare boss-Table
-- TODO: Add functionality for split bullshit (kms)
function SetupManager:importBosses(bossString)
    local bossesFromString = { strsplit(";", bossString) }
    local bossNames = {}

    for _, boss in ipairs(bossesFromString) do
        local bossName, players = strsplit(":", boss)
        table.insert(bossNames, bossName)

        if bossName and players then
            local playerList = {}
            local usedSlots = {}
            local nextSlot = 1
            local playersWithoutSlots = {}

            -- players with SlotInfo
            for _, player in ipairs({ strsplit(",", players) }) do
                local playerName, providedSlot = strsplit("+", player)
                playerName = playerName:match("^%s*(.-)%s*$") -- Trim spaces
                local slot = tonumber(providedSlot)

                if slot and not usedSlots[slot] then
                    playerList[slot] = playerName
                    usedSlots[slot] = true
                else
                    table.insert(playersWithoutSlots, playerName)
                end
            end

            -- players w/o slotIfo
            for _, playerName in ipairs(playersWithoutSlots) do
                while usedSlots[nextSlot] do
                    nextSlot = nextSlot + 1
                end
                playerList[nextSlot] = playerName
                usedSlots[nextSlot] = true
                nextSlot = nextSlot + 1
            end

            SetupManager.setupManager:Show()
            playersByBoss[bossName] = playerList
        end
    end

    -- Update saved variable
    BossGroupManagerSaved.playersByBoss = playersByBoss

    -- Print imported setups for the bosses
    SetupManager:customPrint("Imported setups for the following bosses:", "success")
    print(table.concat(bossNames, ", "))

    -- Update the UI
    SetupManager:UpdateBossButtons()
end

-- Slash command: Import players for multiple bosses
function SetupManager:ImportPlayers(input)
    if not input or input == "" then
        SetupManager:customPrint("Invalid format. Use: /Rilla import Ulgrax;Player1,Player2:Boss2;Player3,Player4", "err")
        return
    end

    -- Process the input string using the importBosses function
    SetupManager:importBosses(input)
end

-- Slash command: Delete a boss
function SetupManager:DeleteBoss(boss)
    if playersByBoss[boss] then
        playersByBoss[boss] = nil
        BossGroupManagerSaved.playersByBoss = playersByBoss -- Update saved variable
        SetupManager:customPrint("Deleted boss: " .. boss, "success")
        SetupManager:UpdateBossButtons()
    else
        SetupManager.customPrint("Boss not found: " .. boss, "err")
    end
end


-- Function to reorder players within their groups based on slots
--[[
function SetupManager:ReorderPlayersWithinGroups()
    local boss = SetupManager.currentBoss
    if not boss or not playersByBoss[boss] then
        SetupManager:customPrint("Consistency Check is missing boss", "info")
        return
    end

    local players = playersByBoss[boss]
    local maxGroupMembers = 5
    local totalGroups = 8

    -- Create group layout for assigned players
    local groupLayout = {}
    for i = 1, totalGroups do
        groupLayout[i] = {}
    end

    -- Place players with specified slots first
    for _, player in ipairs(players) do
        local slot = tonumber(player:match("%+(%d+)$")) -- Extract slot if specified

        if slot then
            local targetGroup = math.ceil(slot / maxGroupMembers)
            local targetSlot = slot % maxGroupMembers
            if targetSlot == 0 then
                targetSlot = maxGroupMembers
            end

            groupLayout[targetGroup][targetSlot] = player:match("^(.-)%+") -- Remove the slot from the player's name
        end
    end

    -- Place players without specified slots
    local nextSlot = 1
    for _, player in ipairs(players) do
        if not player:match("%+(%d+)$") then
            while groupLayout[math.ceil(nextSlot / maxGroupMembers)][nextSlot % maxGroupMembers] do
                nextSlot = nextSlot + 1
            end

            local targetGroup = math.ceil(nextSlot / maxGroupMembers)
            local targetSlot = nextSlot % maxGroupMembers
            if targetSlot == 0 then
                targetSlot = maxGroupMembers
            end

            groupLayout[targetGroup][targetSlot] = player
            nextSlot = nextSlot + 1
        end
    end

    -- Reorder players within their respective groups
    for group, slots in ipairs(groupLayout) do
        if group <= 4 then
            -- Collect current positions of players in the group
            local currentPositions = {}
            for i = 1, GetNumGroupMembers() do
                local unitName, _, subgroup, _, class = GetRaidRosterInfo(i)
                if subgroup == group then
                    table.insert(currentPositions, { name = unitName, index = i, class = class })
                end
            end

            -- Create a temporary table to hold the correct order
            local tempPositions = {}
            for _, player in ipairs(slots) do
                if player then
                    for _, pos in ipairs(currentPositions) do
                        if pos.name == player then
                            table.insert(tempPositions, pos)
                            break
                        end
                    end
                end
            end

            -- Move players within the group to match the correct order
            for slot, pos in ipairs(tempPositions) do
                if pos and currentPositions[player].index ~= tempPositions[playersByBoss].index then
                    SetRaidSubgroup(pos.index, group)
                    SetupManager:customPrint("Moved " .. pos.name .. " to group " .. group .. " slot " .. slot, "info")
                end
            end
        end
    end

    SetupManager:customPrint("Reordered players within groups 1-4 successfully.", "success")
end
]]--