AddEventHandler('exilerp:getSharedObject', function(cb)
	cb(ESX)
end)

function getSharedObject()
	return ESX
end

function getServer() 
	return GetConvar("serverType", "wloff")
end
