local Command = require('Command')
local Locationstack = require('Locationstack')

Command:register{
	name = 'home',
	action = {
		format = '%s went to %s home point %s',
		isProperty = true,
	},
	arguments = { {
		name = 'name',
		type = 'string',
		required = false,
		default = 'default',
	} },
	run = function(self, ply, args)
		if args.name == '-l' then
			local homeNames = {}
			for k, _ in pairs(ply:getHomes()) do
				table.insert(homeNames, k)
			end
			ply:sendReply('Homes: ' .. table.concat(homeNames, ', '))
			return
		end
		local home = ply:getHome(args.name)
		if not home then
			ply:sendError('Home not found')
			return
		end

		Locationstack:add(ply)
		ply:teleport(home)

		self:sendActionReply(ply, ply, {}, args.name)
	end,
}
