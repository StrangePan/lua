local class = require 'me.strangepan.libs.util.v1.class'
local builder = require 'me.strangepan.libs.util.v1.builder'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

local looper = class.build()

local debug = false
local function print_debug(...)
  if debug then print(...) end
end

local NO_OP = function() end

function looper:_init(die_on, callbacks)
  assert_that(die_on):is_a_table()
  assert_that(callbacks):is_a_table()

  self._die_on = {}
  for i,death_event in pairs(die_on) do
    assert_that(death_event):is_a_string()
    self._die_on[death_event] = death_event
  end
  assert_that('terminate'):is_a_key_in(self._die_on)

  self._callbacks = {}
  for event_name, event_callback in pairs(callbacks) do
    assert_that(event_name):is_a_string()
    assert_that(event_callback):is_a_function()
    self._callbacks[event_name] = event_callback
  end
end

function looper:loop()
  while true do
    event = {os.pullEventRaw()}
    event_name = event[1]
    print_debug('looper event: '..event_name)
    event_data = {unpack(event, 2)}
    print_debug('looper event params: '..#event_data)
    callback = self._callbacks[event_name] or NO_OP
    callback(unpack(event_data))
    if self._die_on[event_name] then break end
  end
end

local looper_builder =
    builder.builder()
        :field{name = 'die_on', required = false, default = {'terminate'}}
        :field{name = 'callbacks', required = false, default = {}}
        :builder_function(function(params) return looper(params.die_on, params.callbacks) end)
        :build()

function looper.builder()
  return looper_builder()
end

return looper
