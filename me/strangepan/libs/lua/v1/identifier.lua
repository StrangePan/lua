local identifier = {}

local function process(char_string)
  local new_chars = {}
  for _,char_string in ipairs(char_string) do
    local l = string.len(char_string)
    for i = 1,l do
      new_chars[string.sub(char_string, i, i)] = true
    end
  end
  return new_chars
end
local function found_in(char, char_table)
  return char_table[char] == true
end
local valid_initial_chars = process {
  'abcdefghijklmnopqrstuvwxyz',
  'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
  '_',
}
local valid_secondary_chars = process {
  '0123456789'
}

function identifier.is_valid(identifier_string)
  if type(identifier_string) ~= 'string' then
    return
      false,
      'not a valid lua identifier: not of type \'string\' ('..type(identifier_string)..' received)'
  end

  local identifier_string_length = string.len(identifier_string)
  if identifier_string_length < 1 then
    return
      false,
      'not a valid lua identifier: identifiers must contain at least one character (empty string '
        ..'received)'
  end

  if not found_in(string.sub(identifier_string, 1, 1), valid_initial_chars) then
    return
      false,
      'not a valid lua identifier: identifiers must begin with a letter (a-z or A-Z) or an '
          ..'underscore (_) (\''..identifier_string..'\' received)'
  end

  for i = 2,identifier_string_length do
    local c = string.sub(identifier_string, i, i)
    if not found_in(c, valid_initial_chars) and not found_in(c, valid_secondary_chars) then
      return
        false,
        'not a valid lua identifier: identifiers can only contain letters (a-z or A-Z), '
            ..'underscores (_), and digits (0-9) (\''..identifier_string..'\' received)'
    end
  end

  return true
end

return identifier
