local QBCore = exports['qb-core']:GetCoreObject()
local oxyvehicle = nil
local startedrun = false

RegisterNetEvent("f-oxyrun:server:StartOxyPayment", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if startedrun == false then
        TriggerClientEvent("f-oxyruns:client:StartOxy", src)
        Player.Functions.RemoveMoney('cash', Config.StartOxyPayment, "Oxy Start")
        startedrun = true
    elseif startedrun == true then
        TriggerClientEvent('QBCore:Notify', src, "You have already started a run.", "error", 5000)
    end
    if Config.SpawnOxyVehicle == true then
        if oxyvehicle == nil then
            TriggerClientEvent("f-oxyrun:client:spawnoxyvehicle", src)
            oxyvehicle = true
        elseif oxyvehicle == true then 
            return 
        end
    end
end)

RegisterNetEvent("f-oxyrun:server:finishedrun", function()
    startedrun = false
    oxyvehicle = nil
end)

RegisterNetEvent("f-oxyrun:server:reward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cashchance = math.random(1, 100)
    local rareitem = math.random(100)

    local cash = math.random(Config.CashAmount[1], Config.CashAmount[2])
    if Player then
        if cashchance <= Config.CashChance then
            if Player.Functions.AddMoney("cash", cash, "Oxy Money") then
                TriggerClientEvent('QBCore:Notify', src, "You got $"..cash.."", "success", 5000)
            end
        else
            if Player.Functions.AddItem(Config.OxyItem, Config.OxyAmount) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.OxyItem], "add", Config.OxyAmount)
                TriggerClientEvent('QBCore:Notify', src, "You did not get any cash. But you got "..Config.OxyAmount.." Oxy instead", "primary", 5000)
            end
        end
        if rareitem <= Config.RareItemChance then
            Player.Functions.AddItem(Config.RareItem, Config.RareItemAmmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem], "add", Config.RareItemAmmount)
            TriggerClientEvent('QBCore:Notify', src, "You also got a Random item?", "primary", 5000)
        end
    end
end)