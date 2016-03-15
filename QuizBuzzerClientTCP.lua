-- Buzzer Client using TCP

-- Network Variables
ssid = "QuizBuzzer"
pass = "tntt1234"
buzzerName="KingMaximus"

-- Configure Wireless Internet
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')\n')
print('MAC Address: ',wifi.sta.getmac())
print('Chip ID: ',node.chipid())
print('Heap Size: ',node.heap(),'\n')

-- Configure WiFi --
wifi.sta.config(ssid,pass)


-- WiFi Connection Verification 
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

-- Pin setup for reading
buzzerState = 0
ledState = 0
gpioBuzzer = 2
led = 0
sendflag = 0 

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

-- Timer to blink LED for short amount of time
tmr.alarm(1, 500, 1, function()
   if buzzerState > 0  then
	if ledState == 1 then
		gpio.write(led, gpio.LOW)
		ledState = 0
	else
		gpio.write(led, gpio.HIGH)
		ledState = 1
	end
       buzzerState=buzzerState+1
   end
   
   if buzzerState == 20 then
      buzzerState = 0
      gpio.write(led, gpio.LOW)
   end
end)


-- Timer for clearing debouce the physical buzzer
tmr.alarm(2, 150, 1, function()
   if sendflag == 1 then
      sendflag = 0
   end
end)


-- Send Buzz when GPIO is LOW
function sendBuzz()
   if sendflag == 0 then
      print("Send Team Name")
       -- Socket for Sending --
      conn:connect(80,"192.168.4.1")
      conn:send(wifi.sta.getip().." "..buzzerName)
      conn:close()
      sendflag = 1
   else
      print("Buzz Debounce")
   end
end

-- Defining Trigger and Callback --
gpio.trig(gpioBuzzer,"down", function()
   if sendflag == 0 then
      print("Send Team Name")
       -- Socket for Sending --
      conn = net.createConnection(net.TCP, 0)
      conn:on("receive", buzzerReceive)
      conn:connect(80,"192.168.4.1")
      conn:send(wifi.sta.getip()..buzzerName)
      sendflag = 1
   else
      print("Buzz Debounce")
   end
end)
