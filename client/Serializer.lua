--
-- Static class for serializing and deserializing objects
--
Serializer = {}

local referenceTable



----------------------------------------- DESERIALIZATION ------------------------------------------



local function parseQuotedString(data, start)
  -- short circuit if not quoted
  if string.sub(data,start,start) ~= "\"" then
    return nil,start
  end
  
  -- state flags
  local escaped = false -- have we encountered escape character?
  
  local i = start+1
  local len = string.len(data)
  local result = ""
  local closed = false
  while i <= len and closed == false do
    local c = string.sub(data,i,i)
    i = i + 1

    if c == "\"" and escaped == false then
      closed = true
    elseif c == "\\" and escaped == false then
      -- reached escape char
      escaped = true
    else
      result = result..c
      escaped = false
    end
  end
  
  if closed then
    return result,i
  else
    return nil,start
  end
end

local referenceCharacters = {
  "1", "2", "3", "4", "5", "6",
  "7", "8", "9", "0"
}

local numberCharacters = {
  "1", "2", "3", "4", "5", "6",
  "7", "8", "9", "0", ".", "-"
}

local labelCharacters = {
  "a", "b", "c", "d", "e", "f",
  "g", "h", "i", "j", "k", "l",
  "m", "n", "o", "p", "q", "r",
  "s", "t", "u", "v", "w", "x",
  "y", "z", "A", "B", "C", "D",
  "E", "F", "G", "H", "I", "J",
  "K", "L", "M", "N", "O", "P",
  "Q", "R", "S", "T", "U", "V",
  "W", "X", "Y", "Z", "0", "1",
  "2", "3", "4", "5", "6", "7",
  "8", "9", "_"
}

local function parseLabel(data,start)
  local i = start
  
  -- short circuit if starting with a number character
  if numberCharacters[string.sub(data,i,i)] then
    return nil,start
  end
  
  local result = ""
  local len = string.len(data)
  while i <= len do
    local c = string.sub(data,i,i)
    
    -- end when label is done
    if labelCharacters[c] == nil then
      break
    end
    
    result = result..c
    i = i+1
  end
  
  -- check if valid label
  if result == "" then
    return nil,i
  end
  
  return result,i
end

local function parseReference(data,start)
  if string.sub(data,start,start) ~= "@" then
    return nil,start
  end
  
  local i = start+1
  local len = string.len(data)
  while i <= len and referenceCharacters[string.sub(data,i,i)] ~= nil do
    i = i + 1
  end
  
  local refId = tonumber(string.sub(data,start+1,i-1))

  return referenceTable[refId],i
end

local function parseNumber(data,start)
  if numberCharacters[string.sub(data,start,start)] == nil then
    return nil,start
  end
  
  local i = start+1
  local len = string.len(data)
  while i <= len do
    if numberCharacters[string.sub(data,i,i)] == nil then
      break
    end
    i = i+1
  end
  
  return tonumber(string.sub(data,start,i-1)),i
end

local parseTable = function() end

local function parseKey(data,start)
  local c = string.sub(data,start,start)
  if c == "\"" then
    return parseQuotedString(data,start)
  elseif c == "{" then
    return parseTable(data,start)
  elseif c == "@" then
    return parseReference(data,start)
  elseif numberCharacters[c] then
    return parseNumber(data,start)
  else
    return parseLabel(data,start)
  end
end

local function parseBoolean(data,start)
  local c = string.sub(data,start,start)
  if c == "t" then
    return true,start+1
  elseif c == "f" then
    return false,start+1
  else
    return nil,start
  end
end

local function parseValue(data,start)
  local c = string.sub(data,start,start)
  if c == "\"" then
    return parseQuotedString(data,start)
  elseif c == "{" then
    return parseTable(data,start)
  elseif c == "@" then
    return parseReference(data,start)
  elseif numberCharacters[c] then
    return parseNumber(data,start)
  else
    return parseBoolean(data,start)
  end
end

