MenuData = {}
TriggerEvent("redemrp_menu_base:getData",function(call)
    MenuData = call
end)

local active = false
local ShopPrompt
local hasAlreadyEnteredMarker, lastZone
local currentZone = nil

-- Config --
local blips = {
    --Valentine
	{ name = 'Coach Dealer', sprite = -992598136, x = -365.9, y = 797.27, z = 116.23 },
}


-- Leave --
Citizen.CreateThread(function()
	for _, info in pairs(blips) do
        local blip = N_0x554d9d53f696d002(1664425300, info.x, info.y, info.z)
        SetBlipSprite(blip, info.sprite, 1)
		SetBlipScale(blip, 0.2)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, info.name)
    end  
end)





function SetupShopPrompt()
    Citizen.CreateThread(function()
        local str = 'Rent A Coach'
        ShopPrompt = PromptRegisterBegin()
        PromptSetControlAction(ShopPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(ShopPrompt, str)
        PromptSetEnabled(ShopPrompt, false)
        PromptSetVisible(ShopPrompt, false)
        PromptSetHoldMode(ShopPrompt, true)
        PromptRegisterEnd(ShopPrompt)

    end)
end

AddEventHandler('diack_coachdealer:hasEnteredMarker', function(zone)
    currentZone = zone
end)

AddEventHandler('diack_coachdealer:hasExitedMarker', function(zone)
    if active == true then
        PromptSetEnabled(ShopPrompt, false)
        PromptSetVisible(ShopPrompt, false)
        active = false
    end
	currentZone = nil
end)

Citizen.CreateThread(function()
    SetupShopPrompt()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local isInMarker, currentZone = false

        for k,v in ipairs(blips) do
            if (Vdist(coords.x, coords.y, coords.z, v.x, v.y, v.z) < 1.5) then
                isInMarker  = true
                currentZone = 'blips'
                lastZone    = 'blips'
            end
        end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			TriggerEvent('diack_coachdealer:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('diack_coachdealer:hasExitedMarker', lastZone)
		end

    end
end)



Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        if currentZone then
            if active == false then
                PromptSetEnabled(ShopPrompt, true)
                PromptSetVisible(ShopPrompt, true)
                active = true
            end
            if PromptHasHoldModeCompleted(ShopPrompt) then
                ShopMenu()
                --takeMoney(price)                 
                PromptSetEnabled(ShopPrompt, false)
                PromptSetVisible(ShopPrompt, false)
                active = false

				currentZone = nil
			end
        else
			Citizen.Wait(500)
		end
	end
end)

function ShopMenu()
    MenuData.CloseAll()
    local elements = {
            {label = "Hunting Wagons", value = 'hunt'},
            {label = "Small Wagons", value = 'small'},
            {label = "Large Wagons", value = 'large'},
            {label = "Special Wagons", value = 'spec'},
    }
    MenuData.Open('default', GetCurrentResourceName(), 'coachdealer_main', {
        title    = 'Rent A Wagon',
        subtext    = 'Choose a category',
        align    = 'center',
        elements = elements,
    }, function(data, menu)
        local elements2 = {}
        local OpenSub = false
        local category = data.current.value
        if category == 'hunt' then
            elements2 = {
                {label = "Small Hunting Wagon", value = "hunt_small1", car = "CART07", price = 10},
                {label = "Large Hunting Wagon", value = "hunt_small2", car = "CART06", price = 10},
            }
            OpenSub = true
        elseif category == 'small' then
            elements2 = {
                {label = "Buggy 1", value = 'wagon_small1', car = 'BUGGY01', price = 20},
                {label = "Buggy 2", value = 'wagon_small1', car = 'BUGGY02', price = 20},
                {label = "Buggy 3", value = 'wagon_small3', car = 'BUGGY03', price = 20},

            }
            OpenSub = true
        elseif category == 'large' then
            elements2 = {
                {label = "Chuck Wagon", value = 'wagon_large1', car = 'CHUCKWAGON000X', price = 2},
                {label = "Chuck Wagon 2", value = 'wagon_large2', car = 'CHUCKWAGON002X', price = 2},
                {label = "4 Horse Coach", value = 'wagon_large3', car = 'COACH2', price = 2},
                {label = "2 Horse Coach", value = 'wagon_large4', car = 'COACH3', price = 2},
                {label = "1 Horse Coach", value = 'wagon_large5', car = 'COACH4', price = 2},
                {label = "Open Top Coach", value = 'wagon_large6', car = 'COAC6', price = 2},
                {label = "Transport Wagon", value = 'wagon_large7', car = 'WAGON02X', price = 2},
                {label = "Transport Wagon Clost Top", value = 'wagon_large8', car = 'WAGON04X', price = 2},

            }
            OpenSub = true

        elseif category == 'spec' then
            elements2 = {
                {label = "Small Oil Wagon", value = 'wagon_spec1', car = 'CART05', price = 2},
                {label = "Large Oil Wagon", value = 'wagon_spec2', car = 'OILWAGON01X', price = 2},
                {label = "Army Supply Wagon", value = 'wagon_spec3', car = 'ARMYSUPPLYWAGON', price = 2},
                {label = "Coal Wagon", value = 'wagon_spec4', car = 'coal_wagon', price = 2},
                {label = "Log Wagon", value = 'wagon_spec5', car = 'LOGWAGON', price = 2},
                {label = "Gatling Gun Wagon", value = 'wagon_spec6', car = 'GATCHUCK_2', price = 1000},
                {label = "Circus Wagon", value = 'wagon_spec7', car = 'wagonCircus01x', price = 1000},
                {label = "Dairy Wagon", value = 'wagon_spec8', car = 'wagonDairy01x', price = 1000},

            }
            OpenSub = true
        end

        if OpenSub == true then
            OpenSub = false
            MenuData.Open('default', GetCurrentResourceName(), 'coachdealer_'..category, {
                title    = category..' Shop',
                align    = 'center',
                elements = elements2,
            }, 
            function(data2, menu2)
                local car = data2.current.car
                local item = data2.current.value
                local price = data2.current.price
                TriggerServerEvent("diack_coachdealer:rentwagon", price, car, item)
            end, 
            function(data2, menu2)
                menu2.close()
            end) 
        end
    end, 
    function(data, menu)
        menu.close()
    end) 
end

RegisterNetEvent('diack_coachdealer:spawnCar')
AddEventHandler('diack_coachdealer:spawnCar', function(car)
    local car = GetHashKey(car)
    
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
    local vehicle = CreateVehicle(car, x + 2, y + 6, z + 1, 90.0, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
end)

--function takeMoney(price)
--    TriggerServerEvent("diack_coachdealer:rentwagon", price)   
--end
