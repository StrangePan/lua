local Physics = {}

local ftable = {n = 2, [1] = 1, [2] = 2}

local function factorial(n)
  if n <= ftable.n then
    return ftable[n]
  end
  for i = ftable.n + 1, n do
    ftable[i] = ftable[i - 1] * i
  end
  return ftable[n]
end

function Physics.increment(dt, ...)
  local initial_state = {...}
  local n = #initial_state
  local processed_state = {}
  local dts = {}
  for i = n, 1, -1 do
    local k = initial_state[i]
    if i < n then
      local j = n - i
      dts[j] = dt ^ j / factorial(j)
    end
    for j = i + 1, n do
      k = k + initial_state[j] * dts[j - i]
    end
    processed_state[i] = k
  end
  return unpack(processed_state)
end

return Physics