parseTable = function(data,start)
  local i = start
  
  if string.sub(data,i,i) ~= "{" then
    return nil,start
  end
  
  i = i+1
  local result = {}
  referenceTable[referenceTable.n] = result
  referenceTable.n = referenceTable.n+1
  local len = string.len(data)
  while i <= len do
    -- check for end of table
    if string.sub(data,i,i) == "}" then
      i = i+1
      break
    end
    
    -- get the key and check for errors
    local k
    k,i = parseKey(data,i)
    if k == nil then return nil,i end
    
    -- make sure = sign is present
    if string.sub(data,i,i) ~= "=" then return nil,i end
    i = i+1
    
    -- get the value and check for errors
    local v
    v,i = parseValue(data,i)
    if v == nil then return nil,i end
    
    -- insert parsed key/value pair into table
    result[k]=v
    
    -- make sure delimiter or end is present
    local c = string.sub(data,i,i)
    if c == "," then
      i = i+1
    elseif c ~= "}" then
      return nil,i
    end
  end
  
  return result,i
end




------------------------------------------ SERIALIZATION -------------------------------------------



local quotedStringEscapedCharacters = {
  "\"", "\\"
}

local function serializeQuotedString(object)
  assert(type(object)=="string")
  local data = "\""
  
  for i=1,string.len(object) do
    local c = string.sub(object,i,i)
    if quotedStringEscapedCharacters[c] then
      data = data.."\\"
    end
    data = data..c
  end
  
  data = data.."\""
  return data
end

local function serializeLabel(object)
  assert(type(object) == "string")
  for i = 1,string.len(object) do
    if labelCharacters[string.sub(object,i,i)] == nil then
      return nil
    end
  end
  return object
end

local function serializeNumber(object)
  assert(type(object) == "number")
  return tostring(object)
end

local serializeTable = function() end

local function serializeKey(object)
  local oType = type(object)
  if oType == "table" then
    return serializeTable(object)
  elseif oType == "number" then
    return serializeNumber(object)
  elseif oType == "string" then
    return serializeLabel(object) or serializeQuotedString(object)
  else
    return nil -- unsupported data type
  end
end

local function serializeBoolean(object)
  assert(type(object) == "boolean")
  if object == true then
    return "t"
  else
    return "f"
  end
end

local function serializeValue(object)
  local oType = type(object)
  if oType == "table" then
    return serializeTable(object)
  elseif oType == "number" then
    return serializeNumber(object)
  elseif oType == "string" then
    return serializeQuotedString(object)
  elseif oType == "boolean" then
    return serializeBoolean(object)
  else
    return nil
  end
end

--
-- converts table into serialized string. Returns the serialized table as a string
--
serializeTable = function(object)
  assert(type(object) == "table")
  
  -- return a table reference if this table was previously serialized
  if referenceTable[object] then
    return "@"..referenceTable[object]
  else
    referenceTable[object] = referenceTable.n
    referenceTable.n = referenceTable.n+1
  end
  
  local data = "{"
  for k,v in pairs(object) do
    local kType = type(k)
    local vType = type(v)
    
    if kType == "nil" or kType == "function" or vType == "nil" or vType == "function" then
      -- do nothing
    else
      local kData = serializeKey(k)
      local vData = serializeValue(v)
      if kData == nil or vData == nil then
        -- do nothing
      else
        if data ~= "{" then
          data = data..","
        end
        data = data..kData.."="..vData
      end
    end
  end
  data = data.."}"
  
  return data
end



-------------------------------------------- INTERFACE ---------------------------------------------



--
-- Creates a table out of a string of data that has been created by the serialize() function
--
function Serializer.deserialize(data)
  referenceTable = {n=1}
  return parseTable(data,1)
end

--
-- Turns a lua table into a serialized string. Functions will be ommited, as well as any nil values.
-- Will handle recursive table references without problem. Table keys of type boolean will be
-- ommitted.
--
function Serializer.serialize(object)
  referenceTable = {n=1}
  return serializeTable(object)
end



local function flipArray(array)
  for _,v in ipairs(array) do
    array[v] = true
  end
end
flipArray(referenceCharacters)
flipArray(numberCharacters)
flipArray(labelCharacters)
flipArray(quotedStringEscapedCharacters)
