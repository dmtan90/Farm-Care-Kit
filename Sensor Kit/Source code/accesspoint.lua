--------------------------------------------------------------------------------
-- Access point mode manager
-- BeeIO TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "accesspoint"}
function M:init(ssid, pwd, success)
	self.connected = false;
	print("Setup acccess point mode\nSSID: ".. ssid .. "\nPWD: " .. pwd);
	wifi.setmode(wifi.SOFTAP);
	wifi.ap.config({ssid=ssid, pwd=pwd})
    	tmr.alarm (1, 800, 1, function ( )
		if wifi.ap.getip ( ) == nil then
			print ("Creating...");
		else
		     	tmr.stop (1);	print ("Created, IP is " .. wifi.ap.getip ( ));
		     	if success ~= nil then success() end
		end
	end)
end
function M:decodeURL(url)
	local hex_to_char = function(x)
		return string.char(tonumber(x, 16))
	end
	return url:gsub("%%(%x%x)", hex_to_char)
end
function M:setupSmartConfig()
	print("Setup Smart Config Mode");local srv=net.createServer(net.TCP);
	srv:listen(80,function(conn) 
	    conn:on("receive", function(client, request)
	    	 local _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP"); local buf = "";local _POST = {};local reboot = false;		
	        if path == "/core.css" then
	        	file.open("core.css", "r");buf = file.read();file.close()
	        elseif path == "/core.js" then
	        	--self:genScript(buf);
	        	buf = "var config="; file.open("config.in", "r"); buf = buf .. file.read(); file.close(); file.open("core.js", "r"); buf = buf .. file.read(); 	file.close();
	        elseif path == "/" or  path == "/index.html" then
	        	if method == "POST" then
	        		local i = string.find(request, "sta_ssid"); local vars = self:decodeURL(string.gsub(string.sub(request, i), "+", " "));
				if vars ~= nil then 
			            for k, v in string.gmatch(vars, "([%w_-]+)=([^&]*)&*") do 
			                _POST[k] = v;
			            end 
			       end 
		        end
		        if config == nil then config = flashMod("config"); config:init(); end        
		        if _POST.ap_ssid ~= nil and _POST.ap_ssid ~= "" then
			       config:setSTASSID(_POST.sta_ssid);config:setSTAPWD(_POST.sta_pwd);config:setAPSSID(_POST.ap_ssid);config:setAPPWD(_POST.ap_pwd);config:commit();reboot=true
			       file.open("reboot.html", "r");buf = file.read();file.close()
			 else
			 	file.open("index.html", "r");buf = file.read();file.close()
			 end
		end
	        client:send(buf);buf = nil,client:close();collectgarbage()
	        if reboot == true then
			tmr.alarm(1, 30000, 0, function()
				node.restart()			
			end)	         
	        end
	    end)
	end)
end
flashMod(M)
file.remove("accesspoint.lua")
return M