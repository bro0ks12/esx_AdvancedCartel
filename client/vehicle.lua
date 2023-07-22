
local spawnedVehicles = {}

AddEventHandler("esx_AdvancedCartel:OpenVehicleSpawnerMenu", function(data)
	types = data.menuOptions.type
    station = data.menuOptions.station
    part = data.menuOptions.part
    partNum = data.menuOptions.partNum
    OpenVehicleSpawnerMenu(types, station, part, partNum)
end)

function OpenVehicleSpawnerMenu(type, station, part, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local elements = {
		{unselectable = true, icon = "fas fa-car", title = TranslateCap('vehicle_menu')},
		{icon = "fas fa-car", title = TranslateCap('garage_storeditem'), action = 'garage'},
		{icon = "fas fa-car", title = TranslateCap('garage_storeitem'), action = 'store_garage'},
		{icon = "fas fa-car", title = TranslateCap('garage_buyitem'), action = 'buy_vehicle'}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		if element.action == "buy_vehicle" then
			local shopElements = {}
			local shopCoords = Config.CartelStations[station][part][partNum].InsideShop
			local authorizedVehicles = Config.CartelStations.Cartel.AuthorizedVehicles

			if authorizedVehicles then
				if #authorizedVehicles > 0 then
					for k,vehicle in ipairs(authorizedVehicles) do
						if IsModelInCdimage(vehicle.model) then
							local vehicleLabel = GetLabelText(GetDisplayNameFromVehicleModel(vehicle.model))

							shopElements[#shopElements+1] = {
								icon = 'fas fa-car',
								title = vehicle.name,
								name  = vehicleLabel,
								model = vehicle.model,
								price = vehicle.price,
								type  = type
							}
						end
					end

					if #shopElements > 0 then
						OpenShopMenu(shopElements, playerCoords, shopCoords)
					else
						exports['okokNotify']:Alert('Alerta', TranslateCap('garage_notauthorized'), 2000, 'error')
					end
				else
					exports['okokNotify']:Alert('Alerta', TranslateCap('garage_notauthorized'), 2000, 'error')
				end
			else
				exports['okokNotify']:Alert('Alerta', TranslateCap('garage_notauthorized'), 2000, 'error')
			end
		elseif element.action == "garage" then
			local garage = {
				{unselectable = true, icon = "fas fa-car", title = "Garagem"}
			}

			ESX.TriggerServerCallback('renzu_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					local allVehicleProps = {}

					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						if IsModelInCdimage(props.model) then
							local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
							local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName, props.plate)

							if v.stored == true then
								label = label .. ('<span style="color:green;">%s</span>'):format(TranslateCap('garage_stored'))
							elseif v.stored == false then
								label = label .. ('<span style="color:darkred;">%s</span>'):format(TranslateCap('garage_notstored'))
							end

							garage[#garage+1] = {
								icon = 'fas fa-car',
								title = v.name,
								stored = v.stored,
								model = props.model,
								plate = props.plate
							}

							allVehicleProps[props.plate] = props
						end
					end

					if #garage > 0 then
						ESX.OpenContext("right", garage, function(menuG,elementG)
							if elementG.stored == true then
								local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)
								if foundSpawn then
									ESX.CloseContext()

									ESX.Game.SpawnVehicle(elementG.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
										local vehicleProps = allVehicleProps[elementG.plate]
										ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

										TriggerServerEvent('esx_vehicleshop:setJobVehicleState', elementG.plate, false)
										exports['okokNotify']:Alert('Alerta', TranslateCap('garage_released'), 2000, 'success')
									end)
								end
							else
								exports['okokNotify']:Alert('Alerta', TranslateCap('garage_notavailable'), 2000, 'error')
							end
						end)
					else
						exports['okokNotify']:Alert('Alerta', TranslateCap('garage_empty'), 2000, 'info')
					end
				else
					exports['okokNotify']:Alert('Alerta', TranslateCap('garage_empty'), 2000, 'info')
				end
			end, type)
		elseif element.action == "store_garage" then
			StoreNearbyVehicle(playerCoords)
			ESX.CloseContext()
		end
	end)
end

exports('OpenVehicleSpawnerMenu', OpenVehicleSpawnerMenu)

