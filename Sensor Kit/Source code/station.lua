--------------------------------------------------------------------------------
-- Station mode manager
-- BeeIO TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tan Do <dmtan@gmail.com>
--------------------------------------------------------------------------------
if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "station"}
function M:init(ssid, pwd, success, fail)
	print("Setup station mode\nSSID: ".. ssid .. "\nPWD: " .. pwd);
	self.connected = false;
	local timer = 1;
	wifi.setmode(wifi.STATION);
	wifi.sta.config(ssid, pwd);
	wifi.sta.autoconnect(1);
    	tmr.alarm (1, 800, 1, function ( )
		if wifi.sta.getip ( ) == nil then
			print ("Connecting...");self.connected = false;timer = timer + 1;
			if timer > 50 then
				if fail ~= nil then fail() end	
				tmr.stop (1);	
			end
		else
		     	tmr.stop (1);
		     	print ("Connected, IP is " .. wifi.sta.getip ( ));
		     	self.connected = true;
		     	if success ~= nil then success() end
		end
	end)
end
function M:isConnected()
	return self.connected
end
function M:get(host, port, url, success, fail)
	if self.connected then
		local isSecure = 0; if port == 443 then isSecure = 1 end
		local isSucceed = false;
		local conn=net.createConnection(net.TCP, isSecure); 
		conn:on("connection", function(conn) 
			print("Connecting to " .. host); 
			local cmd = "GET " .. url .. " HTTP/1.1\r\nHost: " .. host .. "\r\nConnection: keep-alive\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n";
			print("cmd>" .. cmd); conn:send(cmd); cmd = nil; collectgarbage()
		end);
		conn:on("sent", function(conn) 
			print("Sent data"); 
		end); 
		conn:on("receive", function(conn, data)		
			success(data);
			isSucceed = true;
			conn:close();
		end); 		
		conn:on("disconnection", function(conn) 
			print("Disconnection to " .. host); 
			if isSucceed == false and fail ~= nil then fail() end
			conn = nil
		end);
		conn:connect(port, host);	
	end
end
function M:post(host, port, url, data, success, fail)
	if self.connected == true then
		local isSecure = 0; if port == 443 then isSecure = 1 end
		local isSucceed = false;
	   	local conn = net.createConnection(net.TCP, isSecure)
		conn:on("receive", function(conn, response)
	 		print("Receive: " .. response);
	 		if success ~= nil then success(response) end
	 		isSucceed = true;
	 		conn:close()
	 	end)
	 	conn:on("disconnection", function(conn)
	 		if isSucceed == false and fail ~= nil then fail() end
			conn = nil
		end)		
		conn:on("connection", function(conn)	     	
			local cmd = "POST " .. url .. " HTTP/1.1\r\n" .. "Host: " .. host .. "\r\n" .. "Accept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
			cmd = cmd .. "Content-Type: application/x-www-form-urlencoded\r\nContent-Length: " .. string.len(data) .. "\r\nConnection: keep-alive\r\n\r\n"..data;
			print("cmd> " .. cmd);conn:send(cmd);data = nil;	cmd = nil;collectgarbage()
	 	end)
		conn:connect(port, host)
	end
end
flashMod(M)
file.remove("station.lua")
return M
