local Permission = require('Permission')

local warps = require('Persister'):get('warps')

local WarpMode = {
	PRIVATE = 1,
	PUBLIC = 2,
	PERMISSION = 3,
}

local Warp

local _warp_mt = {
	__metatable = false,
	__newindex = function()
		error('Readonly')
	end,
	isAllowed = function(self, ply)
		if self:canModify(ply) or (ply:hasPermission(
			'foxbukkit.teleportation.warp.override.teleport'
		) and ply:fitsImmunityRequirement(self.owner, Permission.Immunity.GREATER_OR_EQUAL)) then
			return true
		end

		if self.mode == WarpMode.PUBLIC then
			return true
		elseif self.mode == WarpMode.PERMISSION then
			return ply:hasPermission(self.permission)
		elseif self.mode == WarpMode.PRIVATE then
			return self.guests[ply:getUniqueId()]
		end
	end,
	canModify = function(self, ply)
		return ply:getUniqueId() == self.owner or self.ops[ply:getUniqueId()] or (ply:hasPermission(
			'foxbukkit.teleportation.warp.override.modify'
		) and ply:fitsImmunityRequirement(self.owner, Permission.Immunity.GREATER))
	end,
	addOp = function(self, ply)
		self.ops[ply:getUniqueId()] = true
	end,
	removeOp = function(self, ply)
		self.ops[ply:getUniqueId()] = nil
	end,
	addGuest = function(self, ply)
		self.guests[ply:getUniqueId()] = true
	end,
	removeGuest = function(self, ply)
		self.guests[ply:getUniqueId()] = nil
	end,
	delete = function(self)
		Warp:delete(self)
	end,
	save = function()
		warps:__save()
	end,
}

_warp_mt.__index = _warp_mt

for k, v in pairs(warps.__value) do
	if not v.guests then
		v.guests = {}
	end
	if not v.ops then
		v.ops = {}
	end
	if not v.permission then
		v.permission = ''
	end
	if not v.hidden then
		v.hidden = false
	end
	warps.__value[k] = setmetatable(v, _warp_mt)
end

Warp = {
	get = function(_, name)
		return warps[name:lower()]
	end,
	make = function(_, name, ply)
		local warp = setmetatable(
			{
				owner = ply:getUniqueId(),
				location = ply:getLocation(),
				name = name,
				guests = {},
				ops = {},
				hidden = false,
				permission = '',
				mode = Warp.Mode.PRIVATE,
			},
			_warp_mt
		)
		warps[name:lower()] = warp
		return warp
	end,
	add = function(_, warp)
		warps[warp.name:lower()] = warp
	end,
	delete = function(_, warp)
		if type(warp) ~= 'string' then
			warp = warp.name:lower()
		end
		warps[warp] = nil
	end,
	getAll = function()
		return warps.__value
	end,
	Mode = WarpMode,
}

return Warp
