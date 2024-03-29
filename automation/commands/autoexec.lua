local Command = require('Command')
local Event = require('Event')

local table_concat = table.concat
local table_remove = table.remove
local table_insert = table.insert

local tonumber = tonumber
local next = next

Event:registerReadOnlyPlayerJoin(function(ply)
	if ply.autoexec then
		for _, cmd in next, ply.autoexec do
			ply:chat(cmd)
		end
	end
end)

Command:register{
	name = 'autoexec',
	run = function(_, ply, args)
		local method = args[1]
		if not ply.autoexec then
			ply.autoexec = {}
		end
		if method == 'add' then
			local argsConcat = table_concat(args, ' ', 2)
			table_insert(ply.autoexec, argsConcat)
			ply:sendReply('Added "' .. argsConcat .. '" to your autoexec')
		elseif method == 'remove' then
			local id = tonumber(args[2])
			local cmd = table_remove(ply.autoexec, id)
			if not cmd then
				ply:sendError('Invalid id')
			else
				ply:sendReply('Removed "' .. cmd .. '" from your autoexec')
			end
		elseif not method or method == 'list' then
			ply:sendReply('- AUTOEXEC START -')
			for id, cmd in next, ply.autoexec do
				ply:sendReply(tostring(id) .. ') ' .. cmd)
			end
			ply:sendReply('- AUTOEXEC END -')
			return
		else
			ply:sendError('Invalid method')
			return
		end
		ply:__save()
	end,
}
