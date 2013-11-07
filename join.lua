
-- Extended Ban Mod for Minetest
-- (C) 2013 Diego Martínez <kaeza>
-- See `LICENSE.txt' for details.

-- join.lua: On join player callback.

local KICK_GUESTS = xban.conf.get("kick_guests")
local DEF_GUEST_KICK_MESSAGE = (xban.conf.get("guest_kick_message")
	or ("Guest accounts are not allowed in this server. "..
		"Please choose a proper username and try again in a few minutes."
	)
)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if (not name) or (name == "") then return end
	local ip = minetest.get_player_ip(name)
	if KICK_GUESTS and name:match("^Guest[0-9]+") then
		minetest.after(1, xban.ban_player, name, 60*2, DEF_GUEST_KICK_MESSAGE)
		return
	end
	local data = xban.find_entry(name, true)
	if data.banned then
		if  (not data.expires)
		 or (os.time() <= data.expires) then
			minetest.after(1, xban.ban_player, name, nil, data.banned)
			return
		end
	end

	data.names[name] = true
	data.names[ip] = true

	xban._.ACTION("%s: added new IP '%s' to list", name, ip)
	xban.save_db()
end)
