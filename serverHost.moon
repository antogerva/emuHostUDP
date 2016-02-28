package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')

import client, emu, console from _G

export remExecBuilder = require('deserializeData')
export serverSocket = socket.udp()
export portHost = 51424
export portClient = 51425

serverSocket\setsockname("localhost", portHost)
serverSocket\settimeout(0)
print("Server is up and can accept connetion")

export fps = 111
export timerTick = 1000/fps
print("timer set at: ".. timerTick)
export timer = iup.timer{time:timerTick, run:"YES"}

export queueCmd={}
export isRcpt=false
export remoteCmdToExecute=nil
export dataToSend="New command executed."
export clientSocket = nil

start = ->
  canread = socket.select({serverSocket}, nil, 0)
  for _,clientSocket in ipairs(canread) do
    serverSocket\setpeername("localhost", portClient)
    line, err = clientSocket\receive()

    if err then print err
    rcptValue = tostring(line)

    print("got: "..rcptValue)
    if(rcptValue=="send") then
      serverSocket\send(dataToSend)
      print("done ".. rcptValue)
      isRcpt=true
    elseif(rcptValue~=nil and rcptValue~="nil") then
      --serverSocket:send(dataToSend);
      print("added "..rcptValue)
      gg = remExecBuilder(rcptValue)
      table.insert(queueCmd, gg)

poll = ->
  --socket.poll(socket,'*r');
  serverSocket\setpeername("localhost", portClient)
  line, err = clientSocket\receive()
  rcptValue = tostring(line)
  if err then print err

  print("got: "..rcptValue)
  if(rcptValue=="send") then
    serverSocket\send(dataToSend)
    print("done ".. rcptValue)
    isRcpt=true
  elseif(rcptValue~=nil and rcptValue~="nil") then
    serverSocket\send(dataToSend)
    print("added "..rcptValue)
    table.insert(queueCmd, remExecBuilder(rcptValue))
  return


timer.action_cb = ->
  start()
  --poll()


--emu.frameadvance()
--emu.yield()
client.speedmode(100)
client.pause()

--gui.drawText(10,10,"Test")
export idleCount=0
--while true
if 1==1 then
  if isRcpt==true then
    idleCount=0
    --TODO: Send back the actual data returned.
    --example:
    --dataToSend= "game name: " .. gameinfo.getromname();
    dataToSend = "New Command command executed with success."
    isRcpt=false
    if(client.ispaused()) then
      client.unpause()
    print("berp")

    for i, value in ipairs(queueCmd) do
      print("oye")
      remCmd=queueCmd[i]
      print("sup")
      queueCmd[i]=nil
      if(remCmd.multiArgs=="ping") then
        print("pong")
        dataToSend="pong"
      else
        remCmd\parse()
        --remCmd:print(); -- show all the params and function used.
        remCmd\exec()


    queueCmd={}
  elseif(client.ispaused()~=true) then
    idleCount = idleCount+1
    if(idleCount>100) then
      --Put back to pause when there's no message received
      --when passing over a certain threshold
      client.pause()

  --print("ok")
  --emu.yield()
  --console.log(_G.stop)
  --_G.stop()
