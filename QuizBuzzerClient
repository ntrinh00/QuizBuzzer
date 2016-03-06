-- init.lua --
-- Buzzer Client

-- Network Variables
ssid = "........"
pass = "........"

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
gpioBuzzer = 1
gpioLED = 2
gpio.mode(gpioBuzzer,gpio.INPUT)
gpio.mode(gpioLED, gpio.OUTPUT)
gpio.write(gpioLED, HIGH)

-- Socket for Sending --
conn = net.createConnection(net.UDP, 0)
-- Socket to receive clear --
buzz=net.createServer(net.UDP)
buzz:on("receive", buzzerReceive)
buzz:listen(10000)

-- Send Buzz when GPIO is LOW
function sendBuzz()
    conn:connect(10000,"192.168.4.1")
    conn:send("Green")
    conn:close()
end

-- Receive Message and Parse
function buzzerReceive(c, pl)
   if pl == "Reset"
      print("Resetting Buzzer State")
      buzzerState = 0
   else if pl == "Set"
      print("Setting Buzzer State")
      buzzerState = 1
   end
end

-- Blinking the LED
function blinkLED()
    print("Blinking the LED")
end

-- Starting the Main Loop

if gpio.read(gpioBuzzer) == 0 then
   print(gpio.read(pin))
   sendBuzzer()
end
