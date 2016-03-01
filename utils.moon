
toArr = (aTable) ->
  myArray = {}
  for i,tbl in ipairs(aTable) do
    nbKeys = 0
    for k,v in pairs(tbl) do
      nbKeys+=1
      myArray[#myArray+1]=v
    if(nbKeys==0) then
      myArray[#myArray+1]="_null_"
  for i,v in ipairs(myArray) do --quick fix for the nil value issue in table
    if(v=="_null_") then myArray[i]=nil
  return myArray

unpackArrValues = (aTable)->
  return unpack toArr(aTable)


trim=(str)->
  begin = str\match"^%s*()"
  return begin > #str and "" or str\match(".*%S", begin)

--Check if a fullString begin with a startString
cmpStartsString=(fullString,startString)->
  return string.sub(fullString,1,string.len(startString))==startString

clearTable = (t)->
  for i=0, #t do t[i]=nil

dump = (...)->
  if(type(...)=="nil") then
    print "nil"
    return
  -- A reasonably bullet-proof table dumper that writes out in Moon syntax;
  -- can limit the number of items dumped out, and cycles are detected.
  -- No attempt at doing pretty indentation here, but it does try to produce
  -- 'nice' looking output by separating the hash and the array part.
  --
  --  dump = require 'moondump'
  --  ...
  --  print dump t  -- default, limit 1000, respect tostring
  --  print dump t, limit:10000,raw:true   -- ignore tostring
  --
  quote  = (v) ->
      if type(v) == 'string'
          '%q'\format(v)
      else
          tostring(v)

  --- return a string representation of a Lua value.
  -- Cycles are detected, and a limit on number of items can be imposed.
  -- @param t the table
  -- @param options
  --    limit on items, default 1000
  --    raw ignore tostring
  -- @return a string
  dumpString = (t,options) ->
      options = options or {}
      limit = options.limit or 1000
      buff = tables:{[t]:true}
      k,tbuff = 1,nil

      put = (v) ->
          buff[k] = v
          k += 1

      put_value = (value) ->
          if type(value) ~= 'table'
              put quote value
              if limit and k > limit
                  buff[k] = "..."
                  error "buffer overrun"
          else
              if not buff.tables[value] -- cycle detection!
                  buff.tables[value] = true
                  tbuff value
              else
                  put "<cycle>"
          put ','

      tbuff = (t) ->
          mt = getmetatable t unless options.raw
          if type(t) ~= 'table' or mt and mt.__tostring
              put quote t
          else
              put '{'
              indices = #t > 0 and {i,true for i = 1,#t}
              for key,value in pairs t -- first do the hash part
                  if indices and indices[key] then continue
                  if type(key) ~= 'string' then
                      key = '['..tostring(key)..']'
                  elseif key\match '%s'
                      key = quote key
                  put key..':'
                  put_value value

              if indices -- then bang out the array part
                  for v in *t
                      put_value v

              if buff[k - 1] == "," then k -= 1
              put '}'
      -- we pcall because that's the easiest way to bail out if there's an overrun.
      pcall tbuff,t
      table.concat(buff)
  --return dumpString(...)
  return dumpString(...,limit:40000,raw:true)

dumpPrint = (...)->
  print dump(...)

dumpFile = (filename, content)->
  file = io.open(filename, "w+")
  file\write(content)
  io.close(file)

prettyPrint = (...)->
  --This module adds two functions to the `debug` module. While it may seem a
  --little unorthodox, this after-the-fact modification of the existing lua
  --standard libraries is because it is common that, when a project is ready for
  --release, one adds `export debug = nil` to the beginning of the project, so
  --that any lingering debug code that is slowing your application down is
  --caught with error messages in the final stage of testing.
  --Generally, `print` statements are also removed in this same stage, to
  --prevent pollution of the console and because stringification of objects
  --sometimes has a significant processor overhead.  Consequently, it seems
  --natural to put the debug printing function in the `debug` library, so that
  --all unwanted testing code can be removed with one line.
  --
  --This module introduces two functions, `debug.write` and `debug.print`, which
  --are analogous to the built-in `io.write` and `print` functions, except that
  --they handle tables correctly.
  --To prevent cycles from being printed, a simple rule is used that every table
  --is only printed once in a given invocation of `debug.print` or
  --`debug.write`.  Even if there are no cycles, and the table structure just
  --contains non-tree-like references, it will still print each table only once.
  --Every key-value pair is printed on a separate line, so, although always
  --remaining fairly readable, the output can get rather large fairly quickly.
  ilevel = 0
  indent = (a, b)->
      steps, fn = if b
          a, b
      else
          1, a
      ilevel += steps
      fn!
      ilevel -= steps
  writeindent = -> io.write "   "\rep ilevel

  debug.write = =>
      visited = {}
      _write = =>
          if type(self) == 'table' and not visited[self]
              if not (@@ and @@__name and not @__tostring)
                  visited[self] = true
                  print "{"
                  for k, v in pairs self
                      indent ->
                          writeindent!
                          _write k
                          io.write ': '
                          _write v
                          print!
                  writeindent!
                  _write "}"
              elseif @__tostring
                  io.write @__tostring!
              else
                  io.write @@__name
          else
              io.write tostring self
      _write self

  debug.print = (...)->
      remaining = #{...}
      for arg in *{...}
          remaining -= 1
          debug.write arg
          io.write ', ' unless remaining == 0
      print!
  debug.print(...)

split = (str, sep)->
  sep, fields = sep or ":", {}
  pattern = string.format("([^%s]+)", sep)
  str\gsub(pattern, ((c) -> fields[#fields+1] = c))
  return fields

lenTbl = (t)->
  i=0
  for _ in pairs(t) do
    i+=1
  return i

getTimeStamp = ()->
  return os.time()

{:toArr, :cmpStartsString, :prettyPrint, :dumpPrint, :dump, :unpackArrValues,
 :clearTable, :trim, :dumpFile, :split, :lenTbl,  :getTimeStamp}
