local PlayerData                = {}
local GUI                       = {}
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local IsHandcuffed              = false
local IsDragged                 = false
local CopPed                    = 0
local ox_inventory              = exports.ox_inventory
GUI.Time                        = 0

Citizen.CreateThread(function()
  exports.ox_target:addSphereZone({
    coords = Config.MafiaStations.Mafia.Armories,
    radius = 0.6,
    distance = 2,
    options = {
        {
            name = 'mafia1',
            onSelect = function()
              exports["esx_mafia"]:OpenArmoryMenu()
            end,
            icon = 'fa-solid fa-circle',
            label = 'Abrir inventário',
        }
    }
  })
end)

function OpenArmoryMenu()
  TriggerServerEvent('ox:loadStashes')
  ox_inventory:openInventory('stash', {id=Config.JobId, groups=Config.StashGroups})
end

exports("OpenArmoryMenu",OpenArmoryMenu)

function OpenVehicleSpawnerMenu(station, partNum)

  local vehicles = Config.MafiaStations[station].Vehicles

  ESX.UI.Menu.CloseAll()

  local elements = {}

  for i=1, #Config.MafiaStations[station].AuthorizedVehicles, 1 do
    local vehicle = Config.MafiaStations[station].AuthorizedVehicles[i]
    table.insert(elements, {label = vehicle.label, value = vehicle.name})
  end

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'vehicle_spawner',
    {
      title    = _U('vehicle_menu'),
      align    = 'top-left',
      elements = elements,
    },
    function(data, menu)

      menu.close()

      local model = data.current.value

      local vehicle = GetClosestVehicle(vehicles[partNum].SpawnPoint.x,  vehicles[partNum].SpawnPoint.y,  vehicles[partNum].SpawnPoint.z,  3.0,  0,  71)

      if not DoesEntityExist(vehicle) then

        local playerPed = GetPlayerPed(-1)

        if Config.MaxInService == -1 then

          ESX.Game.SpawnVehicle(model, {
            x = vehicles[partNum].SpawnPoint.x,
            y = vehicles[partNum].SpawnPoint.y,
            z = vehicles[partNum].SpawnPoint.z
          }, vehicles[partNum].Heading, function(vehicle)
            TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
          end)

        else

          ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)

            if canTakeService then

              ESX.Game.SpawnVehicle(model, {
                x = vehicles[partNum].SpawnPoint.x,
                y = vehicles[partNum].SpawnPoint.y,
                z = vehicles[partNum].SpawnPoint.z
              }, vehicles[partNum].Heading, function(vehicle)
                TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
              end)

            else
              ESX.ShowNotification(_U('service_max') .. inServiceCount .. '/' .. maxInService)
            end

          end, 'themafia')

        end

      else
        ESX.ShowNotification(_U('vehicle_out'))
      end

    end,
    function(data, menu)

      menu.close()

      CurrentAction     = 'menu_vehicle_spawner'
      CurrentActionMsg  = _U('vehicle_spawner')
      CurrentActionData = {station = station, partNum = partNum}

    end
  )

end

