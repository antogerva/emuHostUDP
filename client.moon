package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')


export remExecBuilder = require('deserializeData')

export clientSocket = socket.udp()

bindname = "*"
bindport = 51425

peername = "localhost"
peerport = 51424

clientSocket\setsockname(bindname, bindport)
clientSocket\settimeout(0)

--clientSocket\send("SUPPPP!")

export queueCmd={}
export isRcpt=false
export dataToSend="New command executed."


export fps = 111
export timerTick = 1000/fps
print("timer set at: ".. timerTick)
export timer = iup.timer{time:timerTick, run:"YES"}

start = ->
  canread = socket.select({clientSocket}, nil, 0)
  for _,clientSocket in ipairs(canread) do
    clientSocket\setpeername(peername, peerport)
    line, err = clientSocket\receive()

    if err then print err
    rcptValue = tostring(line)

    print("got: "..rcptValue)
    iup.Message('AlertMsg','Got a new message: '..rcptValue)
    if(rcptValue=="send") then
      clientSocket\send(dataToSend)
      print("done ".. rcptValue)
      isRcpt=true
    elseif(rcptValue~=nil and rcptValue~="nil") then
      --serverSocket:send(dataToSend);
      print("added "..rcptValue)
      gg = remExecBuilder(rcptValue)
      table.insert(queueCmd, gg)


timer.action_cb = ->
  print("tick")
  start()
  --poll()
