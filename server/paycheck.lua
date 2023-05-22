function StartPayCheck()
	CreateThread(function()
		while true do
			Wait(Config.PaycheckInterval)
			local xPlayers = ESX.GetExtendedPlayers()
			for _, xPlayer in pairs(xPlayers) do
				local job     = xPlayer.job.name
				local praca   = xPlayer.job.label
				local stopien = xPlayer.job.grade_label
				local salary  = xPlayer.job.grade_salary
				local secondjob = xPlayer.secondjob.name
				local secondpraca = xPlayer.secondjob.label
				local secondsalary = xPlayer.secondjob.grade_salary
				local thirdjob = xPlayer.thirdjob.name
				local thirdpraca = xPlayer.thirdjob.label
				local thirdsalary = xPlayer.thirdjob.grade_salary
				local additionalsalary = secondsalary + thirdsalary

				if xPlayer.group == 'vip' then
					salary = salary * 1.25
					secondsalary = secondsalary * 1.25
					thirdsalary = thirdsalary * 1.25
					additionalsalary = additionalsalary * 1.25
				end

				if salary > 0 then
					if job == 'unemployed' then
						xPlayer.addAccountMoney('bank', salary)
						if (secondjob ~= 'unemployed' and secondjob ~= job) and (thirdjob ~= 'unemployed' and thirdjob ~= job) then
							xPlayer.addAccountMoney('bank', additionalsalary)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~Zasiłek: ~g~'..salary..'$\n~y~' .. secondpraca .. ':~g~ ' .. secondsalary .. '$\n~y~' ..thirdpraca .. ':~g~ ' .. thirdsalary .. '$')
						elseif secondjob ~= 'unemployed' and secondjob ~= job then
							xPlayer.addAccountMoney('bank', secondsalary)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~Zasiłek: ~g~'..salary..'$\n~y~' .. secondpraca .. ':~g~ ' .. secondsalary .. '$')
						elseif thirdjob ~= 'unemployed' and thirdjob ~= job then
							xPlayer.addAccountMoney('bank', thirdsalary)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~Zasiłek: ~g~'..salary..'$\n~y~' .. thirdpraca .. ':~g~ ' .. thirdsalary .. '$')
						else
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~Zasiłek: ~g~'..salary..'$')
						end
					else
						xPlayer.addAccountMoney('bank', salary)
						if (secondjob ~= 'unemployed' and secondjob ~= job) and (thirdjob ~= 'unemployed' and thirdjob ~= job) then
							xPlayer.addAccountMoney('bank', additionalsalary)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~'..praca..' - '..stopien..':~g~ '..salary..'$\n~y~' .. secondpraca .. ':~g~ ' .. secondsalary .. '$\n~y~' ..thirdpraca .. ':~g~ ' .. thirdsalary .. '$')
						elseif secondjob ~= 'unemployed' and secondjob ~= job then
							xPlayer.addAccountMoney('bank', secondsalary)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~'..praca..' - '..stopien..':~g~ '..salary..'$\n~y~' .. secondpraca .. ':~g~ ' .. secondsalary .. '$')
						elseif thirdjob ~= 'unemployed' and thirdjob ~= job then
							xPlayer.addAccountMoney('bank', thirdsalary)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~'..praca..' - '..stopien..':~g~ '..salary..'$\n~y~' ..thirdpraca .. ':~g~ ' .. thirdsalary .. '$')
						else
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Bank', 'Konto bankowe: ~g~'..xPlayer.getAccount('bank').money..'$~s~', 'Wynagrodzenia:\n~y~'..praca..' - '..stopien..':~g~ '..salary..'$')	
						end
					end
				end
			end
		end
	end)
end