
local SAVE_INTERVAL = 60 * 10

local iplist_file = minetest.get_worldpath().."/players.iplist"

local unpack = unpack
if not unpack then unpack = table.unpack end

local iplist
local banned_ips

local function log(message)
	print("[xban] "..message)
end

local iplist_save_timer = 0

-- Forward
local check_db -- = function(nosave)

local function load_ips()
	iplist = { }
	banned_ips = { }
	local f, e = io.open(iplist_file, "r")
	if not f then
		log("Error loading IP database: "..(e or ""))
		return
	end
	for line in f:lines() do
		local ipl = line:split("|")
		local name = ipl[1]
		local banned
		if name:sub(1, 1) == "!" then
			banned = true
			name = name:sub(2)
		end
		if not iplist[name] then iplist[name] = { } end
		iplist[name].banned = banned
		for i = 2, #ipl do
			iplist[name][i-1] = ipl[i]
			if banned then banned_ips[ipl[i]] = true end
		end
	end
	f:close()
	iplist_save_timer = 0
	log("IP database loaded!")
	check_db()
end

local function save_ips()
	check_db()
	local f, e = io.open(iplist_file, "w")
	if not f then
		log("Error saving IP database: "..(e or ""))
		return
	end
	for name, list in pairs(iplist) do
		local s = name
		if list.banned then s = "!"..s end
		for _, ip in ipairs(list) do
			s = s.."|"..ip
		end
		f:write(s.."\n")
	end
	f:close()
	iplist_save_timer = 0
	log("IP database saved!")
end

check_db = function(nosave)
	log("Performing consistency check...")
	for player, list in pairs(iplist) do
		local banned = list.banned
		for _,ip in ipairs(list) do
			if banned_ips[ip] and (not banned) then
				log("Error: IP was banned but not user. Fixed.")
				banned = true
			elseif (not banned_ips[ip]) and banned then
				log("Error: user was banned but not IP. Fixed.")
				banned_ips[ip] = true
			end
		end
		list.banned = banned
	end
end

local function do_ban(player, reason)
	minetest.chat_send_player(player, "You have been banned from this server for the following reason: "..(reason or "because random"))
	minetest.chat_send_player(player, "Disconnection will follow shortly. Have a nice day :)")
	minetest.ban_player(player)
	iplist[player].banned = true
	for _,ip in ipairs(iplist[player]) do
		banned_ips[ip] = true
	end
end

local function ban_player(player, reason)
	minetest.after(1, do_ban, player, reason)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name() or "<wut>"
	local ip = minetest.get_player_ip(name)
	if not iplist[name] then iplist[name] = { } end
	if banned_ips[ip] then
		ban_player(name)
		return
	end
	for _, v in ipairs(iplist[name]) do
		if v == ip then
			log(name..": IP '"..ip.."' already registered")
			if iplist[name].banned then
				ban_player(name)
			end
			return
		end
	end
	if banned_ips[ip] then
		ban_player(name)
	end
	local c = #iplist[name]
	iplist[name][c+1] = ip
	log(name..": added new IP '"..ip.."' to list")
end)

minetest.register_globalstep(function(dtime)
	iplist_save_timer = iplist_save_timer + dtime
	if iplist_save_timer >= SAVE_INTERVAL then
		iplist_save_timer = 0
		save_ips()
	end
end)

minetest.register_on_shutdown(save_ips)

minetest.register_chatcommand("xban", {
	params = "<player> [<reason>]",
	description = "Future ban all IPs for a given player",
	privs = { ban=true, },
	func = function(name, param)
		param = param:trim()
		local player, reason = param:match("([^ ]+) *(.*)")
		if (not player) or (player == "") then
			minetest.chat_send_player(name, "[xban] Usage: /xban <player> [<reason>]")
			return
		end
		if not iplist[player] then
			minetest.chat_send_player(name, "[xban] Player '"..player.."' is not in the list.")
			return
		end
		log(name.." bans player '"..player.."'. Reason: "..reason)
		for _, obj in ipairs(minetest.get_connected_players()) do
			local nm = obj:get_player_name()
			if nm and (nm == player) then
				ban_player(player, reason)
				break
			end
		end
		local s = ""
		for _, ip in ipairs(iplist[player]) do
			s = s..ip..", "
			banned_ips[ip] = true
		end
		log("Banned IPs: "..s)
		minetest.set_player_privs(player, { })
		log("Revoked all privileges")
	end,
})

minetest.register_chatcommand("xban_fix", {
	params = "",
	description = "Perform consistency check on IP database and fix possible errors",
	privs = { ban=true, },
	func = function(name, param)
		check_db()
		save_ips()
	end,
})

load_ips()
