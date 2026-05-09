--========================================================--
--  JIMS LUMBERJACK - CLIENT TREE SYSTEM
--========================================================--

local chopping = false
local currentTree = nil
local hitCount = 0

local SpawnedTrees = {}
local StumpEntities = {} -- NEW: per-tree stump anchors

Config = Config or {}
Config.Trees = {}

local STUMP_MODEL = `p_bottle001x`
local STUMP_Z_OFFSET = 0.20 -- sinks 4–8 inches like your trees

--========================================================--
--  INTERNAL HELPERS
--========================================================--
local function LoadModel(hash)
    if not IsModelValid(hash) then return false end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then return false end
        Wait(10)
    end
    return true
end

local function SpawnStump(treeId, tree)
    if StumpEntities[treeId] and DoesEntityExist(StumpEntities[treeId]) then
        return
    end

    if not LoadModel(STUMP_MODEL) then return end

    local stump = CreateObjectNoOffset(
        STUMP_MODEL,
        tree.x,
        tree.y,
        tree.z - STUMP_Z_OFFSET,
        false, false, false
    )

    SetEntityHeading(stump, tree.heading or 0.0)
    SetEntityAlpha(stump, 0, false)
    SetEntityCollision(stump, false, false)
    SetEntityScale(stump, 0.01)

    StumpEntities[treeId] = stump
end

local function DeleteStump(treeId)
    local stump = StumpEntities[treeId]
    if stump and DoesEntityExist(stump) then
        DeleteObject(stump)
    end
    StumpEntities[treeId] = nil
end

local function SpawnStandingTree(treeId, tree)
    if SpawnedTrees[treeId] and DoesEntityExist(SpawnedTrees[treeId]) then
        return
    end

    local model = GetHashKey(tree.model)
    if not LoadModel(model) then return end

    local obj = CreateObjectNoOffset(model, tree.x, tree.y, tree.z, false, false, false)
    SetEntityHeading(obj, tree.heading)
    FreezeEntityPosition(obj, true)

    SpawnedTrees[treeId] = obj
end

local function DeleteStandingTree(treeId)
    local obj = SpawnedTrees[treeId]
    if obj and DoesEntityExist(obj) then
        DeleteObject(obj)
    end
    SpawnedTrees[treeId] = nil
end

local function RefreshTreeVisual(treeId, tree)
    -- ready  -> standing tree, no stump
    -- cooldown -> stump only
    if tree.state == "ready" then
        DeleteStump(treeId)
        SpawnStandingTree(treeId, tree)
    else
        DeleteStandingTree(treeId)
        SpawnStump(treeId, tree)
    end
end

