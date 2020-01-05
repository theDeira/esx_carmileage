ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_carmileage:addMileage')
AddEventHandler('esx_carmileage:addMileage', function(vehPlate, km)
    local src = source
    local identifier = ESX.GetPlayerFromId(src).identifier
	local plate = vehPlate
	local newKM = km
		
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate=@plate ', {
        ['@plate'] = plate
    }, function(result)
		if result then
		    MySQL.Async.execute('UPDATE veh_km SET km = @kms WHERE carplate = @plate', {['@plate'] = plate, ['@kms'] = newKM})
			--RconPrint('true')
		else
		
		end
    end)
end)

ESX.RegisterServerCallback('esx_carmileage:getMileage', function(source, cb, plate)

	local xPlayer = ESX.GetPlayerFromId(source)
	local vehPlate = plate
	-- print("veh plate is:")
	-- print(vehPlate)
	
	-- print("local plate is:")
	-- print(plate)

	MySQL.Async.fetchAll(
		'SELECT * FROM veh_km WHERE carplate = @plate',
		{
			['@plate'] = vehPlate
		},
		function(result)

			local found = false

			for i=1, #result, 1 do

				local vehicleProps = result[i].carplate

				if vehicleProps == vehPlate then
					KMSend = result[i].km
					-- print("mostrando KMS")
					-- print(KMSend)
					found = true
					break
				end

			end

			if found then
				cb(KMSend)
			else
				cb(0)
				MySQL.Async.execute('INSERT INTO veh_km (carplate) VALUES (@carplate)',{['@carplate'] = plate})
				Wait(2000)
			end

		end
	)

end)

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

RegisterCommand('5664', function(source, args)  --araç transfer komutu

	
	myself = source
	local xPlayer = ESX.GetPlayerFromId(myself)
	local plate1 = args[1]
  
	if plate1 ~= nil then plate01 = plate1 else plate01 = "" end
  
  


	MySQL.Async.fetchScalar(
        'SELECT km FROM veh_km WHERE carplate = @plate',
        {
            ['@plate'] = plate1
        },
        function(result)
            if result then
				TriggerClientEvent('esx:showNotification', myself, "~h~~c~Biraz bekleyin,~w~ belirttiğiniz ~b~plaka ~g~sorgulanıyor...")  
				Citizen.Wait(5000)
				TriggerClientEvent('esx:showNotification', myself, "~w~PLAKA: ~c~"..plate1.."~w~ - ~g~"..(round(result / 1000) * 1.0 ).."KM") 
				Citizen.Wait(5000)
				TriggerClientEvent('esx:showNotification', myself, "~g~$100~w~ sorgu ücreti alınmıştır!") 
				xPlayer.removeMoney(100)
				--TriggerClientEvent('esx:showNotification', myself, "1")  
			else
				--TriggerClientEvent('esx:showNotification', myself, "2")  
				TriggerClientEvent('esx:showNotification', myself, "~h~~c~Biraz bekleyin,~w~ belirttiğiniz ~b~plaka ~g~sorgulanıyor...")  
				Citizen.Wait(5000)
				TriggerClientEvent('esx:showNotification', myself, '~b~Karakol ~w~veritabanında böyle bir ~y~plaka ~r~yok!')  
            end
		
        end
    )
	
end)
