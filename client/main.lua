local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
  }
  
local isPaused, isDead = false, false
local components = {}
local currentweapon = {}
local currentWeapon2 = {Ammo = 0}

CreateThread(function()
	while true do
		Wait(0)

		if Citizen.InvokeNative(0xB8DFD30D6973E135, PlayerId()) then
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)

ESX.UI.HUD.DisplayTicket = function(position)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerLoaded = true
	ESX.PlayerData = playerData
	local loadingPosition = (ESX.PlayerData.coords or {x = -539.0761, y = -215.14, z = 36.8})
	ESX.UI.HUD.DisplayTicket(0)
	--PVP
	SetCanAttackFriendly(playerPed, true, false)
	NetworkSetFriendlyFireOption(true)
	--Wanted LVL
	ClearPlayerWantedLevel(PlayerId())
	SetMaxWantedLevel(0)
	TriggerServerEvent('esx:ambulancejob:deathspawn')
	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
	TriggerEvent('playerSpawned')
	DecorRegister('isSpawned', 2)
	SetWeaponsNoAutoswap(false)
	StartServerSyncLoops()
	SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
	SetCreateRandomCops(false)
	SetCreateRandomCopsNotOnScenarios(false)
	SetCreateRandomCopsOnScenarios(false)
	SetGarbageTrucks(false)
	SetRandomBoats(false)
	SetRandomTrains(false)
	Wait(500)
end)

AddEventHandler('esx:onPlayerSpawn', function() 
	isDead = false 
end)

AddEventHandler('esx:onPlayerDeath', function() 
	isDead = true 
end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not ESX.PlayerLoaded do
		Wait(100)
	end
	CreateThread(function()
		local status = 0
		while true do
			if status == 0 then
				status = 1 
				TriggerEvent('exile:load', function(result)
					if result == 3 then
						status = 2
					else
						status = 0
					end
				end)
			end
			
			Wait(200)
			if status == 2 then
				break
			end
		end
	end)
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for k,v in ipairs(ESX.PlayerData.accounts) do
		if v.name == account.name then
			ESX.PlayerData.accounts[k] = account
			break
		end
	end
end)

RegisterNetEvent('esx:addInventoryItem')
AddEventHandler('esx:addInventoryItem', function(item, count, showNotification)
	local found = false
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item.name then
			found = true
			ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
			ESX.PlayerData.inventory[k].count = count
			break
		end
	end
	
	if not found then
		ESX.TriggerServerCallback('esx:isValidItem', function(status)
			if status then
				table.insert(ESX.PlayerData.inventory, item)

				ESX.UI.ShowInventoryItemNotification(true, item.label, count)
				if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
					ESX.ShowInventory()
				end
			end
		end, item.name)	
	else
		if showNotification then
			ESX.UI.ShowInventoryItemNotification(true, item.label, count)
		end

		if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end
	end

end)

RegisterNetEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(item, count, silent)
	local found = false

    for k,v in ipairs(ESX.PlayerData.inventory) do
        if v.name == item.name then
			found = true

            if not silent then
                ESX.UI.ShowInventoryItemNotification(false, v.label, v.count - count)
            end

            ESX.PlayerData.inventory[k].count = count
			if item.count <= 0 then				
				if ESX.PlayerData.slots[item.name] then							
					ESX.SetSlot(item.name, nil, true)
				end
				if v.type == 'item_weapon' then
					RemoveWeaponFromPed(PlayerPedId(), GetHashKey(v.name))
				end
			end	
            break
        end
    end

	if not found then
		ESX.TriggerServerCallback('esx:isValidItem', function(status)
			if status then
				table.insert(ESX.PlayerData.inventory, item)
				
				if item.count <= 0 then
					if ESX.PlayerData.slots[item.name] then					
						ESX.SetSlot(item.name, nil, true)
					end
				end	
				ESX.UI.ShowInventoryItemNotification(true, item.label, count)

				if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
					ESX.ShowInventory()
				end
			end
		end, item.name)	
	else
		if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end
	end
end)

RegisterNetEvent('esx:setWeaponAmmo')
AddEventHandler('esx:setWeaponAmmo', function(weapon, weaponAmmo)
	SetPedAmmo(ESX.PlayerData.ped, GetHashKey(weapon), weaponAmmo)
end)