--========================================================--
--  RECEIVE TREE DATA
--========================================================--
RegisterNetEvent("jims-lumberjack:updateTrees", function(trees)
    Config.Trees = trees or {}
    Utils.Debug("Tree states updated. Received " .. tostring(#Config.Trees) .. " trees.")

    -- Refresh visuals for all trees on update
    for id, tree in pairs(Config.Trees) do
        RefreshTreeVisual(id, tree)
    end
end)

--========================================================--
--  CHOP ANIMATION
--========================================================--
local function PlayChopAnim()
    local ped = PlayerPedId()

    RequestAnimDict("mech_lumberjack@chop_wood")
    while not HasAnimDictLoaded("mech_lumberjack@chop_wood") do Wait(10) end

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
        if Utils.Distance(pcoords, vector3(tree.x, tree.y, tree.z)) <= Config.InteractDistance then
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

    CreateThread(function()
        while chopping do
            Wait(0)

            if IsControlJustPressed(0, 0x07CE1E61) then
                PlayChopAnim()
                hitCount += 1

                if hitCount >= Config.TreeChopHits then
                    chopping = false
                    TriggerServerEvent("jims-lumberjack:treeChopped", currentTree)
                    currentTree = nil
                    return
                end
            end

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
--  MAIN LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        if not Permissions:HasAccess(GetLumberRank(), "Processing") then
            Wait(1000)
            goto continue
        end

        local treeId, tree = GetNearestTree()
        if treeId and tree.state == "ready" then
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Chop Tree"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then
                StartChopping(treeId)
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)

--========================================================--
--  INITIAL SPAWN TREES
--========================================================--
CreateThread(function()
    TriggerServerEvent("jims-lumberjack:requestTrees")

    while not Config.Trees or next(Config.Trees) == nil do Wait(100) end
    Wait(500)

    for id, tree in pairs(Config.Trees) do
        RefreshTreeVisual(id, tree)
    end
end)

--========================================================--
--  TREE FALL SEQUENCE (REALISTIC + STUMP PIN)
--========================================================--
RegisterNetEvent("jims-lumberjack:treeFalling", function(treeId)
    local tree = Config.Trees[treeId]
    if not tree then return end

    -- Delete standing tree, ensure stump exists
    DeleteStandingTree(treeId)
    SpawnStump(treeId, tree)

    local startModel, endModel
    if tree.model == "treefall_flat_start" then
        startModel = "treefall_flat_start"
        endModel   = "treefall_flat_end"
    else
        startModel = "des_treefall_up15_start"
        endModel   = "des_treefall_up15_end"
    end

    local startHash = GetHashKey(startModel)
    if not LoadModel(startHash) then return end

    local headingRad = math.rad(tree.heading)
    local forwardX = math.sin(headingRad)
    local forwardY = math.cos(headingRad)

    local fallDistance = 2.0

    -- Spawn falling-start model
    local obj = CreateObjectNoOffset(startHash, tree.x, tree.y, tree.z, false, false, false)
    SetEntityHeading(obj, tree.heading)
    FreezeEntityPosition(obj, false)

    -- Slight pre‑fall wobble (subtle)
    for i = 1, 10 do
        local wobble = math.sin(i * 0.3) * 1.2
        SetEntityRotation(obj, wobble, 0.0, tree.heading, 2, true)
        Wait(15)
    end

    -- Delayed crack (feels weighty)
    Citizen.InvokeNative(0xCCE219C922737BFA, "FALL_TREE_CRACK", tree.x, tree.y, tree.z, 0,0,0,true,0)
    Wait(150)

    -- Smooth fall
    local duration = 1400
    local steps = 110
    local waitPerStep = math.floor(duration / steps)
    local totalRotation = 88.0

    for i = 1, steps do
        local t = (i / steps) ^ 1.6

        local curDist = fallDistance * t
        local newX = tree.x + forwardX * curDist
        local newY = tree.y + forwardY * curDist

        SetEntityCoordsNoOffset(obj, newX, newY, tree.z, false, false, false)

        local rotX = totalRotation * t
        SetEntityRotation(obj, rotX, 0.0, tree.heading, 2, true)

        Wait(waitPerStep)
    end

    -- Impact
    local impactX = tree.x + forwardX * fallDistance
    local impactY = tree.y + forwardY * fallDistance

    Citizen.InvokeNative(0xCCE219C922737BFA, "TREE_FALL_LAND", impactX, impactY, tree.z, 0,0,0,true,0)

    -- Load end model
    local endHash = GetHashKey(endModel)
    if not LoadModel(endHash) then
        DeleteObject(obj)
        return
    end

    DeleteObject(obj)

    -- Alignment tuning (your values)
    local endOffsetX = -0.8
    local endOffsetY = -0.8

    if endModel == "des_treefall_up15_end" then
        endOffsetX = -0.8
        endOffsetY = -1.2
    end

    local finalX = impactX + forwardX * endOffsetY + forwardY * endOffsetX
    local finalY = impactY + forwardY * endOffsetY + forwardX * endOffsetX

    local fallen = CreateObjectNoOffset(endHash, finalX, finalY, tree.z, false, false, false)
    SetEntityHeading(fallen, tree.heading)
    FreezeEntityPosition(fallen, true)

    -- NOTE: we do NOT delete the stump here.
    -- Stump stays until server flips state back to "ready" and updateTrees refreshes visuals.

    -- Optional: if you want the fallen trunk to vanish after some time:
    Wait(5000)
    DeleteObject(fallen)
end)

--========================================================--
--  DEBUG COMMAND
--========================================================--
RegisterCommand("testfall", function()
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    local nearestId
    for id, tree in pairs(Config.Trees) do
        if #(pcoords - vector3(tree.x, tree.y, tree.z)) < 10.0 then
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
