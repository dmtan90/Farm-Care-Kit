--------------------------------------------------------------------------------
-- Connection manager
-- BeeIO TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "connection"}
function M:connect(success, fail)
	if config == nil then
		config = flashMod("config");
		config:init();
	end
	if config:getSTASSID() == "" then
		self:setupSmartConfig();
	else
		self.sta = flashMod("station");
		self.sta:init(config:getSTASSID(), config:getSTAPWD(), function()
			if success ~= nil then success() end
		end, function()
			if fail ~= nil then fail() end
			self:setupSmartConfig();	
		end);
	end
end
function M:setupSmartConfig()
	self.ap = flashMod("accesspoint");
	self.ap:init(config:getAPSSID(), config:getAPPWD(), function()
		self.ap:setupSmartConfig();
	end);
end
function M:isConnected()
	return self.sta:isConnected();
end
function M:get(host, port, url, success, fail)
	if self:isConnected() then
		self.sta:get(host, port, url, success, fail);
	else
		if fail ~= nil then fail() end
	end
end
function M:post(host, port, url, params, success, fail)
	if self:isConnected() then
		self.sta:post(host, port, url, params, success, fail);
	else
		if fail ~= nil then fail() end
	end
end
flashMod(M)
file.remove("connection.lua")
return M
