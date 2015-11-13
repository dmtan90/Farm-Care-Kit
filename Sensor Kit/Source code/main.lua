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
GPIO_PINS = {
	[0]=3,
	[2]=4,
	[4]=2,
	[5]=1,
	[12]=6,
	[13]=7,
	[14]=5,
	[15]=8,
	[16]=0
}
PW_PIN = GPIO_PINS[4]
LED_PIN = GPIO_PINS[5] 
SDA_PIN = GPIO_PINS[12]
SCL_PIN = GPIO_PINS[13]
DHT_PIN = GPIO_PINS[14]
led = flashMod("led")
led:init(LED_PIN)
led:blue()
config = flashMod("config")
config:init()
connection = flashMod("connection")
connection:connect(function()
	led:green()
	local farm = flashMod("farm")
	farm:init()
end);