function StoreNearbyVehicle(playerCoords)
	local vehicles, plates, index = ESX.Game.GetVehiclesInArea(playerCoords, 60), {}, {}

	if next(vehicles) then
		for i = 1, #vehicles do
			local vehicle = vehicles[i]
			
			-- Make sure the vehicle we're saving is empty, or else it won't be deleted
			if GetVehicleNumberOfPassengers(vehicle) == 0 and IsVehicleSeatFree(vehicle, -1) then
				local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
				plates[#plates + 1] = plate
				index[plate] = vehicle
			end
		end
	else
		exports['okokNotify']:Alert('Alerta', TranslateCap('garage_store_nearby'), 2000, 'info')
		return
	end

	ESX.TriggerServerCallback('esx_AdvancedCartel:storeNearbyVehicle', function(plate)
		if plate then
			local vehicleId = index[plate]
			local attempts = 0
			ESX.Game.DeleteVehicle(vehicleId)
			local isBusy = true

			CreateThread(function()
				BeginTextCommandBusyspinnerOn('STRING')
				AddTextComponentSubstringPlayerName(TranslateCap('garage_storing'))
				EndTextCommandBusyspinnerOn(4)

				while isBusy do
					Wait(100)
				end

				BusyspinnerOff()
			end)

			-- Workaround for vehicle not deleting when other players are near it.
			while DoesEntityExist(vehicleId) do
				Wait(500)
				attempts = attempts + 1

				-- Give up
				if attempts > 30 then
					break
				end

				vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for i = 1, #vehicles do
						local vehicle = vehicles[i]
						if ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)) == plate then
							ESX.Game.DeleteVehicle(vehicle)
							break
						end
					end
				end
			end

			isBusy = false
			exports['okokNotify']:Alert('Alerta', TranslateCap('garage_has_stored'), 2000, 'success')
		else
			exports['okokNotify']:Alert('Alerta', TranslateCap('garage_has_notstored'), 2000, 'info')
		end
	end, plates)
end

function GetAvailableVehicleSpawnPoint(station, part, partNum)
	local spawnPoints = Config.CartelStations[station][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		exports['okokNotify']:Alert('Alerta', TranslateCap('vehicle_blocked'), 2000, 'error')
		return false
	end
end

function OpenShopMenu(elements, restoreCoords, shopCoords)
	local playerPed = PlayerPedId()
	isInShopMenu = true
	ESX.OpenContext("right", elements, function(menu,element)
		local elements2 = {
			{unselectable = true, icon = "fas fa-car", title = element.title},
			{icon = "fas fa-eye", title = "Visualizar", value = "view"}
		}

		ESX.OpenContext("right", elements2, function(menu2,element2)
			if element2.value == "view" then
				DeleteSpawnedVehicles()
				WaitForVehicleToLoad(element.model)

				ESX.Game.SpawnLocalVehicle(element.model, shopCoords, 0.0, function(vehicle)
					table.insert(spawnedVehicles, vehicle)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
					FreezeEntityPosition(vehicle, true)
					SetModelAsNoLongerNeeded(element.model)

					if element.props then
						ESX.Game.SetVehicleProperties(vehicle, element.props)
					end
				end)

				local elements3 = {
					{unselectable = true, icon = "fas fa-car", title = element.title},
					{icon = "fas fa-check-double", title = "Comprar", value = "buy"},
					{icon = "fas fa-eye", title = "Parar de vizualizar", value = "stop"}
				}

				ESX.OpenContext("right", elements3, function(menu3,element3)
					if element3.value == 'stop' then
						isInShopMenu = false
						ESX.CloseContext()

						DeleteSpawnedVehicles()
						FreezeEntityPosition(playerPed, false)
						SetEntityVisible(playerPed, true)

						ESX.Game.Teleport(playerPed, restoreCoords)
					elseif element3.value == "buy" then
						local newPlate = exports['renzu_vehicleshop']:GeneratePlate()
						local vehicle  = GetVehiclePedIsIn(playerPed, false)
						local props    = ESX.Game.GetVehicleProperties(vehicle)
						props.plate    = newPlate

						ESX.TriggerServerCallback('esx_AdvancedCartel:buyJobVehicle', function (bought)
							if bought then
								exports['okokNotify']:Alert('Alerta', TranslateCap('vehicleshop_bought', element.title, ESX.Math.GroupDigits(element.price)), 2000, 'success')
								isInShopMenu = false
								ESX.CloseContext()
								DeleteSpawnedVehicles()
								FreezeEntityPosition(playerPed, false)
								SetEntityVisible(playerPed, true)

								ESX.Game.Teleport(playerPed, restoreCoords)
							else
								exports['okokNotify']:Alert('Alerta', TranslateCap('vehicleshop_money'), 2000, 'error')
								ESX.CloseContext()
							end
						end, props, element.type, element.title, element.price)
					end
				end, function()
					isInShopMenu = false
					ESX.CloseContext()

					DeleteSpawnedVehicles()
					FreezeEntityPosition(playerPed, false)
					SetEntityVisible(playerPed, true)

					ESX.Game.Teleport(playerPed, restoreCoords)
				end)
			end
		end)
	end)
end


CreateThread(function()
	while true do
		Wait(0)

		if isInShopMenu then
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Wait(500)
		end
	end
end)

function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or joaat(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('vehicleshop_awaiting_model'))
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end
