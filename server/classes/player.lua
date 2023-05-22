function CreateExtendedPlayer(playerId, identifier, group, accounts, inventory, job, name, coords, character, secondjob, thirdjob, dealerLevel, digit, slots, loadout)
	local self = {}

	self.accounts = accounts
	self.coords = coords
	self.group = group
	self.identifier = identifier
	self.inventory = inventory
	self.character = character
	self.job = job
	self.secondjob = secondjob
	self.thirdjob = thirdjob
	self.dealerLevel = dealerLevel
	self.name = name
	self.playerId = playerId
	self.source = playerId
	self.variables = {}
	self.digit = digit
	self.slot = slots
	self.loadout = loadout
	--self.skills = skills
	ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))

	self.getDealerLevel = function()
		return self.dealerLevel
	end
	self.addDealerLevel = function()
		if self.dealerLevel.level <= 25 then
			local currentLevel = self.dealerLevel.level
			local currentPoints = self.dealerLevel.points
			if currentPoints >= 50 then
				currentLevel = currentLevel + 1
				currentPoints = 0
				if currentLevel < 25 then
					self.triggerEvent('esx:showNotification', "Teraz jesteś bardziej ~y~przekonywujący~w~ przy ~b~dealowaniu!~y~ [" .. currentLevel .. "/25]")
				elseif currentLevel == 25 then
					self.triggerEvent('esx:showNotification', "Osiągnąłeś maksymalny poziom ~y~perswazji~w~ przy ~b~dealowaniu!~y~ [" .. currentLevel .. "/25]")
				end
			else
				currentPoints = currentPoints + 1
			end
			self.dealerLevel.level = currentLevel
			self.dealerLevel.points = currentPoints
		end
	end
	--[[self.getSkill = function()
		return self.skills
	end
	self.getSkills = function()
		return self.skills
	end]]

	self.setSlots = function(val)
		self.slot = val
	end
	
	self.getSlots = function()
		return self.slot
	end
	
	--[[self.setSkill = function(val, val2)
		self.skills[val] = val2
		TriggerClientEvent('esx:setSkills', self.source, self.getSkill())
	end

	self.addSkill = function(val, val2)
			if self.skills[val] < 10000 then
				local toadd = self.getSkill()[val]
				self.skills[val] = toadd + val2
			else
				self.skills[val] = 10000
			end
			
		TriggerClientEvent('esx:setSkills', self.source, self.getSkill())
	end]]

	self.getDigit = function()
		return self.digit
	end

	self.setDigit = function(dig)
		self.digit = dig
	end
	
	self.setCharacter = function(val, val2)
		self.character[val] = val2
	end

	self.getSecondJob = function()
		return self.secondjob
	end

	self.getThirdJob = function()
		return self.thirdjob
	end
	
	self.getCharacter = function()
		return self.character
	end

	self.setSecondJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.secondjob))

		if ESX.DoesJobExist(job, grade) then
			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

			self.secondjob.id    = jobObject.id
			self.secondjob.name  = jobObject.name
			self.secondjob.label = jobObject.label

			self.secondjob.grade        = tonumber(grade)
			self.secondjob.grade_name   = gradeObject.name
			self.secondjob.grade_label  = gradeObject.label
			self.secondjob.grade_salary = gradeObject.salary

			self.secondjob.skin_male    = {}
			self.secondjob.skin_female  = {}

			if gradeObject.skin_male then
				self.secondjob.skin_male = json.decode(gradeObject.skin_male)
			else
				self.secondjob.skin_male = {}
			end

			if gradeObject.skin_female then
				self.secondjob.skin_female = json.decode(gradeObject.skin_female)
			else
				self.secondjob.skin_female = {}
			end

			TriggerEvent('esx:setSecondJob', self.source, self.secondjob, lastJob)
			self.triggerEvent('esx:setSecondJob', self.secondjob)
			--TriggerClientEvent('esx:setSecondJob', self.source, self.secondjob)
		end
	end
	
	self.setThirdJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.thirdjob))

		if ESX.DoesJobExist(job, grade) then
			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

			self.thirdjob.id    = jobObject.id
			self.thirdjob.name  = jobObject.name
			self.thirdjob.label = jobObject.label

			self.thirdjob.grade        = tonumber(grade)
			self.thirdjob.grade_name   = gradeObject.name
			self.thirdjob.grade_label  = gradeObject.label
			self.thirdjob.grade_salary = gradeObject.salary

			self.thirdjob.skin_male    = {}
			self.thirdjob.skin_female  = {}

			if gradeObject.skin_male then
				self.thirdjob.skin_male = json.decode(gradeObject.skin_male)
			else
				self.thirdjob.skin_male = {}
			end

			if gradeObject.skin_female then
				self.thirdjob.skin_female = json.decode(gradeObject.skin_female)
			else
				self.thirdjob.skin_female = {}
			end

			TriggerEvent('esx:setThirdJob', self.source, self.thirdjob, lastJob)
			self.triggerEvent('esx:setThirdJob', self.thirdjob)
		end
	end

	self.triggerEvent = function(eventName, ...)
		TriggerClientEvent(eventName, self.source, ...)
	end

	self.setCoords = function(coords)
		self.updateCoords(coords)
		self.triggerEvent('esx:teleport', coords)
	end

	self.updateCoords = function(coords)
		self.coords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1), heading = ESX.Math.Round(coords.heading or 0.0, 1)}
	end

	self.getCoords = function(vector)
		if vector then
			return vector3(self.coords.x, self.coords.y, self.coords.z)
		else
			return self.coords
		end
	end

	self.kick = function(reason)
		DropPlayer(self.source, reason)
	end

	self.setMoney = function(money)
		money = ESX.Math.Round(money)
		self.setAccountMoney('money', money)
	end

	self.getMoney = function()
		return self.getAccount('money').money
	end

	self.getNumber = function()

		local result = MySQL.query.await('SELECT defaultNumber FROM phone_numbers WHERE identifier = "' .. self.identifier .. '"', {})
		
		if(result) then
			return result[1].defaultNumber
		else
			return "Brak"
		end
	end

	self.getIBAN = function()
		local result = MySQL.query.await('SELECT iban FROM users WHERE identifier = "' .. self.identifier .. '"', {})
		
		if(result) then
			return result[1].iban
		else
			return 'Brak'
		end
 	end

	self.addMoney = function(money)
		money = ESX.Math.Round(money)
		self.addAccountMoney('money', money)
	end

	self.removeMoney = function(money)
		money = ESX.Math.Round(money)
		self.removeAccountMoney('money', money)
	end

	self.getIdentifier = function()
		return self.identifier
	end

	self.setGroup = function(newGroup)
		ExecuteCommand(('remove_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
		self.group = newGroup
		ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(self.identifier, self.group))
		
		self.triggerEvent('esx:setGroup', self.group)
	end

	self.getGroup = function()
		return self.group
	end

	self.set = function(k, v)
		self.variables[k] = v
	end

	self.get = function(k)
		return self.variables[k]
	end

	self.getAccounts = function(minimal)
		if minimal then
			local minimalAccounts = {}

			for k,v in ipairs(self.accounts) do
				minimalAccounts[v.name] = v.money
			end

			return minimalAccounts
		else
			return self.accounts
		end
	end

	self.getAccount = function(account)
		for k,v in ipairs(self.accounts) do
			if v.name == account then
				return v
			end
		end
	end

	self.getInventory = function(minimal)
		if minimal then
			local minimalInventory = {}

			for k,v in ipairs(self.inventory) do
				if v.count > 0 then
					minimalInventory[v.name] = v.count
				end
			end

			return minimalInventory
		else
			return self.inventory
		end
	end

	self.getJob = function()
		return self.job
	end

	self.getName = function()
		return self.name
	end

	self.setName = function(newName)
		self.name = newName
	end

	self.setAccountMoney = function(accountName, money)
		local account = self.getAccount(accountName)

		if account then
			local prevMoney = account.money
			local newMoney = ESX.Math.Round(money)
			account.money = newMoney

			self.triggerEvent('esx:setAccountMoney', account)
		end
	end

	self.addAccountMoney = function(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money + ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

	self.removeAccountMoney = function(accountName, money)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money - ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
			end
		end
	end

	self.getInventoryItem = function(name2)
		for k,v in ipairs(self.inventory) do			
			if v.name == name2 then
				return v
			end
		end
		
		-- not found item	
		local item = ESX.Items[name2]
		if item ~= nil then
			if type(item.data) =='string' then
				item.data = json.decode(item.data)
			end
						
			table.insert(self.inventory, {
				name = name2,
				count = 0,
				label = item.label,
				limit = item.limit,
				usable = ESX.UsableItemsCallbacks[name2] ~= nil,
				rare = item.rare,
				canRemove = item.canRemove,
				type = item.type,
				data = item.data
			})
		end

		-- 1 more try find item
		for k,v in ipairs(self.inventory) do			
			if v.name == name2 then
				return v
			end
		end

		return false
	end

	self.addInventoryItem = function(name, count)
		local item = self.getInventoryItem(name)
		
		if item then
			count = ESX.Math.Round(count)
			item.count = item.count + count

			TriggerEvent('esx:onAddInventoryItem', self.source, item.name, item.count)
			self.triggerEvent('esx:addInventoryItem', item, item.count)
		end
	end
	
	self.removeInventoryItem = function(name, count, showNotification)
		local item = self.getInventoryItem(name)

		if item then
			count = ESX.Math.Round(count)
			local newCount = item.count - count

			if newCount >= 0 and count > 0 then
				item.count = newCount

				TriggerEvent('esx:onRemoveInventoryItem', self.source, item.name, item.count, showNotification)
				self.triggerEvent('esx:removeInventoryItem', item, item.count, showNotification)
			end

		end
	end

	self.setInventoryItem = function(name, count)
		local item = self.getInventoryItem(name)

		if item and count >= 0 then
			count = ESX.Math.Round(count)

			if count > item.count then
				self.addInventoryItem(item.name, count - item.count)
			else
				self.removeInventoryItem(item.name, item.count - count)
			end
		end
	end

	self.setJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.job))

		if ESX.DoesJobExist(job, grade) then
			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

			self.job.id    = jobObject.id
			self.job.name  = jobObject.name
			self.job.label = jobObject.label

			self.job.grade        = tonumber(grade)
			self.job.grade_name   = gradeObject.name
			self.job.grade_label  = gradeObject.label
			self.job.grade_salary = gradeObject.salary

			if gradeObject.skin_male then
				self.job.skin_male = json.decode(gradeObject.skin_male)
			else
				self.job.skin_male = {}
			end

			if gradeObject.skin_female then
				self.job.skin_female = json.decode(gradeObject.skin_female)
			else
				self.job.skin_female = {}
			end

			TriggerEvent('esx:setJob', self.source, self.job, lastJob)
			self.triggerEvent('esx:setJob', self.job)
		end
	end
	
	self.showNotification = function(msg, flash, saveToBrief, hudColorIndex)
		self.triggerEvent('esx:showNotification', msg, flash, saveToBrief, hudColorIndex)
	end

	self.showHelpNotification = function(msg, thisFrame, beep, duration)
		self.triggerEvent('esx:showHelpNotification', msg, thisFrame, beep, duration)
	end

	function self.getLoadout(minimal)
		if minimal then
			local minimalLoadout = {}

			for k,v in ipairs(self.loadout) do
				minimalLoadout[v.name] = {ammo = v.ammo}
				if v.tintIndex > 0 then minimalLoadout[v.name].tintIndex = v.tintIndex end

				if #v.components > 0 then
					local components = {}

					for k2,component in ipairs(v.components) do
						if component ~= 'clip_default' then
							components[#components + 1] = component
						end
					end

					if #components > 0 then
						minimalLoadout[v.name].components = components
					end
				end
			end

			return minimalLoadout
		else
			return self.loadout
		end
	end

	function self.addWeapon(weaponName, ammo)
		if not self.hasWeapon(weaponName) then
			local weaponLabel = ESX.GetWeaponLabel(weaponName)

			table.insert(self.loadout, {
				name = weaponName,
				ammo = ammo,
				label = weaponLabel,
				components = {},
				tintIndex = 0
			})

			self.triggerEvent('esx:addWeapon', weaponName, ammo)
			self.triggerEvent('esx:addInventoryItem', weaponLabel, false, true)
		end
	end

	function self.hasWeapon(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return true
			end
		end

		return false
	end

	function self.getWeapon(weaponName)
		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return k, v
			end
		end
	end

	function self.addWeaponAmmo(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo + ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	function self.updateWeaponAmmo(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			if ammoCount < weapon.ammo then
				weapon.ammo = ammoCount
			end
		end
	end

	function self.removeWeapon(weaponName)
		local weaponLabel

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				weaponLabel = v.label

				for k2,v2 in ipairs(v.components) do
					self.removeWeaponComponent(weaponName, v2)
				end

				table.remove(self.loadout, k)
				break
			end
		end

		if weaponLabel then
			self.triggerEvent('esx:removeWeapon', weaponName)
			self.triggerEvent('esx:removeInventoryItem', weaponLabel, false, true)
		end
	end

	function self.removeWeaponAmmo(weaponName, ammoCount)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo - ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	self.canCarryItem = function(name, count)		
		local item, limit = self.getInventoryItem(name), ESX.Items[name].limit
		
		if item and limit then
			count = ESX.Math.Round(count)
			local newCount = item.count + count
			
			return newCount <= limit
		end
	end
	
	return self
end