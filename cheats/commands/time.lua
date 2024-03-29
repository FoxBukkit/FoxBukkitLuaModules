local Command = require('Command')
local Player = require('Player')
local Event = require('Event')

local fixedServerTime = nil

local function setPlayerFixedTime(ply)
	local time = ply._fixedTime or fixedServerTime
	if time and time >= 0 then
		if time < 6 then
			time = time + 18
		else
			time = time - 6
		end
		ply:setPlayerTime(time * 1000, false)
	else
		ply:resetPlayerTime()
	end
end

Event:registerReadOnlyPlayerJoin(setPlayerFixedTime)

Command:register{
	name = 'time',
	action = {
		format = '%s set %s time to %d:00',
		isProperty = true,
	},
	arguments = { {
		name = 'time',
		type = 'number',
		aliases = {
			day = 12,
			night = 0,
			none = -1,
		},
		required = false,
		default = -1,
	} },
	run = function(self, ply, args)
		local formatOverride = {}
		if args.time < 0 then
			ply._fixedTime = nil
			formatOverride.format = '%s reset %s time to server time'
		else
			ply._fixedTime = args.time
		end
		setPlayerFixedTime(ply)
		self:sendActionReply(ply, ply, formatOverride, args.time)
	end,
}

Command:register{
	name = 'servertime',
	action = {
		format = '%s set server time to %d:00',
		broadcast = true,
	},
	arguments = { {
		name = 'time',
		type = 'number',
		aliases = {
			day = 12,
			night = 0,
			none = -1,
		},
		required = false,
		default = -1,
	} },
	run = function(self, ply, args)
		fixedServerTime = args.time
		for _, otherPly in next, Player:getAll() do
			setPlayerFixedTime(otherPly)
		end
		local formatOverride = {}
		if args.time < 0 then
			formatOverride.format = '%s reset server time to normal time'
		end
		self:sendActionReply(ply, nil, formatOverride, args.time)
	end,
}
