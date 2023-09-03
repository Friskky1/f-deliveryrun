local QBCore = exports['qb-core']:GetCoreObject()

local startedrun = false
local candeliver = false
local curcoords = nil
local itemsdelivered = 0
local candropoff = false
local hasdropoff = false
local lastdelivery = 1
local vehspawned = false

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

RegisterCommand("enddeliveryrun", function()
	itemsdelivered = 0
	startedrun = false
	candeliver = false
	candropoff = false
	hasdropoff = false
	TriggerServerEvent("f-deliveryrun:server:finishedrun")
	QBCore.Functions.Notify("You ended the deliveryrun", "success", 5000)
	RemoveBlip(dropoffblip)
	DeleteDeliveryPed()
end)

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
			Wait(Config.TBR * 1000)
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
		TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
		exports[Config.Fuel]:SetFuel(veh, 100.0)
	end, coords, true)
	vehspawned = true
end)

RegisterNetEvent("f-deliveryrun:client:deletevehicle", function()
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
	if vehspawned == true then
		if veh ~= 0 then
			QBCore.Functions.DeleteVehicle(veh)
		else
			local pcoords = GetEntityCoords(ped)
			local vehicles = GetGamePool('CVehicle')
			for k, v in pairs(vehicles) do
				if #(pcoords - GetVehiclePedIsUsing(ped, v)) <= 10.0 and IsPedInVehicle(ped, veh, false) then
					QBCore.Functions.DeleteVehicle(v)
					vehspawned = false
				else
					return
				end
			end
		end
	else
		QBCore.Functions.Notify("The delivery run vehicle is not spawned so you cant get the return reward", "error", 5000)
	end
	if Config.VehicleReturnReward == true and vehspawned == true then 
		TriggerServerEvent("f-deliveryrun:server:vehiclereturnreward")
	end
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

	if Config.StartBlip.Blip == true then
		StartBlip = AddBlipForCoord(Config.StartLocation.xyz)
		SetBlipSprite(StartBlip, Config.StartBlip.Sprite)
		SetBlipScale(StartBlip, Config.StartBlip.Scale)
		SetBlipDisplay(StartBlip, Config.StartBlip.Display)
		SetBlipColour(StartBlip, Config.StartBlip.Colour)
		SetBlipAsShortRange(StartBlip, true)
		AddTextEntry('StartBlip', Config.StartBlip.BlipText)
		BeginTextCommandSetBlipName('StartBlip')
		EndTextCommandSetBlipName(StartBlip)
	end
end)

if Config.SpawnStartVehicle == true then
	CreateThread(function()
		-- Delete Vehicle ped
		local delvehped = Config.DelVehiclePed
		RequestModel(delvehped)
		while not HasModelLoaded(delvehped) do 
			Wait(10) 
		end
		local vehp = CreatePed(0, delvehped, Config.DelVehPedLocation.x, Config.DelVehPedLocation.y, Config.DelVehPedLocation.z-1.0, Config.DelVehPedLocation.w, false, false)
		TaskStartScenarioInPlace(vehp, 'WORLD_HUMAN_CLIPBOARD', -1, true)
		FreezeEntityPosition(vehp, true)
		SetEntityInvincible(vehp, true)
		SetBlockingOfNonTemporaryEvents(vehp, true)
		-- Target
		exports['qb-target']:AddTargetEntity(vehp, {
			options = {
				{
					type = "client",
					event = "f-deliveryrun:client:deletevehicle",
					icon = 'fas fa-capsules',
					label = 'Delete Delivery Run Vehicle',
				}
			},
			distance = 5.0
		})
	end)
end