--------------------------------------------------------------------------------
-- si7021  for NODEMCU
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "si7021"}

-- 16-bit  two's complement
-- value: 16-bit integer
function M:twoCompl(value)
	if value > 32767 then value = -(65535 - value + 1)
 	end
 	return value
end

-- read data from si7021
-- ADDR: slave address
-- commands: Commands of si7021
-- length: bytes to read
function M:read_data(ADDR, commands, length)
	i2c.start(self.id)
  	i2c.address(self.id, ADDR, i2c.TRANSMITTER)
  	i2c.write(self.id, commands)
  	i2c.stop(self.id)
  	i2c.start(self.id)
  	i2c.address(self.id, ADDR, i2c.RECEIVER)
  	tmr.delay(20000)
  	c = i2c.read(self.id, length)
  	i2c.stop(self.id)
  	return c
end

-- initialize module
-- sda: SDA pin
-- scl SCL pin
function M:init(sda, scl)
	-- i2c interface ID
	self.id = 0
	self.init = false
	--device address
  	self.Si7021_ADDR = 0x40
  	--device command
  	self.CMD_MEASURE_HUMIDITY_HOLD = 0xE5
	self.CMD_MEASURE_HUMIDITY_NO_HOLD = 0xF5
	self.CMD_MEASURE_TEMPERATURE_HOLD = 0xE3
	self.CMD_MEASURE_TEMPERATURE_NO_HOLD = 0xF3
	self.CMD_MEASURE_POST_RH_TEMP_READ = 0xE0
	-- temperature and pressure
	self.t = -1000
	self.h = -1000	
	i2c.setup(self.id, sda, scl, i2c.SLOW)
  	self.init = true
end

-- read humidity from si7021
function M:read_humi()
	local dataH = self:read_data(self.Si7021_ADDR, self.CMD_MEASURE_HUMIDITY_HOLD, 2)
  	local UH = string.byte(dataH, 1) * 256 + string.byte(dataH, 2)
  	self.h = ((UH*12500+65536/2)/65536 - 600)
  	--self.h = bit.rshift(125 * UH, 16) - 6
  	print("H: " .. self.h)
  	return(self.h)
end

-- read temperature from si7021
function M:read_temp()
	local dataT = self:read_data(self.Si7021_ADDR, self.CMD_MEASURE_TEMPERATURE_HOLD, 2)
  	local UT = string.byte(dataT, 1) * 256 + string.byte(dataT, 2)
  	self.t = ((UT*17572+65536/2)/65536 - 4685)
  	--self.t = bit.rshift(17572 * UT, 16) - 4685
  	print("T: " .. self.t)
  	return(self.t)
end

-- read temperature and humidity from si7021
function M:read()
	if (not self.init) then
     		print("init() must be called before read.")
  	else
		self:read_humi()
	 	self:read_temp()
  	end
end;

-- get humidity
function M:getHumidity()
	return self.h
end

-- get temperature
function M:getTemperature()
	return self.t
end

flashMod(M)
file.remove("si7021.lua")
return M
