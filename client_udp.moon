package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"
import iup from _G

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
export socket = require('socket')
import dumpPrint, lenTbl, cmpStartsString, clearTable, getTimeStamp from require("utils")

import arg from _G --command line args

export clientSocket = socket.udp()

export bindname = nil
export bindport = nil
export peername = nil
export peerport = nil

export form=nil
export username = "unknown"
export queueInput=nil
export tsTbl = {}

class ClientSpawn
  new:()=>
    print "new"

  setForm:(self, f)->
    form=f

  setTimestampList:(self, listTbl)->
    tsTbl=listTbl

  setBindname:(self, bn)->
    bindname=bn

  setBindport:(self, bp)->
    bindport=tonumber(bp)

  setPeername:(self, pn)->
    peername=pn

  setPeerport:(self, pp)->
    peerport=tonumber(pp)

  setUsername:(self, usr)->
    username=usr

  setInputQueue:(self, queue)->
    queueInput=queue

  getSocketInfo:(self)->
    print("Using sockname: "..bindname..":"..bindport)
    print("Using peername: "..peername..":"..peerport)

  initSocket:(self)->
    clientSocket\setsockname(bindname, bindport)
    clientSocket\settimeout(44)
    clientSocket\setpeername(peername, peerport)
    @getSocketInfo()
    return

  testRun:(self, inputTbl)->
    table.insert(inputTbl, "confirm:"..getTimeStamp()..";;usr: test run")
    queueInput=inputTbl
    @run()
    queueInput=nil
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
      dumpPrint tsTbl

      if line==nil or line=="nil" then
        print "Received an empty message."
        if err then print "error: "..tostring(err)
        continue

      inSockValue = tostring(line)..""
      print "inSock: "..inSockValue
      splitSock={}
      for str in string.gmatch(inSockValue,"([^;;]+)") do
        splitSock[lenTbl(splitSock)]=tostring(str)

      ts,rcptValue = splitSock[0], splitSock[1]

      maxCheckout = 10
      isInvalid = false
      for i=0, (#tsTbl or maxCheckout), 1 do
        print "just checking..."
        if tsTbl[i]==ts then
          print "Received a duplicated message at TS: "..ts
          isInvalid=true
      if isInvalid==true then
        continue
      if #tsTbl>10
        tsTbl[9]=nil
      print "tsTbl content:"
      dumpPrint tsTbl
      table.insert(tsTbl, 1, ts) --insert at the start of the queue

      print("received: "..rcptValue)
      if(rcptValue~=nil and rcptValue~="nil") then
        if not cmpStartsString(rcptValue,"confirm")
          confirmMsg = getTimeStamp()..";;confirm: "..rcptValue
          print("sending: "..confirmMsg)
          clientSocket\send(confirmMsg)
          if form~=nil then form\updateClient(rcptValue)
        if form~=nil then form\updateStatus("Connected")
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
        if msg == nil then
          print("msg is nil")
          continue
        packet = getTimeStamp()..";;"..msg
        print "packet to send: "..packet
        clientSocket\send(packet)
      clearTable(queueInput)
    return

cmdUsage=()->
  --usage:
  --moon client_udp.moon 51424 51425
  --moon client_udp.moon 51425 51424
  if arg~=nil and arg[1]~=nil and arg[2]~=nil then
    print "cmd mode"
    bp = arg[1]
    pp = arg[2]
    pn = if arg[3]~=nil then arg[3] else "localhost"
    clientConnector = ClientSpawn
    clientConnector\setBindname("*")
    clientConnector\setBindport(bp)
    clientConnector\setPeername(pn)
    clientConnector\setPeerport(pp)
    clientConnector\initSocket()
    clientConnector\setUsername("bob")
    clientConnector\testRun({})

    clientConnector\setInputQueue({})
    clientConnector\setTimestampList({})
    clientConnector\startTimer()
    tsDup =getTimeStamp()
    print "sending dup"
    clientSocket\send(tsDup..";;"..username..": ".."hey")
    clientSocket\send(tsDup..";;"..username..": ".."hey")


    while true do
      _,msg = iup.GetParam("Title", nil,  "Msg to reply: %s\n","")
      clientSocket\send(getTimeStamp()..";;"..username..": "..msg)
    iup.MainLoop() --start a loop
cmdUsage()


return {:ClientSpawn, :clientSocket}