RegisterNetEvent('esx:teleport')
AddEventHandler('esx:teleport', function(coords)
	local playerPed = PlayerPedId()

	-- ensure decmial number
	coords.x = coords.x + 0.0
	coords.y = coords.y + 0.0
	coords.z = coords.z + 0.0

	ESX.Game.Teleport(playerPed, coords)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setSecondJob')
AddEventHandler('esx:setSecondJob', function(secondjob)
	ESX.PlayerData.secondjob = secondjob
end)

RegisterNetEvent('esx:setThirdJob')
AddEventHandler('esx:setThirdJob', function(thirdjob)
	ESX.PlayerData.thirdjob = thirdjob
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	currentweapon = {}
	currentWeapon2 = {Ammo = 0}
end)

RegisterNetEvent('esx:spawnVehicle')
AddEventHandler('esx:spawnVehicle', function(vehicleName)
	local model = (type(vehicleName) == 'number' and vehicleName or GetHashKey(vehicleName))

	if IsModelInCdimage(model) then
		local playerPed = PlayerPedId()
		local playerCoords, playerHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)

		ESX.Game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		end)
	else
		TriggerEvent('chat:addMessage', {args = {'^1SYSTEM', 'Invalid vehicle model.'}})
	end
end)

RegisterNetEvent('esx:spawnObject')
AddEventHandler('esx:spawnObject', function(model, coords)
	ESX.Game.SpawnObject(model, coords)
end)

RegisterNetEvent('esx:registerSuggestions')
AddEventHandler('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

RegisterNetEvent('esx:deleteVehicle')
AddEventHandler('esx:deleteVehicle', function(radius)
	local playerPed = PlayerPedId()

	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(playerPed), radius)

		for k,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt = attempt + 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				ESX.Game.DeleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(playerPed, true) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end)
local playerPed = PlayerPedId()
CreateThread(function ()
	while true do
		Wait(500)
		playerPed = PlayerPedId()
	end
end)

function StartServerSyncLoops()
	-- set player ammo
	CreateThread(function()
		while ESX.PlayerLoaded do
			local sleep = 1000
			if exports["esx_ambulancejob"]:isDead() then
				currentWeapon2 = {}
				currentweapon = {}
			end
			if GetSelectedPedWeapon(playerPed) ~= -1569615261 and not exports["esx_ambulancejob"]:isDead() then
				sleep = 500
				local _,weaponHash = GetCurrentPedWeapon(playerPed, true)
				local weapon = ESX.GetWeaponFromHash(weaponHash) 
				if weapon then
					local ammoCount = GetAmmoInPedWeapon(playerPed, weaponHash)
					local desireammoType = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)
					local desireammoItem = Config.AmmoTypes[desireammoType]
					local desireammoCount = GetInventoryItemCount(desireammoItem)
					if ammoCount ~= desireammoCount then
						currentWeapon2.Ammo = desireammoCount
						TriggerServerEvent('esx:updateWeaponAmmo', currentweapon.weapon, desireammoItem, desireammoCount, false)
					end
					if weapon.name ~= currentWeapon2.name then 
						currentWeapon2.Ammo = desireammoCount
						currentWeapon2.name = weapon.name
					end
					if IsAimCamActive() then
						sleep = 0
						if IsPedShooting(PlayerPedId()) then
							currentWeapon2.Ammo = desireammoCount
							TriggerServerEvent('esx:updateWeaponAmmo', currentweapon.weapon, desireammoItem, desireammoCount, true)
						end
					end
				end
			end    
			Wait(sleep)
		end
	end)
	-- sync current player coords with server
	CreateThread(function()
		local previousCoords = vector3(ESX.PlayerData.coords.x, ESX.PlayerData.coords.y, ESX.PlayerData.coords.z)

		while ESX.PlayerLoaded do
			local playerPed = PlayerPedId()
			if ESX.PlayerData.ped ~= playerPed then ESX.SetPlayerData('ped', playerPed) end

			if DoesEntityExist(ESX.PlayerData.ped) then
				local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
				local distance = #(playerCoords - previousCoords)

				if distance > 1 then
					previousCoords = playerCoords
					local playerHeading = ESX.Math.Round(GetEntityHeading(ESX.PlayerData.ped), 1)
					local formattedCoords = {x = ESX.Math.Round(playerCoords.x, 1), y = ESX.Math.Round(playerCoords.y, 1), z = ESX.Math.Round(playerCoords.z, 1), heading = playerHeading}
					TriggerServerEvent('esx:updateCoords', formattedCoords)
				end
			end
			Wait(10000)
		end
	end)
end

function GetInventoryItemCount(name)
	local inventory = ESX.PlayerData.inventory
	for i=1, #inventory, 1 do
		if inventory[i].name == name then
			return inventory[i].count
		end
	end
	return nil
end

