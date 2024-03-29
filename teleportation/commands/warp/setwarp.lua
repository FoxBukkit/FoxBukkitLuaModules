local Command = require('Command')
local Player = require('Player')
local Warp = require('Warp')

Command:register{
	name = 'setwarp',
	action = { format = "%s changed warp %s's property %s to value %s" },
	arguments = { {
		name = 'name',
		type = 'string',
	}, {
		name = 'property',
		type = 'string',
	}, {
		name = 'value',
		type = 'string',
		required = false,
	} },
	run = function(self, ply, args)
		local warp = Warp:get(args.name)
		if not warp then
			ply:sendError('Warp not found')
			return
		end
		if not warp:canModify(ply) then
			ply:sendError('Permission denied')
			return
		end

		local property = args.property:lower()

		if property == 'location' then
			warp.location = ply:getLocation()
			self:sendActionReply(ply, nil, { format = '%s moved warp %s' }, warp.name)
			warp:save()
			return
		elseif property == 'delete' then
			warp:delete()
			self:sendActionReply(ply, nil, { format = '%s deleted warp %s' }, warp.name)
			return
		end

		if not args.value then
			ply:sendError('Missing new value')
			return
		end

		local value = args.value
		local override = {}

		if property == 'addguest' then
			local target = Player:findSingle(Player.constraints.matchName(value))
			if not target then
				ply:sendError('Player not found')
				return
			end
			override = { format = 'added guest to warp %s: %s%s' }
			property = ''
			value = target
			warp:addGuest(target)
		elseif property == 'removeguest' then
			local target = Player:findSingle(Player.constraints.matchName(value))
			if not target then
				ply:sendError('Player not found')
				return
			end
			override = { format = 'removed guest from warp %s: %s%s' }
			property = ''
			value = target
			warp:removeGuest(target)
		elseif property == 'addop' then
			local target = Player:findSingle(Player.constraints.matchName(value))
			if not target then
				ply:sendError('Player not found')
				return
			end
			override = { format = 'added op to warp %s: %s%s' }
			property = ''
			value = target
			warp:addOp(target)
		elseif property == 'removeop' then
			local target = Player:findSingle(Player.constraints.matchName(value))
			if not target then
				ply:sendError('Player not found')
				return
			end
			override = { format = 'removed op from warp %s: %s%s' }
			property = ''
			value = target
			warp:removeOp(target)
		elseif property == 'owner' then
			local target = Player:findSingle(Player.constraints.matchName(value))
			if not target then
				ply:sendError('Player not found')
				return
			end
			value = target
			warp.owner = target
		elseif property == 'permission' then
			warp.permission = value
		elseif property == 'hidden' then
			local hidden = Command.BOOL_VALUES[value:lower()]
			if hidden == nil then
				ply:sendError('No bool-y expression!')
				return
			end
			warp.hidden = hidden
		elseif property == 'mode' then
			local mode = Warp.Mode[value:upper()]
			if not mode then
				ply:sendError('Mode not found (private, public, permission)')
				return
			end
			warp.mode = mode
		elseif property == 'name' then
			warp:delete()
			warp.name = value
			Warp:add(warp)
		end
		warp:save()

		self:sendActionReply(ply, nil, override, warp.name, property, value)
	end,
}
