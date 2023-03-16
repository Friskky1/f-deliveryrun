local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("f-oxyrun:server:StartOxyPayment", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney('cash', Config.StartOxyPayment, "oxy start")
end)

RegisterNetEvent("f-oxyrun:server:reward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cashchance = math.random(1, 100)
    
    -- cash
    local cash = math.random(Config.CashAmount[1], Config.CashAmount[2])
    if Player then
        if cashchance <= Config.CashChance then
            if Player.Functions.AddMoney("cash", cash, "oxy money") then
                TriggerClientEvent("f-oxyrun:client:alertcops", src)
                TriggerClientEvent('QBCore:Notify', src, "You got $"..cash.."", "primary", 10000)
            end
        else
            if Player.Functions.AddItem(Config.OxyItem, Config.OxyAmount) then
                TriggerClientEvent("f-oxyrun:client:alertcops", src)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.OxyItem], "add", Config.OxyAmount)
                TriggerClientEvent('QBCore:Notify', src, "You did not get any cash. But you got "..Config.OxyAmount.." Oxy instead", "primary", 10000)
            end
        end
    end
end)