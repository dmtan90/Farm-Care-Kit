--------------------------------------------------------------------------------
-- Store configuration
-- BeeIO TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "config"}

function M:getConfigString()
	local json = cjson.encode(self.configs)
	return json
end

function M:setConfigString(str)
	local json = cjson.decode(str)
	self.configs = json
end

function M:init()
	--check file exist or not
	print("Init config module")
	self.configs = {
		["config_file"] = "config.in",
		["ap_ssid"] = "BeeIO-ESP",
		["ap_pwd"] = "123456789",
		["sta_ssid"] = "",
		["sta_pwd"] = "",
		["box_serial"] = "150710-000000-000001",
		["host"] = "farmapi.beeio.in",
		["port"]	= 80,
		["api"] = "/box/device"
	}
	local isExist = file.open(self.configs["config_file"], "r")
	if isExist == nil then
		self:commit()
	else 
		local str = file.read()
		self:setConfigString(str)
		file.close()
	end
end

function M:commit()
	file.open(self.configs["config_file"], "w+")
	file.writeline(self:getConfigString())
	file.close()
end

function M:getAPSSID()
	return self.configs["ap_ssid"]
end

function M:setAPSSID(value)
	self.configs["ap_ssid"] = value
end

function M:getAPPWD()
	return self.configs["ap_pwd"]
end

function M:setAPPWD(value)
	self.configs["ap_pwd"] = value
end

function M:getSTASSID()
	return self.configs["sta_ssid"]
end

function M:setSTASSID(value)
	self.configs["sta_ssid"] = value
end

function M:getSTAPWD()
	return self.configs["sta_pwd"]
end

function M:setSTAPWD(value)
	self.configs["sta_pwd"] = value
end

function M:getBoxSerial()
	return self.configs["box_serial"]
end

function M:setBoxSerial(value)
	self.configs["box_serial"] = value
end

function M:getHost()
	return self.configs["host"]
end

function M:setHost(value)
	self.configs["host"] = value
end

function M:getPort()
	return self.configs["port"]
end

function M:setPort(value)
	self.configs["port"] = value
end

function M:getAPI()
	return self.configs["api"]
end

function M:setAPI(value)
	self.configs["api"] = value
end

flashMod(M)

file.remove("config.lua")
return M