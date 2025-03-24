local _, SetupManager = ...
-- TODO: add debugging variable dependency on DevTools Addon. So it only prints when that is enabled

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

    unmodifiedfullCharList = NSAPI and NSAPI:GetAllCharacters() or {} -- need to do this in assign too
    local fullCharList = {}
    -- Normalize both keys and values in fullCharList
    for characterName, mainCharacter in pairs(unmodifiedfullCharList) do
        fullCharList[characterName] = mainCharacter
    end

    local missingPlayers = {}
    for _, playerName in ipairs(playersByBoss[boss]) do
        if playerName then

            --[[
                playerName -> Nickname



            ]]--
            local player = fullCharList[playerName] or playerName
            local found = false

            for i = 1, GetNumGroupMembers() do
                local unitName = GetRaidRosterInfo(i)
                local nickName = fullCharList[unitName] or unitName

                -- Check if the main name matches the target player
                if nickName == player then
                    found = true
                    break
                end
            end

            if not found then
                table.insert(missingPlayers, SetupManager:GetClassColor(player))
            end
        end
    end

    if #missingPlayers > 0 then
        SetupManager:customPrint("Players missing from " .. boss .. " setup:", "err")
        print(table.concat(missingPlayers, ", "))
    else
        SetupManager:customPrint("All assigned players (or their alts) are present for " .. boss .. ".", "success")
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

function SetupManager:InviteMissingPlayers(boss)
    local fullCharList = NSAPI and NSAPI:GetAllCharacters() or {}

    local assignedPlayers = playersByBoss[boss]
    if not assignedPlayers then
        SetupManager:customPrint("No Setup for " .. boss, "err")
        return
    end
    failedInvites = failedInvites or {}

    --[[ DevTool:AddData({
        assignedPlayers = assignedPlayers,
        fullCharList = fullCharList
    })
    ]]--

    for _, playerName in ipairs(assignedPlayers) do
        if playerName then
            local targetPlayer = SetupManager:normalize(playerName)
            local found = false
            for i = 1, GetNumGroupMembers() do
                local unitName = GetRaidRosterInfo(i)
                -- TODO: make this smarter lol
                local strippedUnitName = SetupManager:normalize(SetupManager:stripServer(unitName))
                local mainName = fullCharList[strippedUnitName] or strippedUnitName

                --[[ DevTool:AddData({
                    unitName = unitName,
                    strippedUnitName = strippedUnitName,
                    mainName = mainName
                })
                ]]--

                if SetupManager:normalize(mainName) == targetPlayer then
                    found = true
                    break
                end
            end
            if not found then
                C_PartyInfo.InviteUnit(playerName)
            end
        end
    end

    C_Timer.After(1, function()
        if IsInGroup() and not IsInRaid() then
            ConvertToRaid()
            SetupManager:customPrint("Group converted to a raid.", "info")
        end

        if #failedInvites > 0 then
            print(table.concat(failedInvites, ", "))

            -- do this outside of function
            local guildInfo = SetupManager:getGuildInfo() or {}


            -- TODO: check how the fuck a "your party is full" error can return even though raid group has 15 spots left ????
            for _, failedName in ipairs(failedInvites) do
                -- Determine the main name: if failedName is an alt, get its main; else failedName
                local mainCharacter = fullCharList[failedName] or failedName
                local normalizedMain = SetupManager:normalize(mainCharacter)

                local mainInfo = guildInfo[normalizedMain]
                if mainInfo and mainInfo.online then
                    C_PartyInfo.InviteUnit(mainInfo.fullName)
                else
                    local altList = {}
                    for characterName, mappedMain in pairs(fullCharList) do
                        if SetupManager:normalize(mappedMain) == normalizedMain and SetupManager:normalize(characterName) ~= normalizedMain then
                            table.insert(altList, characterName)
                        end
                    end

                    if #altList > 0 then
                        local invitedAny = false
                        for _, altName in ipairs(altList) do
                            local altKey = SetupManager:normalize(altName)
                            local altInfo = guildInfo[altKey]
                            if altInfo and altInfo.online then
                                C_PartyInfo.InviteUnit(altInfo.fullName)
                                invitedAny = true
                                break
                            end
                        end
                        if not invitedAny then
                            SetupManager:customPrint("No alts of " .. failedName .. " found online.", "info")
                        end
                    end
                end
            end

            failedInvites = {}
        end
    end)
