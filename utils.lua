local toArr
toArr = function(aTable)
  local myArray = { }
  for i, tbl in ipairs(aTable) do
    local nbKeys = 0
    for k, v in pairs(tbl) do
      nbKeys = nbKeys + 1
      myArray[#myArray + 1] = v
    end
    if (nbKeys == 0) then
      myArray[#myArray + 1] = "_null_"
    end
  end
  for i, v in ipairs(myArray) do
    if (v == "_null_") then
      myArray[i] = nil
    end
  end
  return myArray
end
local unpackArrValues
unpackArrValues = function(aTable)
  return unpack(toArr(aTable))
end
local trim
trim = function(str)
  local begin = str:match("^%s*()")
  return begin > #str and "" or str:match(".*%S", begin)
end
local cmpStartsString
cmpStartsString = function(fullString, startString)
  return string.sub(fullString, 1, string.len(startString)) == startString
end
local clearTable
clearTable = function(t)
  for i = 0, #t do
    t[i] = nil
  end
end
local dump
dump = function(...)
  if (type(...) == "nil") then
    print("nil")
    return 
  end
  local quote
  quote = function(v)
    if type(v) == 'string' then
      return ('%q'):format(v)
    else
      return tostring(v)
    end
  end
  local dumpString
  dumpString = function(t, options)
    options = options or { }
    local limit = options.limit or 1000
    local buff = {
      tables = {
        [t] = true
      }
    }
    local k, tbuff = 1, nil
    local put
    put = function(v)
      buff[k] = v
      k = k + 1
    end
    local put_value
    put_value = function(value)
      if type(value) ~= 'table' then
        put(quote(value))
        if limit and k > limit then
          buff[k] = "..."
          error("buffer overrun")
        end
      else
        if not buff.tables[value] then
          buff.tables[value] = true
          tbuff(value)
        else
          put("<cycle>")
        end
      end
      return put(',')
    end
    tbuff = function(t)
      local mt
      if not (options.raw) then
        mt = getmetatable(t)
      end
      if type(t) ~= 'table' or mt and mt.__tostring then
        return put(quote(t))
      else
        put('{')
        local indices = #t > 0 and (function()
          local _tbl_0 = { }
          for i = 1, #t do
            _tbl_0[i] = true
          end
          return _tbl_0
        end)()
        for key, value in pairs(t) do
          local _continue_0 = false
          repeat
            if indices and indices[key] then
              _continue_0 = true
              break
            end
            if type(key) ~= 'string' then
              key = '[' .. tostring(key) .. ']'
            elseif key:match('%s') then
              key = quote(key)
            end
            put(key .. ':')
            put_value(value)
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        if indices then
          for _index_0 = 1, #t do
            local v = t[_index_0]
            put_value(v)
          end
        end
        if buff[k - 1] == "," then
          k = k - 1
        end
        return put('}')
      end
    end
    pcall(tbuff, t)
    return table.concat(buff)
  end
  return dumpString(..., {
    limit = 40000,
    raw = true
  })
end
local dumpPrint
dumpPrint = function(...)
  return print(dump(...))
end
local dumpFile
dumpFile = function(filename, content)
  local file = io.open(filename, "w+")
  file:write(content)
  return io.close(file)
end
local prettyPrint
prettyPrint = function(...)
  local ilevel = 0
  local indent
  indent = function(a, b)
    local steps, fn
    if b then
      steps, fn = a, b
    else
      steps, fn = 1, a
    end
    ilevel = ilevel + steps
    fn()
    ilevel = ilevel - steps
  end
  local writeindent
  writeindent = function()
    return io.write(("   "):rep(ilevel))
  end
  debug.write = function(self)
    local visited = { }
    local _write
    _write = function(self)
      if type(self) == 'table' and not visited[self] then
        if not (self.__class and self.__class.__name and not self.__tostring) then
          visited[self] = true
          print("{")
          for k, v in pairs(self) do
            indent(function()
              writeindent()
              _write(k)
              io.write(': ')
              _write(v)
              return print()
            end)
          end
          writeindent()
          return _write("}")
        elseif self.__tostring then
          return io.write(self:__tostring())
        else
          return io.write(self.__class.__name)
        end
      else
        return io.write(tostring(self))
      end
    end
    return _write(self)
  end
  debug.print = function(...)
    local remaining = #{
      ...
    }
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local arg = _list_0[_index_0]
      remaining = remaining - 1
      debug.write(arg)
      if not (remaining == 0) then
        io.write(', ')
      end
    end
    return print()
  end
  return debug.print(...)
end
local split
split = function(str, sep)
  local fields
  sep, fields = sep or ":", { }
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, (function(c)
    fields[#fields + 1] = c
  end))
  return fields
end
local lenTbl
lenTbl = function(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
  end
  return i
end
local getTimeStamp
getTimeStamp = function()
  return os.time()
end
return {
  toArr = toArr,
  cmpStartsString = cmpStartsString,
  prettyPrint = prettyPrint,
  dumpPrint = dumpPrint,
  dump = dump,
  unpackArrValues = unpackArrValues,
  clearTable = clearTable,
  trim = trim,
  dumpFile = dumpFile,
  split = split,
  lenTbl = lenTbl,
  getTimeStamp = getTimeStamp
}
