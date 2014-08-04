
-- Extended Ban Mod for Minetest
-- (C) 2013 Diego Martínez <kaeza>
-- See `LICENSE.txt' for details.

-- init.lua: Initialization script.

xban = { }
xban._ = { } -- Internal functions.

xban.player_notes = minetest.get_modpath("player_notes")

local MP = minetest.get_modpath("xban")

dofile(MP.."/conf.lua")
dofile(MP.."/intr.lua")
dofile(MP.."/xban.lua")
dofile(MP.."/chat.lua")
dofile(MP.."/join.lua")
