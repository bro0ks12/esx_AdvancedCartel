local stash = {
  id = Config.JobId,
  label = Config.JobName,
  slots = 50,
  weight = Config.StashWeight,
  groups = Config.StashGroups
}

if Config.MaxInService ~= -1 then
  TriggerEvent('esx_service:activateService', 'mafia', Config.MaxInService)
end

RegisterServerEvent('esx_mafia:drag')
AddEventHandler('esx_mafia:drag', function(target)
	local _source = source
	TriggerClientEvent('esx_mafia:drag', target, _source)
end)

RegisterServerEvent('esx_mafia:putInVehicle')
AddEventHandler('esx_mafia:putInVehicle', function(target)
	TriggerClientEvent('esx_mafia:putInVehicle', target)
end)

RegisterServerEvent('esx_mafia:OutVehicle')
AddEventHandler('esx_mafia:OutVehicle', function(target)
	TriggerClientEvent('esx_mafia:OutVehicle', target)
end)

ESX.RegisterServerCallback('esx_mafia:getVehicleInfos', function(source, cb, plate)

	if Config.EnableESXIdentity then

    MySQL.Async.fetchAll(
      'SELECT * FROM owned_vehicles',
      {},
      function(result)

        local foundIdentifier = nil

        for i=1, #result, 1 do

          local vehicleData = json.decode(result[i].vehicle)

          if vehicleData.plate == plate then
            foundIdentifier = result[i].owner
            break
          end

        end

        if foundIdentifier ~= nil then

          MySQL.Async.fetchAll(
            'SELECT * FROM users WHERE identifier = @identifier',
            {
              ['@identifier'] = foundIdentifier
            },
            function(result)

              local ownerName = result[1].firstname .. " " .. result[1].lastname

              local infos = {
                plate = plate,
                owner = ownerName
              }

              cb(infos)

            end
          )

        else

          local infos = {
          plate = plate
          }

          cb(infos)

        end

      end
    )

  else

    MySQL.Async.fetchAll(
      'SELECT * FROM owned_vehicles',
      {},
      function(result)

        local foundIdentifier = nil

        for i=1, #result, 1 do

          local vehicleData = json.decode(result[i].vehicle)

          if vehicleData.plate == plate then
            foundIdentifier = result[i].owner
            break
          end

        end

        if foundIdentifier ~= nil then

          MySQL.Async.fetchAll(
            'SELECT * FROM users WHERE identifier = @identifier',
            {
              ['@identifier'] = foundIdentifier
            },
            function(result)

              local infos = {
                plate = plate,
                owner = result[1].name
              }

              cb(infos)

            end
          )

        else

          local infos = {
          plate = plate
          }

          cb(infos)

        end

      end
    )

  end

end)

AddEventHandler('onServerResourceStart', function(resourceName)
  if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
      exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.groups)
  end
end)

Citizen.CreateThread( function()
  updatePath = "/bro0ks12/esx_AdvancedMafia/releases" -- your git user/repo path
  resourceName = "esx_AdvancedMafia ("..GetCurrentResourceName()..")" -- the resource name
  
  function checkVersion(err,responseText, headers)
    curVersion = LoadResourceFile(GetCurrentResourceName(), "version") -- make sure the "version" file actually exists in your resource root!
  
    if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
      print("\n###############################")
      print("\n"..resourceName.." is outdated, should be:\n"..responseText.."is:\n"..curVersion.."\nplease update it from https://github.com"..updatePath.."")
      print("\n###############################")
    elseif tonumber(curVersion) > tonumber(responseText) then
      print("You somehow skipped a few versions of "..resourceName.." or the git went offline, if it's still online i advise you to update ( or downgrade? )")
    else
      print("\n"..resourceName.." is up to date, have fun!")
    end
  end
  
  PerformHttpRequest("https://github.com/"..updatePath, checkVersion, "GET")
  end)
