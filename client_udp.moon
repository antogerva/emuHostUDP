package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')
import dumpPrint, cmpStartsString, clearTable, trim from require("utils")

export clientSocket = socket.udp()

export bindname = nil
export bindport = nil
export peername = nil
export peerport = nil

export form=nil
export username = "unknown"
export queueInput=nil

class ClientSpawn
  new:()=>
    print "new"

  setForm:(self, f)->
    form=f

  setBindname:(self, bn)->
    bindname=trim(bn)

  setBindport:(self, bp)->
    bindport=tonumber(trim(bp))

  setPeername:(self, pn)->
    peername=trim(pn)

  setPeerport:(self, pp)->
    peerport=tonumber(trim(pp))

  setUsername:(self, usr)->
    username=trim(usr)

  setInputQueue:(self, queue)->
    queueInput=queue

  getSocketInfo:(self)->
    bn,bp = clientSocket\getsockname()
    pn,pp = clientSocket\getpeername()
    print("Using sockname: "..bn..":"..bp)
    print("Using peername: "..pn..":"..pp)

  initSocket:(self)->
    clientSocket\setsockname(bindname, bindport)
    clientSocket\settimeout(0)
    clientSocket\setpeername(peername, peerport)
    @getSocketInfo()
    return

  testRun:(self, inputTbl)->
    table.insert(inputTbl, "confirm: test run")
    queueInput=inputTbl
    @run()
    return

  addInputQueue:(self, msg)->
    table.insert(queueInput, msg)

  @fnTick:()->
    @start()
    return iup.DEFAULT

  @start:()->
    canread = socket.select({clientSocket}, nil, 0)
    for i,inSocket in ipairs(canread) do
      line, err = inSocket\receive()
      rcptValue = tostring(line)
      if rcptValue==nil or rcptValue=="nil" then
        print "Received an empty message."
        return
      if err then print "error: "..tostring(err)

      print("received: "..rcptValue)
      if(rcptValue~=nil and rcptValue~="nil") then
        if not cmpStartsString(rcptValue,"confirm")
          confirmMsg = "confirm: "..rcptValue
          print("sending: "..confirmMsg)
          clientSocket\send(confirmMsg)
          form\updateClient(rcptValue)
        form\updateStatus("Connected")
        print("added "..rcptValue)

  @startTimer:()->
    print("start timer")
    timerTick=100
    print("timer set at: "..timerTick)
    timer = iup.timer({time:timerTick, action_cb: @fnTick})
    timer.run="YES" --start the timer

  run:(self)->
    if(queueInput ~= nil) then
      for i, msg in ipairs(queueInput) do
        print "msg to send: "..msg
        if msg == nil then
          print("msg is nil")
          continue
        clientSocket\send(msg)
      clearTable(queueInput)
    return

return {:ClientSpawn, :clientSocket}
