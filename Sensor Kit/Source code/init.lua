print("Start init.lua")
if file.open("main.lua") then 
    print("Starting main.lua in 3 seconds")
    tmr.alarm(0, 3000, 0, function() dofile("main.lua") end)
end
print("End init.lua")