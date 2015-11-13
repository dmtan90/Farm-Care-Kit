--------------------------------------------------------------------------------
-- BH1750 for NODEMCU
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "bh1750"}

function M:read_data(ADDR, commands, length)
    i2c.start(self.id)
    i2c.address(self.id, ADDR, i2c.TRANSMITTER)
    i2c.write(self.id, commands)
    i2c.stop(self.id)
    i2c.start(self.id)
    i2c.address(self.id, ADDR, i2c.RECEIVER)
    tmr.delay(200000)
    c = i2c.read(self.id, length)
    i2c.stop(self.id)
    return c
end
function M:read_lux()
    local dataT = self:read_data(self.GY_30_address, self.CMD, 2)
    --Make it more faster
    local UT = dataT:byte(1) * 256 + dataT:byte(2)
    self.l = (UT*1000/12)
    return(self.l)
end

function M:init(sda, scl)
    self.GY_30_address = 0x23
    self.id = 0
    self.l = 0
    self.CMD = 0x10
    self.init = false
    i2c.setup(self.id, sda, scl, i2c.SLOW)
    self.init = true
end

function M:read()
    if (not self.init) then
        print("init() must be called before read.")
    else
        self:read_lux()
    end
end

function M:getlux()
    return self.l
end

flashMod(M)

file.remove("bh1750.lua")
return M
