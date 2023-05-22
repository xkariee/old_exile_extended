ESX.RegisterCommand({'setcoords', 'tp'}, {'best', 'superadmin', 'admin'}, function(xPlayer, args, showError)
	xPlayer.setCoords({x = args.x, y = args.y, z = args.z})
end, false, {help = _U('command_setcoords'), validate = true, arguments = {
	{name = 'x', help = _U('command_setcoords_x'), type = 'number'},
	{name = 'y', help = _U('command_setcoords_y'), type = 'number'},
	{name = 'z', help = _U('command_setcoords_z'), type = 'number'}
}})

ESX.RegisterCommand('setjob', {'best', 'superadmin', 'admin', 'starszyadmin', 'starszymod', 'mod'}, function(xPlayer, args, showError)
	if xPlayer then
		if ESX.DoesJobExist(args.job, args.grade) then
			args.playerId.setJob(args.job, args.grade)
			exports['e-logs']:SendLog(xPlayer.source, "Użyto komendy /setjob " .. args.playerId.source .. " " .. args.job .. " " .. args.grade, "job")
		else
			showError(_U('command_setjob_invalid'))
		end
	else
		args.playerId.setJob(args.job, args.grade)
		showError(_U('command_setjob_invalid'))
	end
end, true, {help = _U('command_setjob'), validate = true, arguments = {
    {name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
    {name = 'job', help = _U('command_setjob_job'), type = 'string'},
    {name = 'grade', help = _U('command_setjob_grade'), type = 'number'}
}})

ESX.RegisterCommand('giveweaponcomponent', {'dev', 'best', 'superadmin'}, function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weaponName) then
		local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

		if component then
			if xPlayer.hasWeaponComponent(args.weaponName, args.componentName) then
				showError(_U('command_giveweaponcomponent_hasalready'))
			else
				xPlayer.addWeaponComponent(args.weaponName, args.componentName)
			end
		else
			showError(_U('command_giveweaponcomponent_invalid'))
		end
	else
		showError(_U('command_giveweaponcomponent_missingweapon'))
	end
end, true, {help = _U('command_giveweaponcomponent'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'weaponName', help = _U('command_giveweapon_weapon'), type = 'weapon'},
	{name = 'componentName', help = _U('command_giveweaponcomponent_component'), type = 'string'}
}})

