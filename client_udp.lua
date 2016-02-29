package.cpath = ";./?51.dll;./debug/?.dll;" .. package.cpath
package.path = ";./socket/?.lua;" .. package.path
require("iuplua")
local iup
iup = _G.iup
socket = require('socket')
local dumpPrint, cmpStartsString, clearTable, trim
do
  local _obj_0 = require("utils")
  dumpPrint, cmpStartsString, clearTable, trim = _obj_0.dumpPrint, _obj_0.cmpStartsString, _obj_0.clearTable, _obj_0.trim
end
clientSocket = socket.udp()
bindname = nil
bindport = nil
peername = nil
peerport = nil
form = nil
username = "unknown"
queueInput = nil
local ClientSpawn
do
  local _class_0
  local _base_0 = {
    setForm = function(self, f)
      form = f
    end,
    setBindname = function(self, bn)
      bindname = trim(bn)
    end,
    setBindport = function(self, bp)
      bindport = tonumber(trim(bp))
    end,
    setPeername = function(self, pn)
      peername = trim(pn)
    end,
    setPeerport = function(self, pp)
      peerport = tonumber(trim(pp))
    end,
    setUsername = function(self, usr)
      username = trim(usr)
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
      clientSocket:settimeout(0)
      clientSocket:setpeername(peername, peerport)
      self:getSocketInfo()
    end,
    testRun = function(self, inputTbl)
      table.insert(inputTbl, "confirm: test run")
      queueInput = inputTbl
      self:run()
    end,
    addInputQueue = function(self, msg)
      return table.insert(queueInput, msg)
    end,
    run = function(self)
      if (queueInput ~= nil) then
        for i, msg in ipairs(queueInput) do
          local _continue_0 = false
          repeat
            print("msg to send: " .. msg)
            if msg == nil then
              print("msg is nil")
              _continue_0 = true
              break
            end
            clientSocket:send(msg)
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
      local line, err = inSocket:receive()
      local rcptValue = tostring(line)
      if rcptValue == nil or rcptValue == "nil" then
        print("Received an empty message.")
        return 
      end
      if err then
        print("error: " .. tostring(err))
      end
      print("received: " .. rcptValue)
      if (rcptValue ~= nil and rcptValue ~= "nil") then
        if not cmpStartsString(rcptValue, "confirm") then
          local confirmMsg = "confirm: " .. rcptValue
          print("sending: " .. confirmMsg)
          clientSocket:send(confirmMsg)
          form:updateClient(rcptValue)
        end
        form:updateStatus("Connected")
        print("added " .. rcptValue)
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
return {
  ClientSpawn = ClientSpawn,
  clientSocket = clientSocket
}
