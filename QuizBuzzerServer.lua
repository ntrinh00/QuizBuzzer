-- init.lua --
-- Buzzer Server

wifi.setmode(wifi.SOFTAP)
print('set mode=SoftAP (mode='..wifi.getmode()..')')
-- print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())
-- wifi config start
 cfg={}
 cfg.ssid="QuizBuzzer"
 cfg.pwd="tntt1234"
 wifi.ap.config(cfg)
 print(wifi.ap.getip())
-- wifi config end

question=''
list=''

function sendReset()
    conn = net.createConnection(net.UDP, 0)
    conn:connect(10000,"192.168.4.255")
    conn:send("Reset")
    conn:close()
end

-- Close the Connection After Sending HTML 
function closeCon(c)
  c:close()
end

--Add a name to the list when someone buzz in
--If already on the list then will be ignored
function addContent(c, pl)
  print(pl)
 -- if "Question" in pl
  if string.find(list, pl) == nil then
     print("adding to list")
     list=list..pl.."<br>"
  end
  tmr.delay(1000*5)
  c:send("Set")
end

--Clear the list when clear message is received
--This also clears the question
function clearList()
    print("list getting clear and questions")
    list=''
    question=''
end

--Another service could send in the question to be
--displayed by HTML
function setQuestion()
    print("this is the question")
end 

--Respond to Get request with HTML
function printHTML(c, pl)
    if string.find(pl,"Reset") then
      clearList()
      sendReset()
    end
    
    print ("Receive update request")
    header=("<html> <head> <title>Quiz Buzzer</title>  <meta http-equiv=\"refresh\" content=\"5;URL='http://192.168.4.1/'\"/>    </head><body> <h1> Hello, Quiz Buzzer!!! </h1>")
    body=("<form src=\"/\" action=\"Reset\"> Reset the Buzzer <input type=\"submit\" value=\"Reset\"> </form> <br>list of people too: <br>")
    footer=("</body></html>")
    packet=header..body..list..footer
    c:send(packet)
    closeCon(c)
end

 -- Start a simple http server
conn=net.createServer(net.TCP)
conn:listen(80,function(conn)
  conn:on("receive",printHTML)
  conn:on("sent",closeCon)
end)

 -- Start a UDP server
buzz=net.createServer(net.UDP)
buzz:on("receive",addContent)
buzz:listen(10000)


-- Start main loop --
