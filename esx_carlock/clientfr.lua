ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 303) then
            local coords = GetEntityCoords(PlayerPedId())
            local hasAlreadyLocked = false
            local cars = ESX.Game.GetVehiclesInArea(coords, 30)
            local carstrie = {}
            local cars_dist = {}        
            local notowned = 0
            if #cars == 0 then
                ESX.ShowNotification("No hay ningún vehículo que te pertenezca cerca.")
            else
                for j=1, #cars, 1 do
                    local coordscar = GetEntityCoords(cars[j])
                    local distance = #(coords - coordscar)
                    table.insert(cars_dist, {cars[j], distance})
                end
                for k=1, #cars_dist, 1 do
                    local z = -1
                    local distance, car = 999
                    for l=1, #cars_dist, 1 do
                        if cars_dist[l][2] < distance then
                            distance = cars_dist[l][2]
                            car = cars_dist[l][1]
                            z = l
                        end
                    end
                    if z ~= -1 then
                        table.remove(cars_dist, z)
                        table.insert(carstrie, car)
                    end
                end
                for i=1, #carstrie, 1 do
                    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(carstrie[i]))
                    ESX.TriggerServerCallback('carlock:isVehicleOwner', function(owner)
                        if owner and not hasAlreadyLocked then
                            local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(carstrie[i]))
                            vehicleLabel = GetLabelText(vehicleLabel)
                            local lock = GetVehicleDoorLockStatus(carstrie[i])
                            if lock == 1 or lock == 0 then
                                SetVehicleDoorsLocked(carstrie[i], 2)
                                ESX.ShowNotification('Has ~r~bloqueado~s~ tu  ~y~'..vehicleLabel..'~s~.')
                                if not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                                end
                                SetVehicleLights(carstrie[i], 2)
                                Citizen.Wait(150)
                                SetVehicleLights(carstrie[i], 0)
                                Citizen.Wait(150)
                                SetVehicleLights(carstrie[i], 2)
                                Citizen.Wait(150)
                                SetVehicleLights(carstrie[i], 0)
                                hasAlreadyLocked = true
                            elseif lock == 2 then
                                SetVehicleDoorsLocked(carstrie[i], 1)
                                ESX.ShowNotification('Has ~g~desbloqueado~s~ tu ~y~'..vehicleLabel..'~s~.')
                                if not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                                end
                                SetVehicleLights(carstrie[i], 2)
                                Citizen.Wait(150)
                                SetVehicleLights(carstrie[i], 0)
                                Citizen.Wait(150)
                                SetVehicleLights(carstrie[i], 2)
                                Citizen.Wait(150)
                                SetVehicleLights(carstrie[i], 0)
                                hasAlreadyLocked = true
                            end
                        else
                            notowned = notowned + 1
                        end
                        if notowned == #carstrie then
                            ESX.ShowNotification("No hay ningún vehículo que te pertenezca cerca.")
                        end 
                    end, plate)
                end         
            end
        end
    end
end)
