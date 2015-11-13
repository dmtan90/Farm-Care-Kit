--------------------------------------------------------------------------------
-- Control devices state
-- BeeIO TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "device" }

function M:init()
	print("Farm Device Control")
	local delayTime = 300000
	local timeID = 0
	self.devices = {["lamp"] = 1,["pump"] = 1,	["fan"] = 1,["fog"] = 1};
	self.pins = {["lamp"] = 5,	["pump"] = 1,["fan"] = 2,	["fog"] = 0};
	self:setPinMode();
	self:setDeviceState();
	self:getData();
	tmr.alarm(timeID, delayTime, 1, function()
		if connection:isConnected() then
			self:getData()
		else
			print("Please check your wireless connection!")
		end
	end)
end

function M:getData()
	if config == nil then config = flashMod("config"); config:init() end
	local url = config:getAPI() .. "/" .. config:getBoxSerial();print(url)
	connection:get(config:getHost(), config:getPort(), url, function(data)
		local startIdx = string.find(data, "{");
		local endIdx =  string.find(data, "}\"");
		if endIdx == nil then endIdx =  string.find(data, "]\"") end
		data = string.gsub(string.sub(data, startIdx, endIdx), "\\", "");
		print("data: " .. data)
		local json = cjson.decode(data)
		--print(json["success"])
		if json["success"] == true then
			if json["value"]["lamp"] then self.devices["lamp"] = 0 else self.devices["lamp"] = 1 end
			if json["value"]["pump"] then self.devices["pump"] = 0 else self.devices["pump"] = 1 end
			if json["value"]["fan"] then self.devices["fan"] = 0 else self.devices["fan"] = 1 end
			if json["value"]["fog"] then self.devices["fog"] = 0 else self.devices["fog"] = 1 end
		else
			self.devices = {["lamp"] = 1,["pump"] = 1,	["fan"] = 1,["fog"] = 1};
		end
		--print(self.devices)
		self:setDeviceState();
	end, function()
		self.devices = {["lamp"] = 1,["pump"] = 1,	["fan"] = 1,["fog"] = 1};
		self:setDeviceState();
	end)
end

function M:setPinMode()
	gpio.mode(self.pins["lamp"], gpio.OUTPUT)
	gpio.mode(self.pins["pump"], gpio.OUTPUT)
	gpio.mode(self.pins["fan"], gpio.OUTPUT)
	gpio.mode(self.pins["fog"], gpio.OUTPUT)	
end

function M:setDeviceState()
	gpio.write(self.pins["lamp"], self.devices["lamp"])
	gpio.write(self.pins["pump"], self.devices["pump"])
	gpio.write(self.pins["fan"], self.devices["fan"])
	gpio.write(self.pins["fog"], self.devices["fog"])	
end

flashMod(M)

file.remove("device.lua")
return M