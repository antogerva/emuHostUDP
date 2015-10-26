--TODO: Add documentation using LDT:
--https://wiki.eclipse.org/LDT/User_Area/Documentation_Language

local M = {};
local C = {
 multiArgs={}, strId="",
 strLib="", strFunc="", rawParams={},
 lib=nil, func=nil, params={}
};

function C:exec()
	--print("executing: "..self.strFunc);
	if(#self.params==0) then
    if(self.func==nil) then
      print("skip func")
    else
		  return self.func();
    end
	else
		return self.func(unpack(self.params));
	end
end

function C:unpackArgs(strId, strLib, strFunc, ...)
  self.strId=strId;
	self.strLib=strLib;
	self.strFunc=strFunc;
	self.rawParams=arg;
end

local function parseParams(paramType, paramValue)
	local paramsArray={};
	if(paramType=="luaarray") then
		--could be possible to use a lua lib such as luaexpact
		--to parse these params.
		local firstLevelContent=paramValue:match("{(.-)}");
		for word in firstLevelContent:gmatch("([^,]+)") do
		  	local oneParam= word:match("'(.-)'"); --todo add suport for double quote as well as single quote
		  	oneParam=((oneParam=="") and oneParam or word);--tenary operator

		  	if(oneParam:match('[0-9].*')==oneParam and oneParam==word) then		  	
		  		oneParam=tonumber(oneParam); --parse as a number if possible
		  	end
			table.insert(paramsArray, oneParam);
		end
	elseif(paramType=="int") then
		table.insert(paramsArray, tonumber(paramValue));
	elseif(paramType=="string") then
		table.insert(paramsArray, paramValue..""); --force as string
	else
		table.insert(paramsArray, paramValue);
	end
	return paramsArray;
end

function C:parse()
  self.params={};
  argsArray={};
  for word in self.multiArgs:gmatch("([^;;]+)") do
  	table.insert(argsArray, word:match("\"(.-)\""));
  end
  self:unpackArgs(unpack(argsArray));

  self.lib=_G[self.strLib];
  if(self.lib==nil) then
    print("skip lib")
  else
    self.func=self.lib[self.strFunc];
  end

  for i, value in ipairs(self.rawParams) do
  	if(i%2==0) then
  		local paramType = self.rawParams[i-1];
  		local paramValue = parseParams(paramType, value);
  		self.params=paramValue;
  		--table.insert(self.params, paramValue);
  	end
  end
end

function C:print()	
  print("multiArgs: ");
  console.log(self.multiArgs);
  print("strLib: "..self.strLib);
  print("strFunc: "..self.strFunc);
  print("rawParams: ")
  console.log(self.rawParams)
  print("lib: ");
  console.log(self.lib);
  print("func: " )
  console.log(self.func)
  print("params: ");
  console.log(self.params);
end


local function new(self, multiArgs)	
  print(self)
  print(multiArgs)
  local newExec = {multiArgs=multiArgs};
  setmetatable(newExec,{__index=C});
  return newExec;
end

setmetatable(M,{__call=new});
return M;