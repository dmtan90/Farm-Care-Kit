if (not flashMod) then
	function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
end
local M = { MOD_NAME = "farm"}
--mode = 0: running mode
--mode = 1: update mode

function M:getLight()
	print("Get light sensor value")
	local light = -1000
	local bh1750 = flashMod("bh1750")
	bh1750:init(SDA_PIN, SCL_PIN)
    	bh1750:read(OSS)
    	
    	--light
    	light = bh1750:getlux() / 100
    	print("Light: "..light.." lx")
    	
    	-- release module
    	bh1750 = nil
    	--package.loaded["bh1750"]=nil
    	return light
end

function M:getAirCondition()
	print("Get DHT sensor value")
	local air = {
		["temperature"] = -1000,
		["humidity"] = -1000
	}
	local status,temp,humi,temp_decimial,humi_decimial = dht.read(DHT_PIN)
	if( status == dht.OK ) then  
	  -- Float firmware using this example
	  print("DHT Temperature:"..temp..";".."Humidity:"..humi)
	  air["temperature"] = temp
	  air["humidity"] = humi
	elseif( status == dht.ERROR_CHECKSUM ) then
	  print( "DHT Checksum error." );
	elseif( status == dht.ERROR_TIMEOUT ) then
	  print( "DHT Time out." );
	end    	
	return air
end

function M:getSoilCondition()
	local soil = {
		["temperature"] = -1000,
		["humidity"] = -1000
	}
	local si7021 = flashMod("si7021")
	si7021:init(SDA_PIN, SCL_PIN)
	si7021:read(OSS)
	soil["humidity"] = si7021:getHumidity() / 100
	soil["temperature"] = si7021:getTemperature() / 100
	
	print("Soil Humidity: "..soil["humidity"].."%")
	print("Soil Temp: "..soil["temperature"].."C")
	
	si7021 = nil
	return soil
end

function M:enablePower()
	gpio.write(PW_PIN, gpio.LOW)
end

function M:disablePower()
	gpio.write(PW_PIN, gpio.HIGH)	
end

function M:updateData()
	self:enablePower()
	tmr.alarm(1, 3000, 0, function()
		local light = self:getLight()
		if light == -1000 then
			led:red()
			self:updateData()
			return
		end
		tmr.delay(100)
		local air = self:getAirCondition()
		if air["temperature"] == -1000 or air["humidity"] == -1000 then
			led:red()
			self:updateData()
			return
		end
		tmr.delay(100)
		local soil = self:getSoilCondition()
		if soil["temperature"] == -1000 or soil["temperature"] > 100 or soil["humidity"] == -1000 then
			led:red()
			self:updateData()
			return
		end
		soil["humidity"] = soil["humidity"] - air["humidity"] 
		tmr.delay(100)
		self:disablePower()
		
		local PostData = ""
		PostData = PostData .. "box=" .. config:getBoxSerial() .. "&"
		PostData = PostData .. "light=" .. light .. "&"	
		PostData = PostData .. "air_temperature=" .. air.temperature .. "&"
		PostData = PostData .. "air_humidity=" .. air.humidity .. "&"
		PostData = PostData .. "soil_temperature=" .. soil.temperature .. "&"
		PostData = PostData .. "soil_humidity=" .. soil.humidity .. "&"
		PostData = PostData .. "ph=0&"
		PostData = PostData .. "co2=0"
	   	connection:post(config:getHost(), config:getPort(), config:getAPI(true), PostData, function()
			led:green()	   	
	   	end, function() 
	   		led:red()
	   	end);	
	end)
end

function M:init()
	print("Farm Data Logging")
	local delayTime = 300000
	local timeID = 0		
	self:updateData()
	tmr.alarm(timeID, delayTime, 1, function()
		if connection:isConnected() then
			self:updateData()
		else
			if led ~= nil then
				led:red()
			end
			print("Please check your wireless connection!")
		end
	end)
	
end

flashMod(M)
file.remove("farm.lua")

return M
