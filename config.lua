Config = {}

Config.OxyPed = "g_m_m_chemwork_01"
Config.StartLocation = vector4(238.48, -27.92, 69.9, 72.99) -- Starting ped location for oxy run
Config.StartOxyPayment = 100 -- How much you pay to start the run

Config.DropOffPeds = {
    "a_m_y_busicas_01",
    "a_m_m_hillbilly_02",
    "a_m_m_tramp_01",
    "a_m_y_breakdance_01",
    "a_f_y_juggalo_01",
    "a_f_o_salton_01",
}

Config.CashAmount = {300, 500}
Config.CashChance = 40

Config.OxyItem = "oxy"
Config.OxyAmount = math.random(1, 3)
Config.MaxRuns = math.random(5, 10)
Config.TBR = math.random(5000, 15000) -- Time between each run in milliseconds

Config.DropOffLocation = {
    vector4(272.1, 196.37, 104.73, 159.75),
    vector4(-143.54, 229.46, 94.93, 2.88),
    vector4(-132.23, -118.49, 56.55, 341.28),
    vector4(98.33, -225.67, 54.64, 339.84),
    vector4(-90.06, -905.86, 29.59, 159.71),
    vector4(-270.55, -977.02, 31.22, 162.47),
}

Config.PDAlerts = "qb" -- qb, ps and cd
Config.CallCopsChance = math.random(30, 50)