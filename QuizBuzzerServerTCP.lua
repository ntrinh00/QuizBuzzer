-- init.lua --
-- Buzzer Server using TCP

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

function closeCon(c, pl)
   c:close()
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
    end
    
    print ("Receive update request")
    header=("<html> <head> <title>Quiz Buzzer</title>  <meta http-equiv=\"refresh\" content=\"5;URL='http://192.168.4.1/'\"/>    </head><body> <h1> Hello, Quiz Buzzer!!! </h1>")
    body=("<form src=\"/\" action=\"Reset\"> Reset the Buzzer <input type=\"submit\" value=\"Reset\"> </form> <br>list of people too: <br>")
    footer=("</body></html>")
    packet=header..body..list..footer
    c:send(packet)
end

--Respond to Get request with HTML
function processMessage(c, pl)
   --print(pl)
   if string.find(pl, "GET") then
      printHTML(c, pl)
   elseif string.find(list, pl) == nil then
      list = list..pl.."<br>"
      c:send("Set")
   elseif string.find(pl, "Question:") then
      question = pl
   end
end

 -- Start a simple http server
conn=net.createServer(net.TCP)
conn:listen(80,function(conn)
  conn:on("receive",processMessage)
  conn:on("sent", closeCon)
end)
