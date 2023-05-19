local QBCore = exports['qb-core']:GetCoreObject()

local startedrun = false
local candeliver = false
local curcoords = nil
local itemsdelivered = 0
local candropoff = false
local hasdropoff = false
local lastdelivery = 1

RegisterNetEvent("f-deliveryrun:client:alertcops", function()
	if Config.PDAlerts == "ps" then
		exports['ps-dispatch']:SuspiciousActivity() -- Project-SLoth qb-dispatch
	elseif Config.PDAlerts == "qb" then
		TriggerServerEvent('police:server:policeAlert', 'Suspicious Activity') -- Regular qbcore
	elseif Config.PDAlerts == "cd" then -- Code Design dispatch
		local data = exports['cd_dispatch']:GetPlayerInfo()
		TriggerServerEvent('cd_dispatch:AddNotification', {
			job_table = {'police'}, 
			coords = data.coords,
			title = '10-17 - Suspicious Person',
			message = 'A '..data.sex..' Was last seen doing suspicious activity at '..data.street, 
			flash = 0,
			unique_id = data.unique_id,
			sound = 1,
			blip = {
				sprite = 480, 
				scale = 0.8, 
				colour = 0,
				flashes = true, 
				text = '911 - Suspicious Person',
				time = 5,
				radius = 0,
			}
		})
	else
		print("Please change your Config.PDAlerts to match one of the dispatches scripts.")
	end
end)

local function transaction(deliveryped)
	exports['qb-target']:AddTargetEntity(deliveryped, {
		options = {
			{
				type = "client",
				event = "f-deliveryrun:client:check",
				icon = 'fas fa-capsules',
				label = 'Deliver ' ..Config.DeliveryItem,
				args = deliveryped,
			}
		},
		distance = 2.0
	})
end

local function deliveryblip()
	dropoffblip = AddBlipForCoord(dropoffcoords.x, dropoffcoords.y, dropoffcoords.z)
	SetBlipSprite(dropoffblip, 280)
	SetBlipScale(dropoffblip, 0.8)
	SetBlipDisplay(dropoffblip, 2)
	SetBlipColour(dropoffblip, 0)
	SetBlipRoute(dropoffblip, true)
end

