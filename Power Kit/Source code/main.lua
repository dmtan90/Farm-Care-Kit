--------------------------------------------------------------------------------
-- Start program
-- BeeIO TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
print("Join BEEIO.IN")
config = flashMod("config")
config:init()
connection = flashMod("connection")
connection:connect(function()
	local device = flashMod("device")
	device:init()
end);