end

SetupManager.currentBoss = nil
function SetupManager:AssignPlayersToGroups(boss)
    local fullCharList = NSAPI and NSAPI:GetAllCharacters() or {}

    if not playersByBoss then
        SetupManager:customPrint("There have been no setups provided yet. Please copy sheet Input.", "err")
        return
    end

    if not playersByBoss[boss] then
        SetupManager:customPrint("No Setup for " .. boss, "err")
        return
    end
    -- DevTool:AddData({fullCharList, playersByBoss})
    SetupManager.currentBoss = boss  -- Store the current boss identifier
    local players = playersByBoss[boss]
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



    -- getRaidRosterInfo
    for i = 1, GetNumGroupMembers() do
        local unitName, _, subgroup = GetRaidRosterInfo(i)
        unitName = SetupManager:stripServer(unitName)

        -- nickname to mainCharacter -> alts after if needed
        if subgroup and type(subgroup) == "number" then
            raidMembers[unitName] = { index = i, group = subgroup }
            groupCounts[subgroup] = groupCounts[subgroup] + 1

            local nickName = fullCharList[unitName] or unitName
            -- Check if either the character or their main is in the setup
            local isInSetup = false



            for _, setupPlayer in ipairs(players) do


                -- here "Dogmá" fails
                --[[
                1. Monda
                2. Monda-Blackmoore

                1. Dogma
                2. Dogmá


                ]]--
                local setupPlayerWOServer = SetupManager:stripServer(setupPlayer)
                local currentlyParsedSetupPlayer = fullCharList[setupPlayerWOServer] or setupPlayer
                -- make check if no nicknames are provided to 1:1 parse setupPlayers to assignedPlayers
                if currentlyParsedSetupPlayer == nickName then
                    isInSetup = true
                    assignedPlayers[unitName] = i
                    break
                end
            end

            if not isInSetup then
                unassignedPlayers[unitName] = i
            end
        end
    end

    -- move unassignedPlayers to group 5-8
    for unitName, index in pairs(unassignedPlayers) do
        local currentGroup = raidMembers[unitName].group
        if currentGroup <= 4 then
            for newGroup = 5, totalGroups do
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

    -- place players in group 1-4 based on assignedPlayers( player, slot)
    for player, slot in pairs(assignedPlayers) do
        slot = tonumber(slot)
        local targetGroup = math.ceil(slot / maxGroupMembers)
        local targetSlot = slot % maxGroupMembers

        if targetSlot == 0 then
            targetSlot = maxGroupMembers
        end

        groupLayout[targetGroup][targetSlot] = player
    end

    -- move players to correct group and slot
    for group, slots in ipairs(groupLayout) do
        if group <= 4 then
            for slot, player in ipairs(slots) do
                if player then

                    local index = raidMembers[player].index + ( 5 * (raidMembers[player].group -1))
                    if index ~= assignedPlayers[player] then
                        SetRaidSubgroup(slot, group)
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

function SetupManager:ClearBosses()
    if playersByBoss then
        playersByBoss = nil
        BossGroupManagerSaved.playersByBoss = nil
        SetupManager:customPrint("Cleared all setups", "success")
    end
end

-- Function to reorder players within their groups based on slots
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

-- Register the READY_CHECK event
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("READY_CHECK")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "READY_CHECK" and IsInRaid() then
        -- SetupManager:ReorderPlayersWithinGroups()
    end
end)
