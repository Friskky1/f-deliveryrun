local QBCore = exports['qb-core']:GetCoreObject()

local startedrun = false
local candeliver = false
local curcoords = nil
local oxydelivered = 0
local candropoff = false
local hasdropoff = false
local lastdelivery = 1

RegisterNetEvent("f-oxyrun:client:alertcops", function()
	if Config.PDAlerts == "ps" then
		exports['qb-dispatch']:DrugSale() -- Project-SLoth qb-dispatch
	elseif Config.PDAlerts == "qb" then
		TriggerServerEvent('police:server:policeAlert', 'Suspicious Hand-off') -- Regular qbcore
	else
		print("Please change your Config.PDAlerts to match one of the dispatches scripts.")
	end
end)

local function transaction(deliveryped)
	exports['qb-target']:AddTargetEntity(deliveryped, {
		options = {
			{
				type = "client",
				event = "f-oxyrun:client:check",
				icon = 'fas fa-capsules',
				label = 'Deliver Oxy',
				args = deliveryped,
			}
		},
		distance = 2.0
	})
end

local function oxydeliverblip()
	dropoffblip = AddBlipForCoord(dropoffcoords.x, dropoffcoords.y, dropoffcoords.z)
	SetBlipSprite(dropoffblip, 51)
	SetBlipScale(dropoffblip, 0.8)
	SetBlipDisplay(dropoffblip, 2)
	SetBlipColour(dropoffblip, 0)
	SetBlipRoute(dropoffblip, true)
end

local function oxydeliveryped()
	local ped = Config.DropOffPeds[math.random(#Config.DropOffPeds)]
	RequestModel(ped)
	while not HasModelLoaded(ped) do 
		Wait(10) 
	end
	local dropoffped = CreatePed(0, ped, dropoffcoords.x, dropoffcoords.y, dropoffcoords.z-1.0, dropoffcoords.w, false, false)
	FreezeEntityPosition(dropoffped, true)
	SetEntityInvincible(dropoffped, true)
	SetBlockingOfNonTemporaryEvents(dropoffped, true)
	transaction(dropoffped)
end

local function DeleteOxyPed(pedhash)
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
	if oxydelivered == Config.MaxRuns then
		QBCore.Functions.Notify("You finished the OxyRun", "success", 5000)
		oxydelivered = 0
		startedrun = false
		candeliver = false
		candropoff = false
		hasdropoff = false
		RemoveBlip(dropoffblip)
		DeleteOxyPed()
	else
		oxydelivered = oxydelivered + 1
		dropoffcoords = fetchlocation()
		lastdelivery = dropoffcoords
		oxydeliverblip()
		oxydeliveryped()
		QBCore.Functions.Notify("Proceed to the next drop off location", "success", 5000)
	end
end

RegisterNetEvent("f-oxyruns:client:StartOxy", function()
	if oxydelivered <= Config.MaxRuns then
		candeliver = true
		if startedrun then
			QBCore.Functions.Notify("You have already started a run.", "error", 3000) 
		end
		hasdropoff = true
		CreateRun()
		startedrun = true
	end
end)

RegisterNetEvent("f-oxyrun:client:check", function(data)
	if candeliver then
		TriggerServerEvent("f-oxyrun:server:reward")
		if math.random(0, 100) <= Config.CallCopsChance then
			TriggerEvent("f-oxyrun:client:alertcops")
		end
		candeliver = false
		hasdropoff = false
		RemoveBlip(dropoffblip)
		QBCore.Functions.Notify("Wait for another delivery", "primary", 5000)
		startedrun = false
		DeleteOxyPed(data.args)
		Wait(Config.TBR)
		TriggerEvent("f-oxyruns:client:StartOxy")
	else
		QBCore.Functions.Notify("You already Delivered the Oxy", "error", 3000)
	end
end)

CreateThread(function()
	-- Starter Ped
	local startped = Config.OxyPed
	RequestModel(startped)
	while not HasModelLoaded(startped) do 
		Wait(10) 
	end
	local oxyped = CreatePed(0, startped, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z-1.0, Config.StartLocation.w, false, false)
	TaskStartScenarioInPlace(oxyped, 'WORLD_HUMAN_CLIPBOARD', -1, true)
	FreezeEntityPosition(oxyped, true)
	SetEntityInvincible(oxyped, true)
	SetBlockingOfNonTemporaryEvents(oxyped, true)
	-- Target
	exports['qb-target']:AddTargetEntity(oxyped, {
		options = {
			{
				type = "server",
				event = "f-oxyrun:server:StartOxyPayment",
				icon = 'fas fa-capsules',
				label = 'Start Oxyrun ($'..Config.StartOxyPayment..')',
			}
		},
		distance = 2.0
	})
end)