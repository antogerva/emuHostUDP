local Deserialize
do
  local _class_0
  local _base_0 = {
    isSupported = function(self)
      return self._func ~= nil
    end,
    exec = function(self)
      if #self._params == 0 then
        if (self._func == nil) then
          return print("skip func")
        else
          return self:_func()
        end
      else
        return self:_func(unpack(self._params))
      end
    end,
    unpackArgs = function(self, strId, strLib, strFunc, ...)
      self._strId = strId
      self._strLib = strLib
      self._strFunc = strFunc
      if ... == nil then
        self._rawParams = { }
      else
        self._rawParams = ...
      end
    end,
    parseParams = function(self, paramType, paramValue)
      local paramsArray = { }
      local _exp_0 = paramType
      if "luaarray" == _exp_0 then
        local firstLevelContent = paramValue:match("{(.-)}")
        for word in firstLevelContent:gmatch("([^,]+)") do
          local oneParam = word:match("'(.-)'")
          if (oneParam == "") then
            oneParam = oneParam
          else
            oneParam = word
          end
          if oneParam:match('[0-9].*') == oneParam and oneParam == word then
            oneParam = tonumber(oneParam)
          end
          table.insert(paramsArray, oneParam)
        end
      elseif "int" == _exp_0 then
        table.insert(paramsArray, tonumber(paramValue))
      elseif "string" == _exp_0 then
        table.insert(paramsArray, paramValue .. "")
      else
        table.insert(paramsArray, paramValue)
      end
      return paramsArray
    end,
    isParsable = function(self)
      return _G[self._strLib] ~= nil
    end,
    parse = function(self)
      self._params = { }
      local argsArray = { }
      for word in self._multiArgs:gmatch("([^;;]+)") do
        table.insert(argsArray, word:match("\"(.-)\""))
      end
      self:unpackArgs(unpack(argsArray))
      self._lib = _G[self._strLib]
      if (self._lib == nil) then
        print("skip lib")
      else
        self._func = self.lib[self._strFunc]
      end
      for i, value in ipairs(self._rawParams) do
        if i % 2 == 0 then
          local paramType = self._rawParams[i - 1]
          local paramValue = self:parseParams(paramType, value)
          self._params = paramValue
        end
      end
    end,
    print = function(self)
      print("multiArgs: ")
      self:log(self._multiArgs)
      print("strLib: ")
      self:log(self._strLib)
      print("strFunc: ")
      self:log(self._strFunc)
      print("rawParams: ")
      self:log(self._rawParams)
      print("lib: ")
      self:log(self._lib)
      print("func: ")
      self:log(self._func)
      print("params: ")
      return self:log(self._params)
    end,
    log = function(self, value)
      if (_G.console and _G.console.log) then
        return _G.console.log(value)
      else
        return print(value)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, multiArgs)
      self._multiArgs = multiArgs
    end,
    __base = _base_0,
    __name = "Deserialize"
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
  self._multiArgs = nil
  self._strId = ""
  self._strLib = ""
  self._strFunc = ""
  self._rawParams = { }
  self._lib = nil
  self._func = nil
  self._params = { }
  Deserialize = _class_0
  return _class_0
end
