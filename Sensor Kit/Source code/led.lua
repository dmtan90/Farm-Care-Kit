local M = { MOD_NAME = "led"}

function M:red()
	ws2812.writergb(self.LED_PIN, string.char(255, 0, 0))
end

function M:green()
	ws2812.writergb(self.LED_PIN, string.char(0, 255, 0))
end

function M:blue()
	ws2812.writergb(self.LED_PIN, string.char(0, 0, 255))  
end

function M:pink()
	ws2812.writergb(self.LED_PIN, string.char(233, 30, 99))
end

function M:purple()
	ws2812.writergb(self.LED_PIN, string.char(156, 39, 176))
end

function M:strip()
	local color = {
		[0] = {[0] = 244, [1] = 67,[2] = 54},
		[1] = {[0] = 233, [1] = 30,[2] = 99},
		[2] = {[0] = 156, [1] = 39,[2] = 176},
		[3] = {[0] = 103, [1] = 58,[2] = 183},
		[4] = {[0] = 63, [1] = 81, [2] = 181},
		[5] = {[0] = 33, [1] = 150,[2] = 243},
		[6] = {[0] = 3, [1] = 169,[2] = 244},
		[7] = {[0] = 0, [1] = 188, [2] = 212},
		[8] = {[0] = 0,[1] = 150,[2] = 136},
		[9] = {[0] = 76,[1] = 175,[2] = 80},
		[10] = {[0] = 139,[1] = 195,[2] = 74},
		[11] = {[0] = 205,[1] = 220,[2] = 57},
		[12] = {[0] = 255,[1] = 235,[2] = 59},
		[13] = {[0] = 255,[1] = 193,[2] = 7},
		[14] = {[0] = 255,[1] = 152,[2] = 0},
		[15] = {[0] = 255,[1] = 87,[2] = 34},
		[16] = {[0] = 121,[1] = 85,[2] = 72},
		[17] = {[0] = 158,[1] = 158,[2] = 158},
		[18] = {[0] = 96,[1] = 125,[2] = 139},
		[19] = {[0] = 0,[1] = 0,[2] = 0},
		[20] = {[0] = 255,[1] = 255,[2] = 255}
	}
	local idx = 0
	local timeID = 2
	tmr.alarm(timeID, 1000, 1, function()
		ws2812.writergb(self.LED_PIN, string.char(color[idx][0], color[idx][1], color[idx][2]))
		if idx == 20 then
			idx = 0
		else
			idx = (idx +1)		
		end
	end)
end

function M:init(led_pin)
	print("init LED module")
	self.LED_PIN = led_pin
end

flashMod(M) 

file.remove("led.lua")
return M