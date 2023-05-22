CreateThread(function()
	local isDead = false
	local vehicleDead = false
	while true do
		local sleep = 1000
		local player = PlayerId()

		if NetworkIsPlayerActive(player) then
			local playerPed = PlayerPedId()
			local inVehicle = IsPedInAnyVehicle(playerPed, false)
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			if IsPedFatallyInjured(playerPed) and not isDead and not inVehicle then
				sleep = 0
				isDead = true
				vehicleDead = false

				local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
				local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

				if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause, vehicleDead)
				else
					PlayerKilled(deathCause, vehicleDead)
				end
			elseif IsPedFatallyInjured(playerPed) and not isDead and inVehicle then
				CreateThread(function ()
					if vehicle ~= nil and vehicle > 0 then
						vehicleDead = true
						sleep = 0
						isDead = true
		
						local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
						local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
		
						if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
							PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause, vehicleDead)
						else
							PlayerKilled(deathCause, vehicleDead)
						end
					end
				end)
			elseif not IsPedFatallyInjured(playerPed) and isDead then
				sleep = 0
				isDead = false
			end
		end
		Wait(sleep)
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause, vehicleDead)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1), z = ESX.Math.Round(victimCoords.z, 1)},
		killerCoords = {x = ESX.Math.Round(killerCoords.x, 1), y = ESX.Math.Round(killerCoords.y, 1), z = ESX.Math.Round(killerCoords.z, 1)},

		killedByPlayer = true,
		deathCause = deathCause,
		distance = ESX.Math.Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId,

		diedAtVehicle = vehicleDead
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end

function PlayerKilled(deathCause, vehicleDead)
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)

	local data = {
		victimCoords = {x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1), z = ESX.Math.Round(victimCoords.z, 1)},

		killedByPlayer = false,
		deathCause = deathCause,

		diedAtVehicle = vehicleDead
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end