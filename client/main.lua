local QBCore = exports['qb-core']:GetCoreObject()

local startedrun = false
local candeliver = false
local curcoords = nil

RegisterNetEvent("f-oxyrun:client:alertcops", function()
	if Config.PDAlerts == "ps" then
		exports['qb-dispatch']:DrugSale() -- Project-SLoth qb-dispatch
	elseif Config.PDAlerts == "qb" then
		TriggerServerEvent('police:server:policeAlert', 'Suspicious Hand-off') -- Regular qbcore
	else
		print("Please change your Config.PDAlerts to match one of the dispatches.")
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
	SetBlipSprite(dropoffblip, 1)
	SetBlipScale(dropoffblip, 0.8)
	SetBlipDisplay(dropoffblip, 2)
	SetBlipColour(dropoffblip, 28)
	SetBlipRoute(dropoffblip, true)
end

local function oxydeliveryped()
	local ped = Config.DropOffPed
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

RegisterNetEvent("f-oxyrun:client:check", function(data)
	if candeliver then
		TriggerServerEvent("f-oxyrun:server:reward")
		candeliver = false
		RemoveBlip(dropoffblip)
		DeleteOxyPed(data.args)
	else
		QBCore.Functions.Notify("You already Delivered the Oxy", "error", 3000)
	end
end)


RegisterNetEvent("f-oxyruns:client:StartOxy", function()
	candeliver = true
	if startedrun then
		QBCore.Functions.Notify("You have already started a run.", "error", 3000) return
	end
	dropoffcoords = Config.DropOffLocation[math.random(#Config.DropOffLocation)]
	TriggerServerEvent("f-oxyrun:server:StartOxyPayment")
	oxydeliverblip()
	oxydeliveryped()
	startedrun = true
	return true
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
				type = "client",
				event = "f-oxyruns:client:StartOxy",
				icon = 'fas fa-capsules',
				label = 'Start Oxyrun ($'..Config.StartOxyPayment..')',
			}
		},
		distance = 2.0
	})
end)