RegisterCommand('showinv', function()
	if not exports['esx_ambulancejob']:isDead() and not exports['esx_policejob']:IsCuffed() and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

RegisterKeyMapping('showinv', 'Włącz/wyłącz ekwipunek', 'keyboard', 'F2')


CreateThread(function()
	while true do
		Wait(0)
		if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			if IsControlPressed(0, Keys['LEFTALT']) then
				local bind = nil
				for i, key in ipairs({157, 158, 160, 164, 165}) do
					DisableControlAction(0, key, true)
						if IsDisabledControlJustPressed(0, key) then
							bind = i
						break
					end
				end

				if bind then
					local menu = ESX.UI.Menu.GetOpened('default', 'es_extended', 'inventory')
					local elements = menu.data.elements
					
					for i=1, #elements, 1 do
						if elements[i].selected then
							if elements[i].usable or elements[i].type == 'item_weapon' then
								ESX.ShowNotification('Ustawiono ~y~'..elements[i].label..'~s~ na pozycję ~o~'..bind)
								ESX.SetSlot(elements[i].value, bind, true)				

								ESX.ShowInventory()
							else
								ESX.ShowNotification('Nie możesz ustawić ~y~'..elements[i].label)
							end
						end
					end
				end
			end	
		else
			Wait(250)	
		end
	end
end)

RegisterNetEvent('es_extended:useSlot')
AddEventHandler('es_extended:useSlot', function(name)
	local found = false
	local playerPed = PlayerPedId() 
	local weapon = GetSelectedPedWeapon(playerPed)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == name then
			found = true
			if v.type == 'item_weapon' then
				if not exports['esx_ambulancejob']:IsBlockWeapon() then
					if currentweapon.name == name and GetHashKey(currentweapon.weapon) == weapon then
						ESX.ShowNotification('Schowałeś/aś ~r~'..v.label)
						currentweapon = {}
						SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
					else	
						currentweapon = {name = name, weapon = v.name}
						ESX.ShowNotification('Wyciągnąłeś/aś ~g~'..v.label)

						local hash = GetHashKey(v.name)	
						if not HasPedGotWeapon(playerPed, hash, false) then
							Citizen.InvokeNative(0xBF0FD6E56C964FCB, playerPed, hash, 0, false, true)
						end			

						if components ~= nil then				
							for k2,v2 in ipairs(Config.Weapons) do
								if v2.name == v.name then						
									
									for k3,v3 in ipairs(v2.components) do
										local hash2 = v3.hash
										local foundcomp = false
										
										for k4,v4 in ipairs(components) do
											local componentHash = ESX.GetWeaponComponent(v.name, v4)
											
											if componentHash ~= nil then
												if hash2 == componentHash.hash then
													foundcomp = true
													break
												end
											end
										end
										
										if not foundcomp then
											RemoveWeaponComponentFromPed(playerPed, hash, hash2)
										else
											GiveWeaponComponentToPed(playerPed, hash, hash2)	
										end
									end
								end
							end
						end
						
						SetCurrentPedWeapon(playerPed, hash, true)
						if currentWeapon2.Ammo and currentWeapon2.name == currentweapon.weapon then
							Citizen.InvokeNative(0x14E56BC5B5DB6A19, playerPed, hash, currentWeapon2.Ammo)
						end		
					end
				else
					ESX.ShowNotification('~r~Jesteś zbyt bardzo osłabiony żeby wyciągnąć broń')
				end
			elseif v.type == 'item' then
				TriggerServerEvent('esx:useItem', v.name)
			end
		end
	end
		
		
	if not found then			
		ESX.SetSlot(name, nil, true)
	end
end)

RegisterKeyMapping('+-slot1', 'Slot 1', 'keyboard', '1')
RegisterKeyMapping('+-slot2', 'Slot 2', 'keyboard', '2')
RegisterKeyMapping('+-slot3', 'Slot 3', 'keyboard', '3')
RegisterKeyMapping('+-slot4', 'Slot 4', 'keyboard', '4')
RegisterKeyMapping('+-slot5', 'Slot 5', 'keyboard', '5')

RegisterCommand('+-slot1', function()
	if exports['qs-smartphone']:isPhoneOpen() then return end
	if exports["esx_ambulancejob"]:isDead() then return end
	Select(1)
end)

RegisterCommand('+-slot2', function()
	if exports['qs-smartphone']:isPhoneOpen() then return end
	if exports["esx_ambulancejob"]:isDead() then return end
	Select(2)
end)

RegisterCommand('+-slot3', function()
	if exports['qs-smartphone']:isPhoneOpen() then return end
	if exports["esx_ambulancejob"]:isDead() then return end
	Select(3)
end)

RegisterCommand('+-slot4', function()
	if exports['qs-smartphone']:isPhoneOpen() then return end
	if exports["esx_ambulancejob"]:isDead() then return end
	Select(4)
end)

RegisterCommand('+-slot5', function()
	if exports['qs-smartphone']:isPhoneOpen() then return end
	if exports["esx_ambulancejob"]:isDead() then return end
	Select(5)
end)

function Select(number)
	if not exports['esx_policejob']:IsCuffed() and exports['exile_animacje']:PedStatus() and not IsPedInAnyPoliceVehicle(PlayerPedId()) then
		local slot = ESX.GetexileSlots()
		local item = nil
		for k,v in pairs(slot) do
			if v == number then
				item = k
			end
		end
		if item ~= nil then
			TriggerEvent('es_extended:useSlot', item)
		end
	end
end

RegisterNetEvent('es_extended:weaponClips')
AddEventHandler('es_extended:weaponClips', function(extended)
	local playerPed = PlayerPedId()

	if DoesEntityExist(playerPed) then
		local status, weaponHash = GetCurrentPedWeapon(playerPed, true)
		local weapon = ESX.GetWeaponFromHash(weaponHash)
		
		if status == 1 and weapon and currentweapon.name ~= nil then
			local canput = false
			for k,v in ipairs(ESX.PlayerData.inventory) do
				if v.type == 'item_weapon' then
					if v.name == currentweapon.name and GetHashKey(currentweapon.weapon) == weaponHash then
						for k2,v2 in ipairs(Config.Weapons) do
							if v.name == v2.name then 
								if v2.take_ammo ~= nil then
									if v2.take_ammo == extended then
										canput = true
										local ammoType = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)
										local ammoItem = Config.AmmoTypes[ammoType]
										
										TriggerServerEvent('es_extended:giveAmmo', ammoItem, 32)
										break											
									end	
								end
							end					
						end
					end
				end
			end
			
			if canput then
				TriggerServerEvent('es_extended:removeClip', extended)
			else
				ESX.ShowNotification('~r~Nieodpowiedni typ magazynku')
			end
		else
			ESX.ShowNotification("Nie posiadasz broni w ręce")
		end
	end	
end)

