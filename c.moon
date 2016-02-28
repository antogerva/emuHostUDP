package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--client version on console

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')

export remExecBuilder = require('deserializeData')

import prettyPrint, dumpPrint from require("utils")

export clientSocket = socket.udp()

bindname = "*"
bindport = 51425

peername = "localhost"
peerport = 51424

clientSocket\setsockname(bindname, bindport)
clientSocket\settimeout(0)

clientSocket\setpeername(peername, peerport)


dumpPrint clientSocket


export queueCmd={}
export dataToSend="New command executed."

class ClientSpawn
  new:()=>
    print "new"

  cmpStartsString = (fullString,startString)->
    return string.sub(fullString,1,string.len(startString))==startString

  @fnTick:()->
    @start()
    --poll()
    return iup.DEFAULT

  @fnTock:()->
    print("tock")
    return iup.DEFAULT

  @start:()->
    canread = socket.select({clientSocket}, nil, 0)
    for _,inSocket in ipairs(canread) do
      --iup.Close()
      line, err = inSocket\receive()

      if err then print err
      rcptValue = tostring(line)

      print("got: "..rcptValue)
      if(rcptValue=="send") then
        clientSocket\send(dataToSend)
        print("done ".. rcptValue)
      elseif(rcptValue~=nil and rcptValue~="nil") then
        if not cmpStartsString(rcptValue,"confirm")
          clientSocket\send("confirm: "..rcptValue)
        --serverSocket\send(dataToSend);
        print("added "..rcptValue)
        gg = remExecBuilder(rcptValue)
        table.insert(queueCmd, gg)

  @startTimer:()=>
    --fps = 111
    --timerTick = 1000/fps
    --timerTick=100
    --print("timer set at: ".. timerTick)
    --@_timer = iup.timer({time:timerTick, action_cb: @fnTock})
    --@_timer.run="NO" --stop the timer
    --@_timer.run="YES" --start the timer
    iup.SetIdle(@fnTick) --this can be used as timer as well...
  @_timer = nil
  @startTimer()

print("keep going")
while true do
  --msg = io.read("*l")
  _,msg = iup.GetParam("Title", nil,  "Msg to send: %s\n","")
  clientSocket\send(msg)
  print("send msg: "..msg)

  if (#queueCmd > 0) then
    --TODO: Send back the actual data returned.
    --example:
    --dataToSend= "game name: " .. gameinfo.getromname();
    dataToSend = "New Command command executed with success."

    for i, value in ipairs(queueCmd) do
      remCmd=queueCmd[i]
      queueCmd[i]=nil
      if(remCmd.multiArgs=="ping") then
        print("pong")
        dataToSend="pong"
      else
        if remCmd\isParsable() then
          remCmd\parse()
          --remCmd:print() -- show all the params and function used.
        --else print("lib not supported")
        if remCmd\isSupported() then
          print("execute function...")
          remCmd\exec()
        --else print("function not supported")
    queueCmd={} --clear the queue

--if _G.emu==nil and _G.tastudio==nil then
  --print("using console mode")
  --dg = iup.dialog({title:"Timer example"})
  --dg\show()
  --iup.MainLoop() --start a loop
