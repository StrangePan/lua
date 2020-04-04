local lazy = require 'me.strangepan.libs.util.v1.lazy'
local class = require 'me.strangepan.libs.util.v1.class'
local builder = lazy 'me.strangepan.libs.util.v1.builder'
local queue = require 'me.strangepan.libs.data.v1.queue'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

local mock_os = class.build()

local debug = false
local function print_debug(...)
  if debug then print(...) end
end

function mock_os:_init()
  self._event_queue = queue()
end

function mock_os:sleep() end

local function yield_until(f)
  local v = f()
  while not v do
    print_debug('looper yielding...')
    coroutine.yield()
    v = f()
  end
  print_debug('condition met, no longer yielding...')
  return v
end

local function pull_event_or_terminate(self, terminate)
  while self._event_queue:is_populated() do
    local event = self._event_queue:poll()
    local event_name = event[1]
    print_debug('pulling queued event: '..event_name)
    if terminate and event_name == 'terminate' then
      error('Received termination signal')
    end
    if not filter_set then
      print_debug('returning to app: '..event_name)
      return event
    end
    for _,filter in ipairs(filter_set) do
      if filter == event_name then
        print_debug('returning to app: '..event_name)
        return event
      end
    end
    print_debug('dropped filtered event: '..event_name)
  end
  print_debug('no events in queue')
end

function mock_os:pullEvent(filter_set)
  return unpack(yield_until(function() return pull_event_or_terminate(self, true) end))
end

function mock_os:pullEventRaw(filter_set)
  return unpack(yield_until(function() return pull_event_or_terminate(self, false) end))
end

function mock_os:_pullNextEvent()
  return self._event_queue:poll()
end

function mock_os:queueEvent(...)
  local args = {...}
  local event_name = args[1]
  assert_that(event_name):is_a_string()
  self._event_queue:enqueue(args)
end

-- Builder

local mock_os_builder

function mock_os.builder()
  if not mock_os_builder then
    local function builder_function(parameters)
      local new_os = {}
      local new_mock_os = mock_os()

      -- Constructs new functions that, when called, call member methods on the mock_turtle object.
      -- Effectively, this maps a static function to a member method.
      for key,val in pairs(mock_os) do
        if type(val) == 'function' and string.sub(key, 1, 1) ~= '_' then
          new_os[key] = function(...)
            return val(new_mock_os, ...)
          end
        end
      end

      -- Any methods not defined on the mock should default to the base
      if parameters.build_upon then
        setmetatable(new_os, {__index = parameters.build_upon})
      end

      -- Return the newly constructed set of static functions instead of the mock_turtle directly.
      return new_os
    end

    mock_os_builder =
      builder().builder()
        :field{name = 'build_upon'}
        :builder_function(builder_function)
        :build()
  end
  return mock_os_builder()
end

return mock_os
