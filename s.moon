package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--server version on console

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')


export remExecBuilder = require('deserializeData')
export serverSocket = socket.udp()
export portHost = 51424
export portClient = 51425

serverSocket\setsockname("localhost", portHost)
serverSocket\settimeout(0)
serverSocket\setpeername("localhost", portClient)
print("Server is up and can accept connetion")

export fps = 111
export timerTick = 1000/fps
--print("timer set at: ".. timerTick)
--export timer = iup.timer{time:timerTick, run:"YES"}

export queueCmd={}
export remoteCmdToExecute=nil
export dataToSend="New command executed."
export clientSocket = nil

class ServerSpawn
  new:()=>
    print "new"

  cmpStartsString = (fullString,startString)->
    return string.sub(fullString,1,string.len(startString))==startString

  @fnTick:()->
    @start()
    --poll()
    return iup.DEFAULT

  @poll:()->
    --socket.poll(socket,'*r');
    serverSocket\setpeername("localhost", portClient)
    line, err = clientSocket\receive()
    rcptValue = tostring(line)
    if err then print err

    print("got: "..rcptValue)
    if(rcptValue=="send") then
      serverSocket\send(dataToSend)
      print("done ".. rcptValue)
    elseif(rcptValue~=nil and rcptValue~="nil") then
      serverSocket\send(dataToSend)
      print("added "..rcptValue)
      table.insert(queueCmd, remExecBuilder(rcptValue))
    return

  @start:()->
    canread = socket.select({serverSocket}, nil, 0)
    for _,inSocket in ipairs(canread) do
      line, err = inSocket\receive()
      if err then print err

      rcptValue = tostring(line)

      print("got: "..rcptValue)
      if(rcptValue=="send") then
        serverSocket\send(dataToSend)
        print("done ".. rcptValue)
      elseif(rcptValue~=nil and rcptValue~="nil") then
        if not cmpStartsString(rcptValue,"confirm")
          serverSocket\send("confirm: "..rcptValue)
        --serverSocket\send(dataToSend);
        print("added "..rcptValue)
        gg = remExecBuilder(rcptValue)
        table.insert(queueCmd, gg)

  @startTimer:()=>
    iup.SetIdle(@fnTick) --this can be used as timer as well...
  @startTimer()

print("keep going")

while true do
  --print("reply: ")
  --msg = io.read("*l")
  usr = "bob"
  _,msg = iup.GetParam("Title", nil,  "Msg to reply: %s\n","")
  serverSocket\send(usr..": "..msg)


--if _G.emu==nil and _G.tastudio==nil then
  --print("using console mode")
  --iup.MainLoop() --start a loop