ESX.RegisterCommand('setsecondjob', {'best', 'superadmin', 'admin', 'starszyadmin', 'starszymod', 'mod'}, function(xPlayer, args, showError)
	if xPlayer then
		if ESX.DoesJobExist(args.job, args.grade) then
			args.playerId.setSecondJob(args.job, args.grade)
			exports['e-logs']:SendLog(xPlayer.source, "Użyto komendy /setsecondjob " .. args.playerId.source .. " " .. args.job .. " " .. args.grade, "job")
		else
			showError(_U('command_setjob_invalid'))
		end
	else
		args.playerId.setSecondJob(args.job, args.grade)
		showError(_U('command_setjob_invalid'))
	end
end, true, {help = _U('command_setjob'), validate = true, arguments = {
    {name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
    {name = 'job', help = _U('command_setjob_job'), type = 'string'},
    {name = 'grade', help = _U('command_setjob_grade'), type = 'number'}
}})

ESX.RegisterCommand('setthirdjob', {'best', 'superadmin', 'admin', 'starszyadmin', 'starszymod', 'mod'}, function(xPlayer, args, showError)
	if xPlayer then
		if ESX.DoesJobExist(args.job, args.grade) then
			args.playerId.setThirdJob(args.job, args.grade)
			exports['e-logs']:SendLog(xPlayer.source, "Użyto komendy /setthirdjob " .. args.playerId.source .. " " .. args.job .. " " .. args.grade, "job")
		else
			showError(_U('command_setjob_invalid'))
		end
	else
		args.playerId.setThirdJob(args.job, args.grade)
		showError(_U('command_setjob_invalid'))
	end
end, true, {help = _U('command_setjob'), validate = true, arguments = {
    {name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
    {name = 'job', help = _U('command_setjob_job'), type = 'string'},
    {name = 'grade', help = _U('command_setjob_grade'), type = 'number'}
}})

ESX.RegisterCommand('car', {'best', 'cardev', 'superadmin', 'admin', 'starszyadmin', 'starszymod', 'mod'}, function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx:spawnVehicle', args.car)
	exports['e-logs']:SendLog(xPlayer.source, "Użyto komendy /car " .. args.car, "car")
end, false, {help = _U('command_car'), validate = false, arguments = {
	{name = 'car', help = _U('command_car_car'), type = 'any'}
}})

ESX.RegisterCommand({'cardel', 'dv'}, {'best', 'cardev', 'superadmin', 'admin', 'starszyadmin', 'starszymod', 'mod', 'support', 'trialsupport'}, function(xPlayer, args, showError)
	if not args.radius then args.radius = 4 end
	xPlayer.triggerEvent('esx:deleteVehicle', args.radius)
end, false, {help = _U('command_cardel'), validate = false, arguments = {
	{name = 'radius', help = _U('command_cardel_radius'), type = 'any'}
}})

ESX.RegisterCommand('setaccountmoney', {'best', 'starszyadmin', 'superadmin', 'admin'}, function(xPlayer, args, showError)
	if args.playerId.getAccount(args.account) then
		if xPlayer then
			args.playerId.setAccountMoney(args.account, args.amount)
			exports['e-logs']:SendLog(xPlayer.source, "Użyto komendy /setaccountmoney " .. args.playerId.source .. " " .. args.account .. " " .. args.amount, "givemoney")
		end
	else
		showError(_U('command_giveaccountmoney_invalid'))
	end
end, true, {help = _U('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_setaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveaccountmoney', {'best', 'starszyadmin', 'superadmin', 'admin'}, function(xPlayer, args, showError)
	if xPlayer then
		if args.playerId.getAccount(args.account) then
			args.playerId.addAccountMoney(args.account, args.amount)
			exports['e-logs']:SendLog(xPlayer.source, "Użyto komendy /giveaccountmoney " .. args.playerId.source .. " " .. args.account .. " " .. args.amount, "givemoney")
		else
			showError(_U('command_giveaccountmoney_invalid'))
		end
	else
		args.playerId.addAccountMoney(args.account, args.amount)
	end
end, true, {help = _U('command_giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_giveaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveitem', {'best', 'superadmin', 'admin', 'starszyadmin', 'starszymod', 'mod'},  function(xPlayer, args, showError)
	if xPlayer then
		args.playerId.addInventoryItem(args.item, args.count)
		exports['e-logs']:SendLog(xPlayer.source, "Użyto komendy /giveitem " .. args.playerId.source .. " " .. args.item .. " " .. args.count, "item")
	else
		args.playerId.addInventoryItem(args.item, args.count)
	end
end, true, {help = _U('command_giveitem'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'item', help = _U('command_giveitem_item'), type = 'item'},
	{name = 'count', help = _U('command_giveitem_count'), type = 'number'}
}})

ESX.RegisterCommand('clear', {'user', 'trialsupport', 'support', 'mod', 'starszymod', 'admin', 'starszyadmin', 'superadmin', 'best'}, function(xPlayer, args, showError)
	if xPlayer then
		xPlayer.triggerEvent('chat:clear')
	end
end, false, {help = _U('command_clear')})

ESX.RegisterCommand('clearall', {'admin', 'starszyadmin', 'superadmin', 'best'}, function(xPlayer, args, showError)
	if xPlayer then
		TriggerClientEvent('chat:clear', -1)
	end
end, false, {help = _U('command_clearall')})

ESX.RegisterCommand('clearinventory', {'best', 'superadmin', 'admin', 'starszyadmin', 'starszymod', 'mod'}, function(xPlayer, args, showError)
	for k,v in ipairs(args.playerId.inventory) do
		if v.count > 0 then
			args.playerId.setInventoryItem(v.name, 0)
		end
	end
end, true, {help = _U('command_clearinventory'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('setgroup', {'best', 'superadmin'}, function(xPlayer, args, showError)
	args.playerId.setGroup(args.group)
end, true, {help = _U('command_setgroup'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'group', help = _U('command_setgroup_group'), type = 'string'},
}})

ESX.RegisterCommand('save', {'best', 'superadmin'}, function(xPlayer, args, showError)
	ESX.SavePlayer(args.playerId)
end, true, {help = _U('command_save'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('saveall', {'best', 'superadmin'}, function(xPlayer, args, showError)
	ESX.SavePlayers()
end, true, {help = _U('command_saveall')})

ESX.RegisterCommand('saveitems', {'best', 'superadmin'}, function(xPlayer, args, showError)
	ESX.SaveItems()
end, true, {help = _U('command_saveall')})