RegisterNetEvent('es_extended:setComponent')
AddEventHandler('es_extended:setComponent', function(state, weaponComponent)
	local playerPed = PlayerPedId()
	local status, weaponHash = GetCurrentPedWeapon(playerPed, true)
	local weapon = ESX.GetWeaponFromHash(weaponHash)
	local found = false
	for k,v in pairs(ESX.PlayerData.inventory) do
		if v.type == 'item_weapon' then
			if v.name == weapon.name and GetHashKey(weapon.name) == weaponHash then
				found = true
				if state then	
					local componentHash = ESX.GetWeaponComponent(weapon.name, weaponComponent)
	
					if componentHash then	
						local Equiped = false
						for k2,v2 in ipairs(components) do
							if v2 == weaponComponent then
								Equiped = true
								break
							end
						end		
						if Equiped then
							ESX.ShowNotification('Posiadasz już zamontowany '..componentHash.label)
						else
							table.insert(components, weaponComponent)				
							TriggerServerEvent('es_extended:componentMenu', true, weaponComponent)
							--TriggerServerEvent('es_extended:saveComponents', components)
							GiveWeaponComponentToPed(playerPed, GetHashKey(weapon.name), componentHash.hash)
							ESX.ShowNotification('Udało ci się zamontować '..componentHash.label)
							PlaySoundFrontend(-1, "WEAPON_ATTACHMENT_UNEQUIP", "HUD_AMMO_SHOP_SOUNDSET", 1)
						end
					else
						ESX.ShowNotification('Nie możesz zamontować dodatku')
					end
				else
					local componentHash = ESX.GetWeaponComponent(weapon.name, weaponComponent)
					
					if componentHash then
						local Equiped = false
						for k2,v2 in ipairs(components) do
							if v2 == weaponComponent then
								Equiped = true
								
								table.remove(components, k2)
								break
							end
						end	
						if Equiped then												
							RemoveWeaponComponentFromPed(playerPed, GetHashKey(weapon.name), componentHash.hash)
							ESX.ShowNotification('Udało ci się zdemontować '..componentHash.label)
							Equiped = false
							--TriggerServerEvent('es_extended:saveComponents', components)
							TriggerServerEvent('es_extended:componentMenu', false, weaponComponent)							
							PlaySoundFrontend(-1, "WEAPON_ATTACHMENT_UNEQUIP", "HUD_AMMO_SHOP_SOUNDSET", 1)
						else
							ESX.ShowNotification('Broń nie posiada zamontowanego '..componentHash.label)
						end
					else
						ESX.ShowNotification('Nie możesz zdemontować dodatku')
					end			
				end
				
				break
			end
		end
	end
	
	if not found then
		ESX.ShowNotification("Ta broń nie posiada tego dodatku")
	end
end)

RegisterNetEvent('esx:updateDecor')
AddEventHandler('esx:updateDecor', function(what, entity, key, value)
	entity = NetworkGetEntityFromNetworkId(entity)
	if not entity or entity < 1 then
	  --nil
	elseif what == 'DEL' then
		DecorRemove(entity, key)
	elseif what == 'BOOL' then
		DecorSetBool(entity, key, value == true)
	else
		value = tonumber(value)
		if value then
			DecorSetInt(entity, key, value)
		end
	end 
end)
