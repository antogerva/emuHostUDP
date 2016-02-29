package.cpath = ";./?51.dll;./debug/?.dll;"..package.cpath
package.path = ";./socket/?.lua;"..package.path
package.loaded.formConnect=nil;
package.loaded.client_udp=nil;
package.loaded.utils=nil;

--require("moonscript"); --uncomment this line to use '.moon' for 'require' call
require("formConnect");
