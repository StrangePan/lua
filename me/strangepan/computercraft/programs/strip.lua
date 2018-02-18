local move = require('me.strangepan.libs.computercraft.turtle.v1.move')()
local dig = require('me.strangepan.libs.computercraft.turtle.v1.dig')()
if require 'me.strangepan.libs.computercraft.mock.v1.mocker'():mock() then
  turtle.verbose = true
end

local args = {...}
if #args < 2 or #args > 3 then
  print('Dig a 3x3 tunnel with 1x3 branches spaced 3 blocks apart on either side.')
  print('')
  print('Usage:')
  print('  strip <depth> <left> [right]')
  print('  <depth> = number of blocks long to make the main 3x3 shaft.')
  print('  <left> = number of blocks long to make the branches on the left.')
  print('  [right] = number of blocks long to make the branches on the right. If ommitted, will '..
      'use <left>.')
  return
end

local function parse_numeric_argument(arg)
  local num = tonumber(arg)
  if num == nil
      or num < 1
      or num ~= math.floor(num) then
    print('Invalid argument: '..arg)
    print('Value must be a positive integer.')
    return nil
  end
  return num
end

local tunnelDepth = parse_numeric_argument(args[1])
if not tunnelDepth then return end
local leftDepth = parse_numeric_argument(args[2])
if not leftDepth then return end
local rightDepth = #args >= 3 and parse_numeric_argument(args[3]) or leftDepth
if not rightDepth then return end

local function dig_and_move_forward()
  dig:forward()
  move:forward()
end

local function dig3x3x1()
  dig_and_move_forward()
  dig:up():down()
  move:left()
  dig:forward()
  move:down()
  dig:forward()
  move:right(2)
  dig:forward()
  for i = 1,2 do
    move:up()
    dig:forward()
  end
  move:left(2)
  dig:forward()
  move:down():right()
end

local function dig1x3x1()
  dig_and_move_forward()
  dig:up():down()
end

local function dig_branch(branchDepth)
  move:forward()
  for depth = 1,branchDepth do
    dig1x3x1()
  end
  move:right(2):forward(branchDepth + 1)
end

local function dig_side_branches()
  if not leftDepth and not rightDepth then return end
  if leftDepth then
    move:left()
    dig_branch(leftDepth)
  else
    move:right()
  end
  if rightDepth then
    dig_branch(rightDepth)
    move:right()
  else
    move:left()
  end
end

local BRANCH_SPACING = 4

local function dig_main_tunnel()
  for depth = 1,tunnelDepth do
    dig3x3x1()
    if depth % BRANCH_SPACING == 1 then
      dig_side_branches()
    end
  end
  move:right(2):forward(tunnelDepth)
end

local function dig_strip_mine()
  dig:up()
  move:up()
  dig_main_tunnel()
  move:down()
end

dig_strip_mine()
