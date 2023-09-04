local Command = require('Command')
local Permission = require('Permission')
local Spawnpoint = require('Spawnpoint')
local Homepoint = require('Homepoint')
local Locationstack = require('Locationstack')

Command:register{
	name = 'banish',
	action = {
		format = '%s teleported %s to the spawnpoint%s',
		isProperty = false,
		broadcast = true,
	},
	arguments = { {
		name = 'target',
		type = 'players',
		immunityRequirement = Permission.Immunity.GREATER,
	} },
	run = function(self, ply, args, flags)
		local resetHome = flags:contains('r')
		for _, target in next, args.target do
			Locationstack:clear(ply)
			if resetHome then
				target:clearHomes()
				target:setBedSpawnLocation(nil, true)
			end
			target:teleportToSpawn()
		end
		self:sendActionReply(ply, args.target, {}, resetHome and ' (and reset all homes)' or '')
	end,
}
