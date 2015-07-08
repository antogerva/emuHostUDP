package.cpath = ";./?51.dll;"..package.cpath
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
server:settimeout(1);
print("Server is up and can accept connetion");

local fps = 44;
local timer = iup.timer{time=(1000/fps), run="YES"};
function timer:action_cb()
  start();
end

local isRcpt=false;
local dataToSend="Data!";
function start()
  local canread = socket.select({server}, {server}, 1);    
  for _,client in ipairs(canread) do
    server:setpeername("localhost", portClient);
    local line, err = client:receive();
    local rcptValue =  tostring(line);

    if(rcptValue ~=nil and rcptValue ~="nil") then
      server:send(dataToSend);
      isRcpt=true;
    end
  end
end

client.pause();
while true do
  if(isRcpt==true) then
    dataToSend= "hola!! " .. gameinfo.getromname();
    isRcpt=false;
    client.unpause();
    emu.frameadvance();
    emu.frameadvance();
    client.pause();
  end
  emu.yield();
end
