
-- Extended Ban Mod for Minetest
-- (C) 2013 Diego Martínez <kaeza>
-- See `LICENSE.txt' for details.

-- chat.lua: Chat commands.

minetest.register_chatcommand("xban", {
	params = "<player> [<reason>]",
	description = "Future ban all IPs for a given player",
	privs = { ban=true, },
	func = function(name, param)
		param = param:trim()
		local player_name, reason = param:match("([^ ]+)( *.*)")
		if not player_name then
			xban._.send(name, "Usage: /xban <player> [<reason>]")
			return
		end
		reason = reason:trim()
		if reason == "" then reason = nil end
		xban._.ACTION("%s bans player '%s'. Reason: %s", name, player_name, reason)
		local r, e = xban.ban_player(player_name, nil, reason)
		if r then
			xban._.send(name, "Success!")
		else
			xban._.send(name, "Error: %s", e)
		end
	end,
})

local mul = { [""]=1, s=1, m=60, h=60*60, d=60*60*24, W=60*60*24*7, M=60*60*24*30 }

local function parse_time(t)
	local total = 0
	for count, suffix in t:gmatch("(%d+)([mhdWM]?)") do
		count = count and tonumber(count)
		if count and suffix then
			total = (total or 0) + (count * mul[suffix])
		end
	end
	if total then return total end
end

minetest.register_chatcommand("xtempban", {
	params = "<player> <time> [<reason>]",
	description = "Future ban all IPs for a given player, temporarily",
	privs = { ban=true, },
	func = function(name, param)
		param = param:trim()
		local player_name, time, reason = param:match("([^ ]+) *([^ ]+)( *.*)")
		if not (player_name and time) then
			xban._.send(name, "Usage: /xtempban <player> <time> [<reason>]")
			return
		end
		time = parse_time(time)
		if not time then
			xban._.send(name, "Invalid time format. Syntax is: [0-9]+[mhdWM]")
			return
		elseif time < 60 then
			xban._.send(name, "Ban time must be at least 60 seconds.")
			return
		end
		reason = reason:trim()
		if reason == "" then reason = nil end
		xban._.ACTION("%s bans player '%s' for %d seconds. Reason: %s",
			name, player, time, reason
		)
		local r, e = xban.ban_player(player_name, time, reason)
		if r then
			xban._.send(name, "Success!")
		else
			xban._.send(name, "Error: %s", e)
		end
	end,
})

minetest.register_chatcommand("xunban", {
	params = "<player>",
	description = "Unban all IPs for a given player",
	privs = { ban=true, },
	func = function(name, param)
		param = param:trim()
		if param == "" then
			xban._.send(name, "Usage: /xunban <player>")
			return
		end
		local r, e = xban.unban_player(param)
		if r then
			xban._.send(name, "Success!")
		else
			xban._.send(name, "Error: %s", e)
		end
	end,
})
