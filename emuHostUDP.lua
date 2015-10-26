package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path

--You can download the iup library from:
--http://sourceforge.net/projects/iup
require "iuplua"

--Using luasocket-2.0.2, you can download the socket library from:
--http://files.luaforge.net/releases/luasocket/luasocket
local socket = require('socket');
local server = socket.udp();
local portHost = 51424;
local portClient = 51425;

server:setsockname("localhost", portHost) 
server:settimeout(0);
print("Server is up and can accept connetion");

local remExecBuilder=require('remExec');

local fps = 111;
local timer = iup.timer{time=(1000/fps), run="YES"};
function timer:action_cb()
  start();
  --poll();
end

--Use the wxlua debugger to fix any single debbuging session
--require("wx");
--wxlua.LuaStackDialog();

local queueCmd={};
local isRcpt=false;
local remoteCmdToExecute=nil;
local dataToSend="New command executed.";


function poll()
  --socket.poll(socket,'*r');
  server:setpeername("localhost", portClient);
  local line, err = client:receive();
  local rcptValue = tostring(line);

  --print("got: "..rcptValue)   
  if(rcptValue=="send") then
    server:send(dataToSend);
    --print("done ".. rcptValue)
    isRcpt=true;
  elseif(rcptValue~=nil and rcptValue~="nil") then
    server:send(dataToSend);
    --print("added "..rcptValue)
    table.insert(queueCmd, remExecBuilder(rcptValue));
  end
end

function start()
  local canread = socket.select({server}, nil, 0);    
  for _,client in ipairs(canread) do
    server:setpeername("localhost", portClient);
    local line, err = client:receive();
    local rcptValue = tostring(line);

    --print("got: "..rcptValue)   
    if(rcptValue=="send") then
      server:send(dataToSend);
      --print("done ".. rcptValue)
      isRcpt=true;
    elseif(rcptValue~=nil and rcptValue~="nil") then
      --server:send(dataToSend);
      --print("added "..rcptValue)
      table.insert(queueCmd, remExecBuilder(rcptValue));
    end
  end
end

--emu.frameadvance();
--emu.yield();
client.speedmode(100);
client.pause();

--gui.drawText(10,10,"Test");
local idleCount=0;
while true do
  if(isRcpt==true) then
    idleCount=0;
    --TODO: Send back the actual data returned.
    --example:
    --dataToSend= "game name: " .. gameinfo.getromname();
    dataToSend = "New Command command executed with success.";
    isRcpt=false;
    if(client.ispaused()) then
      client.unpause();
    end
    for i, value in ipairs(queueCmd) do
      local remCmd=queueCmd[i];
      queueCmd[i]=nil;
      if(remCmd.multiArgs=="ping") then
        print("pong");
        dataToSend="pong";
      else
        remCmd:parse();
        --remCmd:print(); -- show all the params and function used.
        remCmd:exec();
      end
    end
    queueCmd={};
  elseif(client.ispaused()~=true) then
    idleCount = idleCount+1;
    if(idleCount>100) then
      --Put back to pause when there's no message received
      --when passing over a certain threshold
      client.pause();
    end
  end
  emu.yield();
end