function OpenBallasActionsMenu()

  local elements = {
    { unselectable = true, icon = "fas fa-info-circle", title = Config.JobName },
    { icon = "fas fa-info-circle", title = _U('citizen_interaction'), name = 'citizen_interaction'}, 
  }

  ESX.OpenContext("right" , elements, function(menu,element)

    if menu.name == "citizen_interaction" then

      local elements2 = {
        { unselectable = true, icon = "fas fa-info-circle", title = _U('citizen_interaction') },
        { icon = "fas fa-info-circle", title = _U('search'), name = 'body_search'}, 
        { icon = "fas fa-info-circle", title = _U('drag'), name = 'drag'}, 
        { icon = "fas fa-info-circle", title = _U('put_in_vehicle'), name = 'put_in_vehicle'}, 
        { icon = "fas fa-info-circle", title = _U('out_the_vehicle'), name = 'out_the_vehicle'}, 
      }

      ESX.OpenContext("right" , elements2, function(menu2,element2)

        local player, distance = ESX.Game.GetClosestPlayer()

        if distance ~= -1 and distance <= 3.0 then

          if menu2.name == 'body_search' then
            ox_inventory:openNearbyInventory()
          end

          if menu2.name == 'drag' then
            TriggerServerEvent('esx_mafia:drag', GetPlayerServerId(player))
          end

          if menu2.name == 'put_in_vehicle' then
            TriggerServerEvent('esx_mafia:putInVehicle', GetPlayerServerId(player))
          end

          if menu2.name == 'out_the_vehicle' then
              TriggerServerEvent('esx_mafia:OutVehicle', GetPlayerServerId(player))
          end

        else
          ESX.ShowNotification(_U('no_players_nearby'))
        end
      end, function(menu2)

      end)
    end

    ESX.CloseContext()
  end, function(menu)

  end)

end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

RegisterNetEvent('esx_mafia:drag')
AddEventHandler('esx_mafia:drag', function(cop)
  TriggerServerEvent('esx:clientLog', 'starting dragging')
  IsDragged = not IsDragged
  CopPed = tonumber(cop)
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)

RegisterNetEvent('esx_mafia:putInVehicle')
AddEventHandler('esx_mafia:putInVehicle', function()

  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)

    if DoesEntityExist(vehicle) then

      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil

      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end

      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end

    end

  end

end)

RegisterNetEvent('esx_mafia:OutVehicle')
AddEventHandler('esx_mafia:OutVehicle', function(t)
  local ped = GetPlayerPed(t)
  ClearPedTasksImmediately(ped)
  plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
  local xnew = plyPos.x+2
  local ynew = plyPos.y+2

  SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

Citizen.CreateThread(function()
  while true do

    Citizen.Wait(0)

    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlJustPressed(0, 38) and PlayerData.job ~= nil and PlayerData.job.name == 'themafia' and (GetGameTimer() - GUI.Time) > 150 then

        if CurrentAction == 'menu_armory' then
          OpenArmoryMenu(CurrentActionData.station)
        end

        if CurrentAction == 'menu_vehicle_spawner' then
          OpenVehicleSpawnerMenu(CurrentActionData.station, CurrentActionData.partNum)
        end

        if CurrentAction == 'delete_vehicle' then

          if Config.EnableSocietyOwnedVehicles then

            local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
            TriggerServerEvent('esx_society:putVehicleInGarage', 'themafia', vehicleProps)

          else

            if
              GetEntityModel(vehicle) == GetHashKey('schafter3')  or
              GetEntityModel(vehicle) == GetHashKey('kuruma2') or
              GetEntityModel(vehicle) == GetHashKey('sandking') or
              GetEntityModel(vehicle) == GetHashKey('mule3') or
              GetEntityModel(vehicle) == GetHashKey('guardian') or
              GetEntityModel(vehicle) == GetHashKey('burrito3') or
              GetEntityModel(vehicle) == GetHashKey('mesa')
            then
              TriggerServerEvent('esx_service:disableService', 'themafia')
            end

          end

          ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
        end

        if CurrentAction == 'menu_boss_actions' then
          ESX.UI.Menu.CloseAll()
		  TriggerEvent('esx_society:openBossMenu', 'themafia', function(data, menu)
			menu.close()

			CurrentAction     = 'menu_boss_actions'
			CurrentActionMsg  = _U('open_bossmenu')
			CurrentActionData = {}
			end, { wash = false })
        end

        CurrentAction = nil
        GUI.Time      = GetGameTimer()

      end

    end

   if IsControlJustPressed(0, 167) and PlayerData.job ~= nil and PlayerData.job.name == 'themafia' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'ballas_actions') and (GetGameTimer() - GUI.Time) > 150 then
     OpenBallasActionsMenu()
     GUI.Time = GetGameTimer()
    end

  end
end)
