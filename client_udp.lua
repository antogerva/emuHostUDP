package.cpath = ";./?51.dll;./debug/?.dll;" .. package.cpath
package.path = ";./socket/?.lua;" .. package.path
require("iuplua")
local iup
iup = _G.iup
socket = require('socket')
local dumpPrint, lenTbl, cmpStartsString, clearTable, getTimeStamp
do
  local _obj_0 = require("utils")
  dumpPrint, lenTbl, cmpStartsString, clearTable, getTimeStamp = _obj_0.dumpPrint, _obj_0.lenTbl, _obj_0.cmpStartsString, _obj_0.clearTable, _obj_0.getTimeStamp
end
local arg
arg = _G.arg
clientSocket = socket.udp()
bindname = nil
bindport = nil
peername = nil
peerport = nil
form = nil
username = "unknown"
queueInput = nil
tsTbl = { }
local ClientSpawn
do
  local _class_0
  local _base_0 = {
    setForm = function(self, f)
      form = f
    end,
    setTimestampList = function(self, listTbl)
      tsTbl = listTbl
    end,
    setBindname = function(self, bn)
      bindname = bn
    end,
    setBindport = function(self, bp)
      bindport = tonumber(bp)
    end,
    setPeername = function(self, pn)
      peername = pn
    end,
    setPeerport = function(self, pp)
      peerport = tonumber(pp)
    end,
    setUsername = function(self, usr)
      username = usr
    end,
    setInputQueue = function(self, queue)
      queueInput = queue
    end,
    getSocketInfo = function(self)
      print("Using sockname: " .. bindname .. ":" .. bindport)
      return print("Using peername: " .. peername .. ":" .. peerport)
    end,
    initSocket = function(self)
      clientSocket:setsockname(bindname, bindport)
      clientSocket:settimeout(44)
      clientSocket:setpeername(peername, peerport)
      self:getSocketInfo()
    end,
    testRun = function(self, inputTbl)
      table.insert(inputTbl, "confirm:" .. getTimeStamp() .. ";;usr: test run")
      queueInput = inputTbl
      self:run()
      queueInput = nil
    end,
    addInputQueue = function(self, msg)
      return table.insert(queueInput, msg)
    end,
    run = function(self)
      if (queueInput ~= nil) then
        for i, msg in ipairs(queueInput) do
          local _continue_0 = false
          repeat
            if msg == nil then
              print("msg is nil")
              _continue_0 = true
              break
            end
            local packet = getTimeStamp() .. ";;" .. msg
            print("packet to send: " .. packet)
            clientSocket:send(packet)
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        clearTable(queueInput)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      return print("new")
    end,
    __base = _base_0,
    __name = "ClientSpawn"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.fnTick = function()
    self:start()
    return iup.DEFAULT
  end
  self.start = function()
    local canread = socket.select({
      clientSocket
    }, nil, 0)
    for i, inSocket in ipairs(canread) do
      local _continue_0 = false
      repeat
        local line, err = inSocket:receive()
        dumpPrint(tsTbl)
        if line == nil or line == "nil" then
          print("Received an empty message.")
          if err then
            print("error: " .. tostring(err))
          end
          _continue_0 = true
          break
        end
        local inSockValue = tostring(line) .. ""
        print("inSock: " .. inSockValue)
        local splitSock = { }
        for str in string.gmatch(inSockValue, "([^;;]+)") do
          splitSock[lenTbl(splitSock)] = tostring(str)
        end
        local ts, rcptValue = splitSock[0], splitSock[1]
        local maxCheckout = 10
        for i = #tsTbl - 1, (0 or #tsTbl - maxCheckout), -1 do
          if tsTbl[i] == ts then
            print("Received a duplicated message.")
            break
          end
        end
        table.insert(tsTbl, ts)
        print("received: " .. rcptValue)
        if (rcptValue ~= nil and rcptValue ~= "nil") then
          if not cmpStartsString(rcptValue, "confirm") then
            local confirmMsg = getTimeStamp() .. ";;confirm: " .. rcptValue
            print("sending: " .. confirmMsg)
            clientSocket:send(confirmMsg)
            if form ~= nil then
              form:updateClient(rcptValue)
            end
          end
          if form ~= nil then
            form:updateStatus("Connected")
          end
          print("added " .. rcptValue)
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  self.startTimer = function()
    print("start timer")
    local timerTick = 100
    print("timer set at: " .. timerTick)
    local timer = iup.timer({
      time = timerTick,
      action_cb = self.fnTick
    })
    timer.run = "YES"
  end
  ClientSpawn = _class_0
end
local cmdUsage
cmdUsage = function()
  if arg ~= nil and arg[1] ~= nil and arg[2] ~= nil then
    print("cmd mode")
    local bp = arg[1]
    local pp = arg[2]
    local clientConnector = ClientSpawn
    clientConnector:setBindname("*")
    clientConnector:setBindport(bp)
    clientConnector:setPeername("localhost")
    clientConnector:setPeerport(pp)
    clientConnector:initSocket()
    clientConnector:setUsername("bob")
    clientConnector:testRun({ })
    clientConnector:setInputQueue({ })
    clientConnector:setTimestampList({ })
    clientConnector:startTimer()
    return iup.MainLoop()
  end
end
cmdUsage()
return {
  ClientSpawn = ClientSpawn,
  clientSocket = clientSocket
}
