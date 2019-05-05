local class = require 'me.strangepan.libs.util.v1.class'
local identifier = require 'me.strangepan.libs.util.v1.identifier'
local ternary = require 'me.strangepan.libs.util.v1.ternary'

--[[ A general way to define builders for your objects using (you guessed it) a builder pattern!

Usage:
    local builder = require 'me.strangepan.libs.util.v1.builder'

    local my_class = {}

    function my_class.builder()

      -- Only define builder class if not previously defined
      if not my_class._builder_class then
        my_class._builder_class =
            builder.builder()
              :field({name = 'foo', required = true})
              :field({name = 'bar', default = 132})
              :builder_function(
                function(params)
                  return my_class(params.foo, params.bar)
                end)
              :build()
      end

      -- Return new instance of builder class
      return my_class._builder_class()
    end

    return my_class
]]


-- Okay, so no builders here, just a builder for builders. Yeah, I know, but bear with me; the point
-- of these builder classes is to be defined and built at runtime.

local builder_builder = class.build()
local builder_builder_private = {}

function builder_builder:_init()
  self._fields = {}
end

function builder_builder:field(parameters)
  local parameters_copy = builder_builder_private.validate_parameters(self, parameters)
  self._fields[parameters_copy.name] = parameters_copy
  return self
end

function builder_builder_private.validate_parameters(builder_builder, parameters)
  -- parameters must be a table
  assert(
    type(parameters) == 'table',
    'Builder error: input parameters must be a named table ('..type(parameters)..' received)')

  -- verify no unrecognized parameters are defined
  local known_parameters = {
    default = true,
    name = true,
    required = true,
  }
  for parameter_key in pairs(parameters) do
    assert(
      type(parameter_key) == 'string',
      'Builder error: invalid field parameter type found ('..type(parameter_key)..'). All field '
          ..'parameters must have string keys')
    assert(
      known_parameters[parameter_key],
      'Builder error: unrecognized field parameter \''.. parameter_key ..'\' defined.')
  end

  -- A string name is mandatory
  local field_name = parameters.name
  assert(
    field_name ~= nil,
    'Builder error: \'name\' parameter not set. Every field must have a distinct name.')
  assert(
    type(field_name) == 'string',
    'Builder error: \'name\' paramter must be a string type ('..type(field_name)..' received)')
  assert(
    not builder_builder._fields[field_name],
    'Builder error: field with name \''..field_name..'\' already defined. Every field must have a '
      ..'unique name')
  local is_valid_identifier, invalid_identifier_message = identifier.is_valid(field_name)
  assert(
    is_valid_identifier,
     'Builder error: '..(invalid_identifier_message or ''))
  assert(
    string.sub(field_name, 1, 1) ~= '_',
    'Builder error: field names beginning with an underscore (_) are reserved and cannot be used '
      ..'(\''..field_name..'\' received)')
  assert(
    field_name ~= 'build',
    'Builder error: field name \''..field_name..'\' is reserved and cannot be used')

  -- field_is_required, if defined, must be a boolean
  local field_is_required = ternary(parameters.required ~= nil, parameters.required, false)
  assert(
    type(field_is_required) == 'boolean',
    'Builder error: \'field_is_required\' parameter must be a boolean type ('
      ..type(field_is_required)..' received)')

  -- default cannot be defined if field_is_required is true
  local field_default = parameters.default
  assert(
    field_default == nil or not field_is_required,
    'Builder error: \'default\' parameter defined on a required field. Required fields cannot have '
      ..'a default value (kinda defeats the purpose of making the field required).')

  -- make a shallow copy so user cannot make changes afterwards
  return {
    name = field_name,
    required = field_is_required,
    default = field_default,
  }
end

function builder_builder:builder_function(builder_function)
  -- cannot be set multiple times
  assert(
    type(builder_function) == 'function',
    'Builder error: builder function must be a function type ('..type(builder_function)
      ..' received)')
  assert(
    self._builder_function == nil,
    'Builder error: builder function defined twice. Builder function cannot be set more than once.')

  self._builder_function = builder_function
  return self
end

function builder_builder:build()
  -- builder function must be defined
  assert(
    self._builder_function,
    'Builder error: builder function not defined')

  -- Oh, the wonders of Lua! Here, we define a brand new class on-the-fly!
  local new_builder_class = class.build()
  new_builder_class._builder_function = self._builder_function
  new_builder_class._fields = self._fields

  function new_builder_class:_init()
    self._values = {}
    self._is_set = {}
  end

  for field_identifier in pairs(self._fields) do
    new_builder_class[field_identifier] = function(self, new_field_value)
      self._values[field_identifier] = new_field_value
      self._is_set[field_identifier] = true
      return self
    end
  end

  function new_builder_class:build()
    -- Use a copy because builders can be passed around and reused
    local values_copy = {}

    -- Process all builder fields and perform final validation
    for field_identifier,field_definition in pairs(new_builder_class._fields) do
      -- Ensure all fields are in a valid state
      assert(
        not field_definition.required or self._is_set[field_identifier],
        'Builder error: required field \''..field_identifier..'\' not set before building.')

      -- Be sure to apply default values where applicable
      values_copy[field_identifier] =
        ternary(
          self._is_set[field_identifier], self._values[field_identifier], field_definition.default)
    end

    return new_builder_class._builder_function(values_copy)
  end

  return new_builder_class
end

local builder = {}

function builder.builder()
  return builder_builder()
end

return builder
