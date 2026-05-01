local workers = {}

local function SpawnWorker(pos)
    local model = `A_M_M_RANCHER_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(model, pos.x, pos.y, pos.z, 0.0, true, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    return ped
end

local function DoWorkerTasks(camp)
    local points = Config.Camps[camp].workerPoints

    workers[1] = SpawnWorker(points.taskA[1])
    workers[2] = SpawnWorker(points.taskA[2])

    TaskGoStraightToCoord(workers[1], points.taskA[1].x, points.taskA[1].y, points.taskA[1].z, 1.0, -1, 0.0, 0.0)
    TaskGoStraightToCoord(workers[2], points.taskA[2].x, points.taskA[2].y, points.taskA[2].z, 1.0, -1, 0.0, 0.0)

    Wait(30000)

    TaskStartScenarioInPlace(workers[1], "WORLD_HUMAN_HAMMER_WORKING", 0, true)
    TaskStartScenarioInPlace(workers[2], "WORLD_HUMAN_SAW_LOG", 0, true)

    Wait(30000)

    DeletePed(workers[1])
    DeletePed(workers[2])
end

RegisterNetEvent("construction:startFoundation", function(camp)
    TriggerEvent("construction:notify", "Please stand back while your foundation is built.")
    DoWorkerTasks(camp)
    TriggerServerEvent("construction:startPhase", camp, 1)
end)
