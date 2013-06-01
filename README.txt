
Extended Ban Mod for Minetest
-----------------------------

This mod registers all the IPs used by individual players, and can ban the
player when using any of them, even if he is not online at the moment.

License
-------

See file 'LICENSE.txt'.

Chat Commands
-------------

/xban <player> [<reason>]
  Ban given player and all his IPs. If reason not given, it defaults to
  "because random". If player is online at the moment, he/she is shown it. If
  user is not online, it saves it in a list, and next time he connects from any
  IP, or connects from a banned IP with different name, it gets banned again,
  and new IP/username recorded.

/xban_fix
  Performs some consistency checks on the database, and fixes errors, then force
  saves it.

The database is checked for errors and saved every SAVE_INTERVAL seconds
(modifiable in init.lua, by default 10 minutes).

Files
-----

This mod only modifies a single file named 'players.iplist' in the world
directory (and indirectly, 'ipban.txt'). The format is as follows:

[!]<playername>|<ip1>|<ip2>|<ip3>|...|<ipN>

The '!' is optional. If present, the player is marked as "banned", and the mod
will ban him whenever he connects again.

<playername> is self-explanatory.

<ip1>, <ip2>, <ip3>, ..., <ipN> is the list of IPs associated with this
particular player.

Example:
!joerandomgriefer|123.45.67.89|11.22.33.44
goodplayer|132.54.76.98
