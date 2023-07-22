local stash = {
    id = Config.JobId,
    label = Config.JobName,
    slots = 50,
    weight = Config.StashWeight,
    groups = Config.StashGroups
}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName ==
        GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots,
                                           stash.weight, stash.groups)
    end
end)

ESX.RegisterServerCallback('esx_AdvancedCartel:buyJobVehicle', function(source, cb, vehicleProps, type, vehicleName, Vehprice)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Vehprice

	-- vehicle model not found
	if price == 0 then
		cb(false)
	else
		if exports.pefcl:getDefaultAccountBalance(source).data >= price then

			MySQL.insert('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`, name) VALUES (?, ?, ?, ?, ?, ?, ?)', { xPlayer.identifier, json.encode(vehicleProps), vehicleProps.plate, type, xPlayer.job.name, true, vehicleName},
			function (rowsChanged)
				cb(true)
			end)
			exports.pefcl:removeBankBalance(source, { amount = price, message = "Compra de veículo" })
		else
			cb(false)
		end
	end
end)

ESX.RegisterServerCallback('esx_AdvancedCartel:storeNearbyVehicle', function(source, cb, plates)
	local xPlayer = ESX.GetPlayerFromId(source)

	local plate = MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE owner = ? AND plate IN (?) AND job = ?', {xPlayer.identifier, plates, xPlayer.job.name})

	if plate then
		MySQL.update('UPDATE owned_vehicles SET `stored` = true WHERE owner = ? AND plate = ? AND job = ?', {xPlayer.identifier, plate, xPlayer.job.name},
		function(rowsChanged)
			if rowsChanged == 0 then
				cb(false)
			else
				cb(plate)
			end
		end)
	else
		cb(false)
	end
end)
