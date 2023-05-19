local QBCore = exports['qb-core']:GetCoreObject()
local vehicle = nil
local startedrun = false

RegisterNetEvent("f-deliveryrun:server:StartRunPayment", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if startedrun == false then
        TriggerClientEvent("f-deliveryruns:client:StartDeliveryRun", src)
        Player.Functions.RemoveMoney('cash', Config.StartRunPayment, "Delivery Run Start")
        startedrun = true
    elseif startedrun == true then
        TriggerClientEvent('QBCore:Notify', src, "You have already started a run.", "error", 5000)
    end
    if Config.SpawnStartVehicle == true then
        if vehicle == nil then
            TriggerClientEvent("f-deliveryrun:client:spawnvehicle", src)
            vehicle = true
        elseif vehicle == true then 
            return 
        end
    end
end)

RegisterNetEvent("f-deliveryrun:server:finishedrun", function()
    startedrun = false
    vehicle = nil
end)

RegisterNetEvent("f-deliveryrun:server:reward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cashchance = math.random(1, 100)
    local rareitem = math.random(100)

    local cash = math.random(Config.CashAmount[1], Config.CashAmount[2])
    if Player then
        if cashchance <= Config.CashChance then
            if Player.Functions.AddMoney("cash", cash, "Delivery Run Money") then
                TriggerClientEvent('QBCore:Notify', src, "You got $"..cash.."", "success", 5000)
            end
        else
            if Player.Functions.AddItem(Config.DeliveryItem, Config.ItemReturnAmount) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.DeliveryItem], "add", Config.ItemReturnAmount)
                TriggerClientEvent('QBCore:Notify', src, "You did not get any cash. But you got "..Config.ItemReturnAmount.." "..Config.DeliveryItem.. " instead", "primary", 5000)
            end
        end
        if rareitem <= Config.RareItemChance then
            Player.Functions.AddItem(Config.RareItem, Config.RareItemAmmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem], "add", Config.RareItemAmmount)
            TriggerClientEvent('QBCore:Notify', src, "You also got a Random item?", "primary", 5000)
        end
    end
end)