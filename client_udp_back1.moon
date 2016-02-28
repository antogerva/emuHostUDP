package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')

import emu, console from _G

import dumpPrint, cmpStartsString, clearTable, trim from require("utils")

export remExecBuilder = require('deserializeData')

export clientSocket = socket.udp()

export bindname = nil
--export bindname = "*"
--export bindname = "127.0.0.1"
--export bindname = "localhost"

export bindport = nil
--export bindport = 51425

export peername = nil
--export peername = "localhost"
--export peername = "127.0.0.1"

export peerport = nil
--export peerport = 51424


dumpPrint clientSocket

export form=nil
export username = "unknown"
export queueInput=nil
export queueRcvCmd={}
export dataToSend="New command executed."

class ClientSpawn
  new:()=>
    print "new"

  setForm:(self, f)->
    form=f

  setBindname:(self, bn)->
    bindname=trim(bn)
    print "bindname: "..bindname

  setBindport:(self, bp)->
    bindport=tonumber(trim(bp))
    print "bindport: "..bindport

  setPeername:(self, pn)->
    peername=trim(pn)
    print "peername: "..peername

  setPeerport:(self, pp)->
    peerport=tonumber(trim(pp))
    print "peerport: "..peerport

  setUsername:(self, usr)->
    username=trim(usr)

  setInputQueue:(self, queue)->
    queueInput=queue

  getSocketInfo:(self)->
    print("Using sockname: "..bindname..":"..bindport)
    print(clientSocket\getsockname())
    print("Using peername: "..peername..":"..peerport)
    print(clientSocket\getpeername())

  initSocket:(self)->
    clientSocket\setsockname(bindname, bindport)
    clientSocket\settimeout(0)
    clientSocket\setpeername(peername, peerport)
    @getSocketInfo()
    return

  testRun:(self, stuff)->
    table.insert(stuff, "confirm: test run")
    queueInput=stuff
    dumpPrint queueInput
    @run()
    return

  addInputQueue:(self, msg)->
    table.insert(queueInput, msg)
    return

  @fnTick:()->
    @start()
    return iup.DEFAULT

  @start:()->
    canread = socket.select({clientSocket}, nil, 0)
    for i,inSocket in ipairs(canread) do
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
        print("added "..rcptValue)
        gg = remExecBuilder(rcptValue)
        table.insert(queueRcvCmd, gg)

  @startTimer:()->
    print("start timer")
    fps = 111
    timerTick = 1000/fps
    timerTick=100
    print("timer set at: ".. timerTick)
    timer = iup.timer({time:timerTick, action_cb: @fnTick})
    timer.run="YES" --start the timer

  run:(self)->
    print("runnnnn")
    if(queueInput == nil) then print("queueInp: nil")
    if(queueInput ~= nil) then
      print("queueInp: "..(#queueInput))
      for i, msg in ipairs(queueInput) do
        print "msg to send: "..msg
        if msg == nil then
          print("msg is null")
          continue
        print("SEND MSG: "..msg)
        clientSocket\send(msg)
        print("SENDED MSG: "..msg)
      clearTable(queueInput)


return {:ClientSpawn, :clientSocket}
