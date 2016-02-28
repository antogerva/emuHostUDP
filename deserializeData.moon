class Deserialize
  @_multiArgs = nil
  @_strId = ""
  @_strLib = ""
  @_strFunc = ""
  @_rawParams = {}
  @_lib = nil
  @_func = nil
  @_params = {}

  new:() =>
    --print "new"

  new:(multiArgs) =>
    --print "new"
    @_multiArgs=multiArgs

  isSupported:()=>
    return @_func ~= nil

  exec:() =>
    if #@_params == 0
      if (@_func == nil)
        print("skip func") --not a supported function?
      else
        return @_func()
    else
      return @_func(unpack(@_params))

  unpackArgs:(strId, strLib, strFunc, ...) =>
    @_strId = strId
    @_strLib = strLib
    @_strFunc = strFunc
    @_rawParams = if ... == nil then {} else ...

  parseParams:(paramType, paramValue) =>
    paramsArray = {}
    switch paramType
      when "luaarray"
        firstLevelContent=paramValue\match("{(.-)}")
        for word in firstLevelContent\gmatch("([^,]+)") do
          oneParam = word\match("'(.-)'")
          oneParam = if(oneParam == "") then oneParam else word
          if oneParam\match('[0-9].*') == oneParam and oneParam == word then
            oneParam = tonumber(oneParam)
          table.insert(paramsArray, oneParam)
      when "int"
        table.insert(paramsArray, tonumber(paramValue))
      when "string"
        table.insert(paramsArray, paramValue .. "")
      else
        table.insert(paramsArray, paramValue)
    return paramsArray

  isParsable:()=>
    return _G[@_strLib]~=nil

  parse:() =>
    @_params={}
    argsArray={}
    for word in @_multiArgs\gmatch("([^;;]+)")
    	table.insert(argsArray, word\match("\"(.-)\""))
    @unpackArgs(unpack(argsArray))

    @_lib=_G[@_strLib]
    if(@_lib==nil) then
      print("skip lib")
    else
      @_func=self.lib[@_strFunc]

    for i, value in ipairs(@_rawParams)
    	if i%2==0
    		paramType = @_rawParams[i-1]
    		paramValue = @parseParams(paramType, value)
    		@_params=paramValue

  print:()	=>
    print("multiArgs: ")
    @log(@_multiArgs)
    print("strLib: ")
    @log(@_strLib)
    print("strFunc: ")
    @log(@_strFunc)
    print("rawParams: ")
    @log(@_rawParams)
    print("lib: ")
    @log(@_lib)
    print("func: " )
    @log(@_func)
    print("params: ")
    @log(@_params)

  log:(value) =>
    --print("log:")
    if(_G.console and _G.console.log) then
      _G.console.log(value)
    else
      print(value)
