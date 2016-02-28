package.cpath = ";./?51.dll;./debug/?.dll;" .. package.cpath
package.path = ";./socket/?.lua;" .. package.path
require("iuplua")
local iup
iup = _G.iup
socket = require('socket')
local client, emu, console
do
  local _obj_0 = _G
  client, emu, console = _obj_0.client, _obj_0.emu, _obj_0.console
end
remExecBuilder = require('deserializeData')
serverSocket = socket.udp()
portHost = 51424
portClient = 51425
serverSocket:setsockname("localhost", portHost)
serverSocket:settimeout(0)
print("Server is up and can accept connetion")
fps = 111
timerTick = 1000 / fps
print("timer set at: " .. timerTick)
timer = iup.timer({
  time = timerTick,
  run = "YES"
})
queueCmd = { }
isRcpt = false
remoteCmdToExecute = nil
dataToSend = "New command executed."
clientSocket = nil
local start
start = function()
  local canread = socket.select({
    serverSocket
  }, nil, 0)
  for _, clientSocket in ipairs(canread) do
    serverSocket:setpeername("localhost", portClient)
    local line, err = clientSocket:receive()
    if err then
      print(err)
    end
    local rcptValue = tostring(line)
    print("got: " .. rcptValue)
    if (rcptValue == "send") then
      serverSocket:send(dataToSend)
      print("done " .. rcptValue)
      isRcpt = true
    elseif (rcptValue ~= nil and rcptValue ~= "nil") then
      print("added " .. rcptValue)
      local gg = remExecBuilder(rcptValue)
      table.insert(queueCmd, gg)
    end
  end
end
local poll
poll = function()
  serverSocket:setpeername("localhost", portClient)
  local line, err = clientSocket:receive()
  local rcptValue = tostring(line)
  if err then
    print(err)
  end
  print("got: " .. rcptValue)
  if (rcptValue == "send") then
    serverSocket:send(dataToSend)
    print("done " .. rcptValue)
    isRcpt = true
  elseif (rcptValue ~= nil and rcptValue ~= "nil") then
    serverSocket:send(dataToSend)
    print("added " .. rcptValue)
    table.insert(queueCmd, remExecBuilder(rcptValue))
  end
end
timer.action_cb = function()
  return start()
end
client.speedmode(100)
client.pause()
idleCount = 0
if 1 == 1 then
  if isRcpt == true then
    idleCount = 0
    dataToSend = "New Command command executed with success."
    isRcpt = false
    if (client.ispaused()) then
      client.unpause()
    end
    print("berp")
    for i, value in ipairs(queueCmd) do
      print("oye")
      local remCmd = queueCmd[i]
      print("sup")
      queueCmd[i] = nil
      if (remCmd.multiArgs == "ping") then
        print("pong")
        dataToSend = "pong"
      else
        remCmd:parse()
        remCmd:exec()
      end
    end
    queueCmd = { }
  elseif (client.ispaused() ~= true) then
    idleCount = idleCount + 1
    if (idleCount > 100) then
      return client.pause()
    end
  end
end
