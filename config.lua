Config = {}

Config.DeliveryRunPed = "g_m_m_chemwork_01" -- starting delivery run ped 
Config.StartLocation = vector4(238.48, -27.92, 69.9, 72.99) -- Starting ped location for the delivery run
Config.StartRunPayment = 100 -- How much you pay to start the run

Config.SpawnStartVehicle = true -- Set to true if you want a vehicle to spawn once the delivery run has started
Config.VehicleModel = "burrito3"
Config.VehicleSpawnLocation = vector4(228.42, -30.72, 69.72, 158.6)

Config.DropOffPeds = { -- the peds that you see when you deliver the items
    "a_m_y_busicas_01",
    "a_m_m_hillbilly_02",
    "a_m_m_tramp_01",
    "a_m_y_breakdance_01",
    "a_f_y_juggalo_01",
    "a_f_o_salton_01",
}

Config.CashAmount = {200, 350} -- amount of cash you will in between thoese values
Config.CashChance = 40 -- % chance to get cash

Config.RareItemChance = math.random(1, 3) -- % chance to get the rare item
Config.RareItemAmmount = 1
Config.RareItem = 'security_card_01'

Config.DeliveryItem = "oxy"
Config.ItemReturnAmount = math.random(1, 3) -- the amount of items returned
Config.MaxRuns = math.random(5, 10) -- random amount of runs before you complete the run
Config.TBR = math.random(5000, 15000) -- Time between each run in milliseconds

Config.DropOffLocation = {
    vector4(272.1, 196.37, 104.73, 159.75),
    vector4(-143.54, 229.46, 94.93, 2.88),
    vector4(-132.23, -118.49, 56.55, 341.28),
    vector4(98.33, -225.67, 54.64, 339.84),
    vector4(-90.06, -905.86, 29.59, 159.71),
    vector4(-270.55, -977.02, 31.22, 162.47),
}

Config.PDAlerts = "qb" -- qb, ps and cd (Configure to your dispatch system)
Config.CallCopsChance = math.random(30, 50) -- 30 to 50% chance to call the cops