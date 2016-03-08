-- init.lua --
-- Buzzer Client

-- Network Variables
ssid = "thecave"
pass = "4086474567"
buzzerName="Green"

-- Configure Wireless Internet
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')\n')
print('MAC Address: ',wifi.sta.getmac())
print('Chip ID: ',node.chipid())
print('Heap Size: ',node.heap(),'\n')

-- Configure WiFi --
wifi.sta.config(ssid,pass)

----------------------------------
-- WiFi Connection Verification --
----------------------------------
tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      print("Connecting to AP...\n")
   else
      ip, nm, gw=wifi.sta.getip()
      print("IP Info: \nIP Address: ",ip)
      print("Netmask: ",nm)
      print("Gateway Addr: ",gw,'\n')
      tmr.stop(0)
   end
end)

---------------------------
-- Pin setup for reading --
---------------------------
buzzerState = 0
ledState = 0
gpioBuzzer = 2
led = 0

-- Setting gpio modes for all pins use 
gpio.mode(gpioBuzzer,gpio.INT, gpio.PULLUP)
gpio.mode(led, gpio.OUTPUT)
gpio.write(led, gpio.LOW)

-- Receive Message and Parse
function buzzerReceive(c, pl)
   if pl == "Reset" then
      print("Resetting Buzzer State")
      buzzerState = 0
      gpio.write(led, gpio.LOW)
   elseif pl == "Set" then
      print("Setting Buzzer State")
      buzzerState = 1
   else
      if string.len(pl) < 15 then
         print("Setting Team Name")
         buzzerName = pl
      end
   end
end

-- Socket to receive clear --
buzz=net.createServer(net.UDP)
buzz:on("receive", buzzerReceive)
buzz:listen(10000)

-- Send Buzz when GPIO is LOW
function sendBuzz()
   print("Send Team Name")
   -- Socket for Sending --
   conn = net.createConnection(net.UDP, 0)
   conn:connect(10000,"192.168.1.56")
   conn:send(buzzerName)
   conn:close()
   buzz:listen(10000)
end


-- Blinking the LED
function blinkLed()
   print("Blinking the LED")
   if ledState == 1 then
      gpio.write(led, gpio.LOW)
      ledState = 0
   else
      gpio.write(led, gpio.HIGH)
      ledState = 1
   end
end

-- Defining Trigger and Callback --
gpio.trig(gpioBuzzer,"both",sendBuzz)

tmr.alarm(0, 1000, 1, function()
   if buzzerState == 1 then
      blinkLed()
   end
end)
