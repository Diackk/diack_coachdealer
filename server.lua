RegisterServerEvent('diack_coachdealer:rentwagon')
AddEventHandler("diack_coachdealer:rentwagon", function(price, car, item)
local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        if user.getMoney() >= price then
            print(car)
            TriggerClientEvent("diack_coachdealer:spawnCar", _source, car)
            user.removeMoney(price)
            TriggerClientEvent('redem_roleplay:Tip', _source, "You have (~e~rented~q~) a wagon for $" .. price, 4000)  
        elseif user.getMoney() < price then
            TriggerClientEvent('redem_roleplay:Tip', _source, "You (~e~dont~q~) have enough money, this costs $" .. price, 4000)
        end
    end)
end)


