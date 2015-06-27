local Command = require("Command")
local Permission = require("Permission")
local Spawnpoint = require("Spawnpoint")

Command:register{
	name = "setspawn",
	action = {
		format = "%s set the spawnpoint of group %s",
		isProperty = false,
		broadcast = true
	},
	arguments = {
		{
			name = "group",
			type = "string"
		}
	},
	run = function(self, ply, args)
		if args.group == "default" or Permission:getGroupImmunityLevel(args.group) < ply:getImmunityLevel() then
			local location = nil
			if not flags:has("d") then
				location = ply:getLocation()
			end
			Spawnpoint:setGroupSpawn(args.group, location)
			self:sendActionReply(ply, nil, {}, args.group)
		else
			ply:sendError("Permission denied")
		end
	end
}