local function deliveryped()
	local runped = Config.DropOffPeds[math.random(#Config.DropOffPeds)]
	RequestModel(runped)
	while not HasModelLoaded(runped) do 
		Wait(10) 
	end
	local dropoffped = CreatePed(0, runped, dropoffcoords.x, dropoffcoords.y, dropoffcoords.z-1.0, dropoffcoords.w, false, false)
	FreezeEntityPosition(dropoffped, true)
	SetEntityInvincible(dropoffped, true)
	SetBlockingOfNonTemporaryEvents(dropoffped, true)
	transaction(dropoffped)
end

local function DeleteDeliveryPed(pedhash)
	FreezeEntityPosition(pedhash, false)
	SetPedKeepTask(pedhash, false)
	TaskSetBlockingOfNonTemporaryEvents(pedhash, false)
	ClearPedTasks(pedhash)
	TaskWanderStandard(pedhash, 10.0, 10)
	SetPedAsNoLongerNeeded(pedhash)
	Wait(20000)
	DeletePed(pedhash)
end

local function fetchlocation()
	local curk = Config.DropOffLocation[math.random(#Config.DropOffLocation)]
	if curk ~= lastdelivery then 
		return curk
	else 
		return fetchlocation()
	end
end

local function CreateRun()
	if itemsdelivered == Config.MaxRuns then
		QBCore.Functions.Notify("You finished the Delivery Run", "success", 5000)
		itemsdelivered = 0
		startedrun = false
		candeliver = false
		candropoff = false
		hasdropoff = false
		TriggerServerEvent("f-deliveryrun:server:finishedrun")
		RemoveBlip(dropoffblip)
		DeleteDeliveryPed()
	else
		itemsdelivered = itemsdelivered + 1
		dropoffcoords = fetchlocation()
		lastdelivery = dropoffcoords
		deliveryblip()
		deliveryped()
		QBCore.Functions.Notify("Proceed to the next drop off location", "success", 5000)
	end
end

RegisterNetEvent("f-deliveryruns:client:StartDeliveryRun", function()
	if itemsdelivered <= Config.MaxRuns then
		candeliver = true
		if startedrun == true then
			candeliver = false
			QBCore.Functions.Notify("You have already started a run.", "error", 3000) 
		elseif startedrun == false then
			hasdropoff = false
			CreateRun()
			startedrun = true
		end
	end
end)

RegisterNetEvent("f-deliveryrun:client:check", function(data)
	local ped = PlayerPedId()
	if candeliver and IsPedOnFoot(ped) then
		if #(GetEntityCoords(ped) - GetEntityCoords(data.args)) < 5.0 then
			TaskTurnPedToFaceEntity(data.args, ped, 1.0)
			TaskTurnPedToFaceEntity(ped, data.args, 1.0)
			Wait(1500)
			PlayAmbientSpeech1(data.args, "Generic_Hi", "Speech_Params_Force")
			Wait(1000)

			RequestAnimDict("mp_safehouselost@")
			while not HasAnimDictLoaded("mp_safehouselost@") do Wait(10) end
			TaskPlayAnim(ped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
			Wait(3100)

			PlayAmbientSpeech1(data.args, "Chat_State", "Speech_Params_Force")
			Wait(500)
			RequestAnimDict("mp_safehouselost@")
			while not HasAnimDictLoaded("mp_safehouselost@") do Wait(10) end
			TaskPlayAnim(data.args, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
			Wait(3000)

			TriggerServerEvent("f-deliveryrun:server:reward")
			if math.random(0, 100) <= Config.CallCopsChance then
				TriggerEvent("f-deliveryrun:client:alertcops")
			end
			candeliver = false
			hasdropoff = false
			RemoveBlip(dropoffblip)
			QBCore.Functions.Notify("Wait for another delivery", "primary", 5000)
			startedrun = false
			DeleteDeliveryPed(data.args)
			Wait(Config.TBR)
			TriggerEvent("f-deliveryruns:client:StartDeliveryRun")
		end
	else
		QBCore.Functions.Notify("You already Delivered the "..Config.DeliveryItem.."", "error", 3000)
	end
end)

RegisterNetEvent("f-deliveryrun:client:spawnvehicle", function()
	local vehicle = Config.VehicleModel
	local coords = Config.VehicleSpawnLocation.xyzw

	QBCore.Functions.SpawnVehicle(vehicle, function(veh)
		SetVehicleNumberPlateText(veh, "RUN-"..tostring(math.random(1000, 9999)))
		SetEntityHeading(veh, coords.w)
		exports['LegacyFuel']:SetFuel(veh, 100.0)
		TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
	end, coords, true)
end)

CreateThread(function()
	-- Starter Ped
	local startped = Config.DeliveryRunPed
	RequestModel(startped)
	while not HasModelLoaded(startped) do 
		Wait(10) 
	end
	local runped = CreatePed(0, startped, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z-1.0, Config.StartLocation.w, false, false)
	TaskStartScenarioInPlace(runped, 'WORLD_HUMAN_CLIPBOARD', -1, true)
	FreezeEntityPosition(runped, true)
	SetEntityInvincible(runped, true)
	SetBlockingOfNonTemporaryEvents(runped, true)
	-- Target
	exports['qb-target']:AddTargetEntity(runped, {
		options = {
			{
				type = "server",
				event = "f-deliveryrun:server:StartRunPayment",
				icon = 'fas fa-capsules',
				label = 'Start Delivery Run ($'..Config.StartRunPayment..')',
			}
		},
		distance = 2.0
	})
end)
