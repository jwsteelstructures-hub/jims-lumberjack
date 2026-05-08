--========================================================--
--  JIMS LUMBERJACK - CLIENT TREE SYSTEM
--========================================================--

local chopping = false
local currentTree = nil
local hitCount = 0

-- Tracks all spawned tree objects so we can delete/replace them
local SpawnedTrees = {}

--========================================================--
--  CONFIG + TREE DATA (CLIENT-SIDE)
--========================================================--
Config = Config or {}
Config.Trees = {}   -- filled by server via updateTrees event

--========================================================--
--  RECEIVE TREE DATA FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:updateTrees", function(trees)
    Config.Trees = trees or {}
    Utils.Debug("Tree states updated. Received " .. tostring(#Config.Trees) .. " trees.")
end)

--========================================================--
--  PLAY CHOP ANIMATION
--========================================================--
local function PlayChopAnim()
    local ped = PlayerPedId()

    RequestAnimDict("mech_lumberjack@chop_wood")
    while not HasAnimDictLoaded("mech_lumberjack@chop_wood") do
        Wait(10)
    end

    TaskPlayAnim(ped, "mech_lumberjack@chop_wood", "chop_wood", 8.0, -8.0, 1500, 1, 0, false, 0, false)
end

--========================================================--
--  FIND NEAREST TREE
--========================================================--
local function GetNearestTree()
    local data = GetBusinessData()
    if not data or not data.trees then return nil end

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    for id, tree in pairs(data.trees) do
        local dist = Utils.Distance(pcoords, vector3(tree.x, tree.y, tree.z))
        if dist <= Config.InteractDistance then
            return id, tree
        end
    end

    return nil
end

--========================================================--
--  START CHOPPING
--========================================================--
local function StartChopping(treeId)
    if chopping then return end
    chopping = true
    hitCount = 0
    currentTree = treeId

    Utils.Debug("Started chopping tree: " .. tostring(treeId))

    CreateThread(function()
        while chopping do
            Wait(0)

            -- LEFT CLICK
            if IsControlJustPressed(0, 0x07CE1E61) then
                PlayChopAnim()
                hitCount = hitCount + 1

                if hitCount >= Config.TreeChopHits then
                    chopping = false
                    TriggerServerEvent("jims-lumberjack:treeChopped", currentTree)
                    currentTree = nil
                    return
                end
            end

            -- Cancel if player walks away
            local _, tree = GetNearestTree()
            if not tree then
                chopping = false
                currentTree = nil
                return
            end
        end
    end)
end

--========================================================--
--  MAIN INTERACTION LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        if not Permissions:HasAccess(GetLumberRank(), "Processing") then
            Wait(1000)
            goto continue
        end

        local treeId, tree = GetNearestTree()
        if treeId then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Chop Tree"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                StartChopping(treeId)
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)

--========================================================--
--  SPAWN TREES FROM JSON (PERSISTENT)
--========================================================--
CreateThread(function()
    TriggerServerEvent("jims-lumberjack:requestTrees")

    while not Config.Trees or next(Config.Trees) == nil do
        Wait(100)
    end

    Wait(500)

    for id, tree in pairs(Config.Trees) do
        local model = GetHashKey(tree.model)

        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end

        local obj = CreateObjectNoOffset(
            model,
            tree.x,
            tree.y,
            tree.z,
            false, false, false
        )

        SetEntityHeading(obj, tree.heading)
        FreezeEntityPosition(obj, true)

        SpawnedTrees[id] = obj
    end

    Utils.Debug("Spawned all persistent lumber trees.")
end)

