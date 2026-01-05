RegisterNetEvent('bodycam:requestPlayers')
AddEventHandler('bodycam:requestPlayers', function()
    local src = source
    local players = {}
    
    for _, playerId in ipairs(GetPlayers()) do
        local name = GetPlayerName(playerId)
        -- اگر از فریم‌ورک ESX یا QB استفاده می‌کنید می‌توانید جاب را هم اینجا بگیرید
        table.insert(players, {
            id = tonumber(playerId),
            name = name,
            job = "Citizen" -- می‌توانید این را داینامیک کنید
        })
    end
    
    TriggerClientEvent('bodycam:receivePlayers', src, players)
end)
