package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

import emu, console from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')

import prettyPrint, dumpPrint from require("utils")

export remExecBuilder = require('deserializeData')

export clientSocket = socket.udp()

export bindname = "*"
--export bindname = "127.0.0.1"
--export bindname = "localhost"
export bindport = 51425

export peername = "localhost"
--export peername = "127.0.0.1"
export peerport = 51424

clientSocket\setsockname(bindname, bindport)
clientSocket\settimeout(0)

clientSocket\setpeername(peername, peerport)

dumpPrint clientSocket

export username = "unknown"
export queueInput=nil
export form=nil
export queueRcvCmd={}
export dataToSend="New command executed."

class ClientSpawn

  new:()=>
    print "new"

  setForm:(self, f)->
    form=f
    --print "setForm"

  setUsername:(self, usr)->
    username=usr
    --print "setUsername"

  setInputQueue:(self, queue)->
    queueInput=queue
    --print "setQueue"

  addInputQueue:(self, msg)->
    table.insert(queueInput, msg)

  getSocketInfo:()->
    print("Using sockname: "..bindname..":"..bindport)
    print(clientSocket\getsockname())
    print("Using peername: "..peername..":"..peerport)
    print(clientSocket\getpeername())

  cmpStartsString = (fullString,startString)->
    return string.sub(fullString,1,string.len(startString))==startString

  @fnTick:()->
    --print("tick")
    @start()
    --poll()
    return iup.DEFAULT

  @fnTock:()->
    print("tock")
    return iup.DEFAULT

  @start:()->
    --canread=nil
    canread = socket.select({clientSocket}, nil, 0)
    for i,inSocket in ipairs(canread) do
      --iup.Close()
      line, err = inSocket\receive()
      if err then print "error: "..tostring(err)
      rcptValue = tostring(line)

      print("got: "..rcptValue)
      if(rcptValue=="send") then
        clientSocket\send(dataToSend)
        print("done ".. rcptValue)
      elseif(rcptValue~=nil and rcptValue~="nil") then
        if not cmpStartsString(rcptValue,"confirm")
          confirmMsg = "confirm: "..rcptValue
          print("sending: "..confirmMsg)
          clientSocket\send(confirmMsg)
          form\updateClient(rcptValue)
        --serverSocket\send(dataToSend);
        print("added "..rcptValue)
        gg = remExecBuilder(rcptValue)
        table.insert(queueRcvCmd, gg)

  @startTimer:()->
    print("start timer")
    fps = 111
    timerTick = 1000/fps
    timerTick=100
    print("timer set at: ".. timerTick)
    timer = iup.timer({time:timerTick, action_cb: @fnTock})
    timer = iup.timer({time:timerTick, action_cb: @fnTick})
    --timer.run="NO" --stop the timer
    timer.run="YES" --start the timer
    --iup.SetIdle(@fnTick) --this can be used as timer as well...
    --dg = iup.dialog({title:"Timer example"})
    --dg\show()
    --iup.SetIdle(@fnTock)
    --iup.MainLoop()


  run:()->
    print "ok"

    if(queueInput == nil) then print("queueInp: nil")
    if(queueInput ~= nil) then
      print("queueInp: "..(#queueInput))
      for i, msg in ipairs(queueInput) do
        print "msg to send: "..msg
        --msg = io.read("*l")
        --_,msg = iup.GetParam("Title", nil,  "Msg to send: %s\n","")
        --print  socket.select({clientSocket}, nil, 0)
        if msg == nil then
          print("msg is null")
          continue
        print("SEND MSG: "..msg)
        --queueInput[i]=nil
        clientSocket\send(msg)
        --clientSocket\sendto(msg, peername, peerport) --this may cause to crash here
        --clientSocket\sendto(msg, "127.0.0.1", peerport) -- so this works
        --clientSocket\sendto(msg, peername, peerport) -- so this works
        print("SENDED MSG: "..msg)
        --clientSocket\sendto("lol", "127.0.0.1", 51420)  -- so this works
        --clientSocket\sendto("lol", "127.0.0.1", 51420)  -- so this works...
      for i=0, #queueInput do queueInput[i]=nil --clear the queue
      --queueInput= [nil for i,v in ipairs queueInput] --clear the queue
      --print("queue cleared: "..(#queueInput))



    --while true do
    if false then
      if (#queueRcvCmd > 0) then
        --TODO: Send back the actual data returned.
        --example:
        --dataToSend= "game name: " .. gameinfo.getromname();
        dataToSend = "New Command command executed with success."

        for i, value in ipairs(queueRcvCmd) do
          remCmd=queueRcvCmd[i]
          queueRcvCmd[i]=nil
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
        queueRcvCmd={} --clear the queue
    --emu.yield()
    --emu.pause()


  --if _G.emu==nil and _G.tastudio==nil then
    --print("using console mode")
    --dg = iup.dialog({title:"Timer example"})
    --dg\show()
    --iup.MainLoop() --start a loop

testRun = ()->
  queueInput={"hi"}
  ClientSpawn\run()
  queueInput=nil

testRun()

return {:ClientSpawn, :clientSocket}