--========================================================--
--  TREE FALL SEQUENCE (ANIMATED FALL + ALIGNMENT FIX)
--========================================================--
RegisterNetEvent("jims-lumberjack:treeFalling", function(treeId)
    local tree = Config.Trees[treeId]
    if not tree then return end

    -- Delete standing tree
    if SpawnedTrees[treeId] then
        DeleteObject(SpawnedTrees[treeId])
        SpawnedTrees[treeId] = nil
    end

    -- Determine fall models
    local startModel, endModel
    if tree.model == "treefall_flat_start" then
        startModel = "treefall_flat_start"
        endModel   = "treefall_flat_end"
    else
        startModel = "des_treefall_up15_start"
        endModel   = "des_treefall_up15_end"
    end

    -- Load start model
    local startHash = GetHashKey(startModel)
    RequestModel(startHash)
    while not HasModelLoaded(startHash) do Wait(10) end

    -- Forward vector
    local headingRad = math.rad(tree.heading)
    local forwardX = math.sin(headingRad)
    local forwardY = math.cos(headingRad)

    local fallDistance = 2.0

    -- Spawn falling-start model
    local obj = CreateObjectNoOffset(startHash, tree.x, tree.y, tree.z, false, false, false)
    SetEntityHeading(obj, tree.heading)
    FreezeEntityPosition(obj, false)

    -- Crack sound
    Citizen.InvokeNative(0xCCE219C922737BFA, "FALL_TREE_CRACK", tree.x, tree.y, tree.z, 0, 0, 0, true, 0)

    -- Camera shake
    local ped = PlayerPedId()
    if #(GetEntityCoords(ped) - vector3(tree.x, tree.y, tree.z)) < 25.0 then
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.3)
    end

    -- Animate fall
    local duration = 1200
    local steps = 30
    local waitPerStep = math.floor(duration / steps)
    local totalRotation = 80.0

    for i = 1, steps do
        local t = i / steps

        local curDist = fallDistance * t
        local newX = tree.x + forwardX * curDist
        local newY = tree.y + forwardY * curDist

        SetEntityCoordsNoOffset(obj, newX, newY, tree.z, false, false, false)

        local rotX = totalRotation * t
        SetEntityRotation(obj, rotX, 0.0, tree.heading, 2, true)

        Wait(waitPerStep)
    end

    -- Impact position
    local impactX = tree.x + forwardX * fallDistance
    local impactY = tree.y + forwardY * fallDistance

    -- Thud sound
    Citizen.InvokeNative(0xCCE219C922737BFA, "TREE_FALL_LAND", impactX, impactY, tree.z, 0, 0, 0, true, 0)

    -- Load end model
    local endHash = GetHashKey(endModel)
    RequestModel(endHash)
    while not HasModelLoaded(endHash) do Wait(10) end

    DeleteObject(obj)

    --========================================================--
    --  MODEL-SPECIFIC ALIGNMENT FIX
    --========================================================--
    local endOffsetX = 0.0
    local endOffsetY = 0.0

    if endModel == "treefall_flat_end" then
        endOffsetX = 0.3
        endOffsetY = -0.8
    elseif endModel == "des_treefall_up15_end" then
        endOffsetX = -0.2
        endOffsetY = -1.2
    end

    -- Rotate offsets into world space
    local finalX = impactX + forwardX * endOffsetY + forwardY * endOffsetX
    local finalY = impactY + forwardY * endOffsetY + forwardX * endOffsetX

    -- Spawn corrected fallen model
    local fallen = CreateObjectNoOffset(endHash, finalX, finalY, tree.z, false, false, false)
    SetEntityHeading(fallen, tree.heading)
    FreezeEntityPosition(fallen, true)

    Wait(5000)
    DeleteObject(fallen)
end)

--========================================================--
--  DEBUG: TEST FALL COMMAND
--========================================================--
RegisterCommand("testfall", function()
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    local nearestId
    for id, tree in pairs(Config.Trees) do
        local dist = #(pcoords - vector3(tree.x, tree.y, tree.z))
        if dist < 10.0 then
            nearestId = id
            break
        end
    end

    if not nearestId then
        Utils.Debug("No tree nearby to test fall.")
        return
    end

    TriggerEvent("jims-lumberjack:treeFalling", nearestId)
end)
