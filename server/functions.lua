ESX.Trace = function(msg)
	if Config.EnableDebug then

	end
end

ESX.SetTimeout = function(msec, cb)
	local id = ESX.TimeoutCount + 1

	SetTimeout(msec, function()
		if ESX.CancelledTimeouts[id] then
			ESX.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	ESX.TimeoutCount = id

	return id
end

ESX.ItemsToUpdate = {}

ESX.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
	if type(name) == 'table' then
		for k,v in ipairs(name) do
			ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
		end

		return
	end

	if ESX.RegisteredCommands[name] then

		if ESX.RegisteredCommands[name].suggestion then
			TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name))
		end
	end

	if suggestion then
		if not suggestion.arguments then suggestion.arguments = {} end
		if not suggestion.help then suggestion.help = '' end

		TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
	end

	ESX.RegisteredCommands[name] = {group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion}

	RegisterCommand(name, function(playerId, args, rawCommand)
		local command = ESX.RegisteredCommands[name]

		if not command.allowConsole and playerId == 0 then
		
		else
			local xPlayer, error = ESX.GetPlayerFromId(playerId), nil

			if command.suggestion then
				if command.suggestion.validate then
					if #args ~= #command.suggestion.arguments then
						error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
					end
				end

				if not error and command.suggestion.arguments then
					local newArgs = {}

					for k,v in ipairs(command.suggestion.arguments) do
						if v.type then
							if v.type == 'number' then
								local newArg = tonumber(args[k])

								if newArg then
									newArgs[v.name] = newArg
								else
									error = _U('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'player' or v.type == 'playerId' then
								local targetPlayer = tonumber(args[k])

								if args[k] == 'me' then targetPlayer = playerId end

								if targetPlayer then
									local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

									if xTargetPlayer then
										if v.type == 'player' then
											newArgs[v.name] = xTargetPlayer
										else
											newArgs[v.name] = targetPlayer
										end
									else
										error = _U('commanderror_invalidplayerid')
									end
								else
									error = _U('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'string' then
								newArgs[v.name] = args[k]
							elseif v.type == 'item' then
								if ESX.Items[args[k]] then
									newArgs[v.name] = args[k]
								else
									error = _U('commanderror_invaliditem')
								end
							elseif v.type == 'weapon' then
								if ESX.GetWeapon(args[k]) then
									newArgs[v.name] = string.upper(args[k])
								else
									error = _U('commanderror_invalidweapon')
								end
							elseif v.type == 'any' then
								newArgs[v.name] = args[k]
							end
						end

						if error then break end
					end

					args = newArgs
				end
			end

			if error then
				if playerId == 0 then
				else
					xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', error}})
				end
			else
				cb(xPlayer or false, args, function(msg)
					if playerId == 0 then
					else
						xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', msg}})
					end
				end)
			end
		end
	end, true)

	if type(group) == 'table' then
		for k,v in ipairs(group) do
			ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
		end
	else
		ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
	end
end

ESX.ClearTimeout = function(id)
	ESX.CancelledTimeouts[id] = true
end

ESX.RegisterServerCallback = function(name, cb)
	ESX.ServerCallbacks[name] = cb
end

ESX.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if ESX.ServerCallbacks[name] then
		ESX.ServerCallbacks[name](source, cb, ...)
	end
end

ESX.SavePlayer = function(xPlayer, cb)
	local asyncTasks = {}

	if xPlayer ~= nil then
		table.insert(asyncTasks, function(cb2)
			MySQL.prepare('UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `secondjob` = ?, `secondjob_grade` = ?, `thirdjob` = ?, `thirdjob_grade` = ?, `slot` = ?, `dealerLevel` = ?, `group` = ?, `position` = ?, `inventory` = ? WHERE `identifier` = ? AND digit = ?', {
				json.encode(xPlayer.getAccounts(true)),
				xPlayer.job.name,
				xPlayer.job.grade,
				xPlayer.secondjob.name,
				xPlayer.secondjob.grade,
				xPlayer.thirdjob.name,
				xPlayer.thirdjob.grade,
				json.encode(xPlayer.getSlots()),
				json.encode(xPlayer.getDealerLevel()),
				xPlayer.group,
				json.encode(xPlayer.getCoords()),
				json.encode(xPlayer.getInventory(true)),
				xPlayer.identifier,
				xPlayer.getDigit(),
			}, function(rowsChanged)
				cb2()
			end)
		end)
	end

	Async.parallel(asyncTasks, function(results)
		if cb then
			cb()
		end
	end)
end

ESX.SavePlayers = function(cb)
	local xPlayers, asyncTasks = ESX.GetExtendedPlayers(), {}

	for i=1, #xPlayers, 1 do
		table.insert(asyncTasks, function(cb2)
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			ESX.SavePlayer(xPlayer, cb2)
		end)
	end

	Async.parallelLimit(asyncTasks, 8, function(results)
		if cb then
			cb()
		end
	end)
end
function ESX.GetPlayers()
	local sources = {}

	for k,v in pairs(ESX.Players) do
		sources[#sources + 1] = k
	end

	return sources
end	

ESX.GetExtendedPlayers = function(key, val)
	local xPlayers = {}
	for k, v in pairs(ESX.Players) do
		if key then
			if (key == 'job' and v.job.name == val) or v[key] == val then
				xPlayers[#xPlayers + 1] = v
			end
		else
			xPlayers[#xPlayers + 1] = v
		end
	end
	return xPlayers
end

function ESX.GetIdentifier(playerId)
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			local identifier = string.gsub(v, 'license:', '')
			return identifier
		end
	end
end

ESX.GetPlayerFromId = function(source)
	return ESX.Players[tonumber(source)]
end

ESX.GetPlayerFromIdentifier = function(identifier)
	for k,v in pairs(ESX.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

ESX.RegisterUsableItem = function(item, cb)
	ESX.UsableItemsCallbacks[item] = cb
end

ESX.UseItem = function(source, item)
	if ESX.Items[item] then
		--if ESX.UsableItemsCallbacks[item] then
			ESX.UsableItemsCallbacks[item](source, item)
		--end
	else
		print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(item))
	end
end

ESX.GetItemLabel = function(item)
	if ESX.Items[item] then
		return ESX.Items[item].label
	end
end

ESX.DoesJobExist = function(job, grade)
	grade = tostring(grade)

	if job and grade then
		if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end

RegisterNetEvent('esx:updateItem')
AddEventHandler('esx:updateItem', function(item, key, value)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer ~= nil then
		for k,v in pairs(xPlayer.getInventory(false)) do
			if v.name == item then
				v.data[key] = value
			end
		end		
		
		if ESX.Items[item] then
			ESX.Items[item].data[key] = value
			
			ESX.ItemsToUpdate[item] = true
		end
		
	end
end)

ESX.GetItems = function()
	return ESX.Items
end

ESX.SetItemsData = function(item, key, value)
	if ESX.Items[item] then
		ESX.Items[item].data[key] = value
		
		ESX.ItemsToUpdate[item] = true
	end
end

RegisterNetEvent('esx:updateItemMultiple')
AddEventHandler('esx:updateItemMultiple', function(data)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer ~= nil then
		for k,v in pairs(data) do			
			for k2,v2 in pairs(xPlayer.getInventory(false)) do
				if k == v2.name then
					v2.data.ammo = v
					
					ESX.ItemsToUpdate[v2.name] = true
				end
			end		
		end
	end
end)

ESX.SaveItems = function()
	local asyncTasks = {}
	
	for name, value in pairs(ESX.ItemsToUpdate) do
		if value then
			table.insert(asyncTasks, function(cb2)
				ESX.SaveItem(name, cb2)
			end)
		end
	end

	Async.parallelLimit(asyncTasks, 8, function(results)
		ESX.ItemsToUpdate = {}
		
		if cb then
			cb()
		end
	end)	
end

ESX.SaveItem = function(name, cb)
	local asyncTasks = {}

	if name ~= nil then
		table.insert(asyncTasks, function(cb2)
			local data = ESX.Items[name]
			
			if data ~= nil then
				MySQL.update('UPDATE items SET data = ? WHERE `name` = ?', {name, json.encode(data.data)}, function(rowsChanged)				
					cb2()
				end)
			else
				cb2()
			end
		end)

		Async.parallel(asyncTasks, function(results)

			if cb then
				cb()
			end
		end)
	end
end

RegisterNetEvent('es_extended:DoUpdateItems')
AddEventHandler('es_extended:DoUpdateItems', function()
	ESX.SaveItems()
end)