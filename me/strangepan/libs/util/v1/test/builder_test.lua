local luaunit = require 'luaunit'
local builder = require 'me.strangepan.libs.util.v1.builder'

TestClass = {}

function TestClass:test_builderBuilder_withBuilderFunction_returnsBuilder()
  local my_builder_class =
  builder.builder()
  :builder_function(function() return {} end)
  :build()

  luaunit.assertNotNil(my_builder_class)
  luaunit.assertNotIs(my_builder_class, builder)
end

function TestClass:test_builderBuilder_withoutBuilderFunction_fails()
  luaunit.assertErrorMsgContains(
    'builder function',
    function()
      builder.builder():build()
    end)
end

function TestClass:test_builderBuilder_whenBuilderFunctionSetTwice_didThrowError()
  luaunit.assertErrorMsgContains(
    'once',
    function()
      builder.builder()
        :builder_function(function() return {} end)
        :builder_function(function() return {} end)
        :build()
    end)
end

function TestClass:test_builderBuilder_whenBuilderFunctionSetToNil_didThrowError()
  luaunit.assertErrorMsgContains(
    'function type',
    function()
      builder.builder()
        :builder_function(nil)
        :build()
    end)
end

function TestClass:test_builderBuilder_whenBuilderFunctionSetToTable_didThrowError()
  luaunit.assertErrorMsgContains(
    'function type',
    function()
      builder.builder()
        :builder_function{'hi mom'}
        :build()
    end)
end

function TestClass:test_builderBuilder_field_withNil_didThrowError()
  luaunit.assertErrorMsgContains(
    'named table',
    function()
      builder.builder():field(nil)
    end)
end

function TestClass:test_builderBuilder_field_withString_didThrowError()
  luaunit.assertErrorMsgContains(
    'named table',
    function()
      builder.builder():field('myfield')
    end)
end

function TestClass:test_builderBuilder_field_whenParameterNotNamed_didThrowError()
  luaunit.assertErrorMsgContains(
    'invalid field parameter type',
    function()
      builder.builder():field{'hi'}
    end)
end

function TestClass:test_builderBuilder_field_whenNameMispelled_didThrowError()
  luaunit.assertErrorMsgContains(
    'unrecognized',
    function()
      builder.builder():field{naem = 'hi'}
    end)
end

function TestClass:test_builderBuilder_field_whenNameNotSet_didThrowError()
  luaunit.assertErrorMsgContains(
    'name',
    function()
      builder.builder():field{}
    end)
end

function TestClass:test_builderBuilder_field_whenNameIsTable_didThrowError()
  luaunit.assertErrorMsgContains(
    'string type',
    function()
      builder.builder():field({name = {'hi mom'}})
    end)
end

function TestClass:test_builderBuilder_field_whenNameAlreadyDefined_didThrowError()
  luaunit.assertErrorMsgContains(
    'unique',
    function()
      builder.builder():field{name = 'hi'}:field{name = 'hi'}
    end)
end

function TestClass:test_builderBuilder_field_whenNameContainsSpace_didThrowError()
  luaunit.assertErrorMsgContains(
    'identifier',
    function()
      builder.builder():field{name = 'hi mom'}
    end)
end

function TestClass:test_builderBuilder_field_whenNameBeginsWithUnderscore_didThrowError()
  luaunit.assertErrorMsgContains(
    'underscore',
    function()
      builder.builder():field{name = '_yo'}
    end)
end

function TestClass:test_builderBuilder_field_whenNameIsBuild_didThrowError()
  luaunit.assertErrorMsgContains(
    'reserved',
    function()
      builder.builder():field{name = 'build'}
    end)
end

function TestClass:test_builderBuilder_field_whenRequiredIsString_didThrowError()
  luaunit.assertErrorMsgContains(
    'boolean type',
    function()
      builder.builder():field{name = 'hi', required = 'yes'}
    end)
end

function TestClass:test_builderBuilder_field_whenDefaultAndRequiredSet_didThrowError()
  luaunit.assertErrorMsgContains(
    'required field',
    function()
      builder.builder():field{name = 'hi', required = true, default = 'default greeting'}
    end)
end

function TestClass:test_builderBuilder_buildTwice_didReturnDistinctValues()
  local builder_builder = builder.builder():field{name = 'hi'}:builder_function(function() end)
  local test_builder1 = builder_builder:build()
  local test_builder2 = builder_builder:build()

  luaunit.assertEquals(type(test_builder1), 'table')
  luaunit.assertEquals(type(test_builder2), 'table')
  luaunit.assertNotIs(test_builder1, test_builder2)
end


-- Testing the builder created by our builder builder

function TestClass:test_builder_constructTwice_didReturnDistinctValues()
  local test_builder =
    builder.builder():field{name = 'hi'}:builder_function(function() end):build()
  local test_builder1 = test_builder()
  local test_builder2 = test_builder()

  luaunit.assertEquals(type(test_builder1), 'table')
  luaunit.assertEquals(type(test_builder2), 'table')
  luaunit.assertNotIs(test_builder1, test_builder2)
end

function TestClass:test_builder_withMultipleFields_defineSetters()
  local test_builder =
    builder.builder()
      :field {name = 'field1'}
      :field {name = 'field2', required = true}
      :field {name = 'field3', default = 132}
      :builder_function(function() end)
      :build()

  luaunit.assertEquals(type(test_builder.field1), 'function')
  luaunit.assertEquals(type(test_builder.field2), 'function')
  luaunit.assertEquals(type(test_builder.field3), 'function')
end

function TestClass:test_builder_build_withMultipleFields_didPassParametersToBuilderFunction()
  local field1_val = 'field_1_val'
  local field2_val = {'field', '2', 'val' }
  local field3_val = 132
  local invocation_count = 0
  local invocation_parameters
  local function builder_function(parameters)
    invocation_count = invocation_count + 1
    invocation_parameters = parameters
  end

  local test_builder =
    builder.builder()
      :field {name = 'field1'}
      :field {name = 'field2'}
      :field {name = 'field3'}
      :builder_function(builder_function)
      :build()

  test_builder()
    :field1(field1_val)
    :field2(field2_val)
    :field3(field3_val)
    :build()

  luaunit.assertEquals(invocation_count, 1)
  luaunit.assertEquals(type(invocation_parameters), 'table')
  luaunit.assertEquals(invocation_parameters.field1, field1_val)
  luaunit.assertEquals(invocation_parameters.field2, field2_val)
  luaunit.assertEquals(invocation_parameters.field3, field3_val)
end

function TestClass:test_builder_build_invokesBuilderFunction()
  local invocation_count = 0
  local function test_builder_function()
    invocation_count = invocation_count + 1
  end
  local builder_class = builder.builder():builder_function(test_builder_function):build()

  builder_class():build()

  luaunit.assertEquals(invocation_count, 1)
end

function TestClass:test_builder_build_returnsBuilderFunctionResult()
  local test_build_result = {'hi, mom'}
  local function test_builder_function()
    return test_build_result
  end
  local builder_class = builder.builder():builder_function(test_builder_function):build()

  local build_result = builder_class():build()

  luaunit.assertIs(build_result, test_build_result)
end

function TestClass:test_builder_build_withRequiredFieldNotSet_didThrowError()
  local test_builder_class =
    builder.builder()
      :field{name = 'field1', required = true}
      :builder_function(function() end)
      :build()

  luaunit.assertErrorMsgContains(
    'required',
    function()
      test_builder_class():build()
    end)
end

function TestClass:test_builder_build_withRequiredFieldSetToNil_didNotThrowError()
  local invocation_count = 0
  local function builder_function()
    invocation_count = invocation_count + 1
  end
  local test_builder_class =
    builder.builder()
      :field{name = 'field1', required = true}
      :builder_function(builder_function)
      :build()

  test_builder_class():field1(nil):build()

  luaunit.assertEquals(invocation_count, 1)
end

function TestClass:test_builder_build_withOptionalField_whenNotSet_didSetFieldToDefault()
  local field1_default_value = 'this was a triumph'
  local invocation_count = 0
  local invocation_parameters
  local function builder_function(parameters)
    invocation_count = invocation_count + 1
    invocation_parameters = parameters
  end
  local test_builder_class =
    builder.builder()
      :field{name = 'field1', default = field1_default_value}
      :builder_function(builder_function)
      :build()

  test_builder_class():build()

  luaunit.assertEquals(invocation_count, 1)
  luaunit.assertEquals(invocation_parameters.field1, field1_default_value)
end

function TestClass:test_builder_build_withOptionalField_whenNotSet_didSetFieldToNil()
  local invocation_count = 0
  local invocation_parameters
  local function builder_function(parameters)
    invocation_count = invocation_count + 1
    invocation_parameters = parameters
  end
  local test_builder_class =
    builder.builder()
      :field{name = 'field1'}
      :builder_function(builder_function)
      :build()

  test_builder_class():build()

  luaunit.assertEquals(invocation_count, 1)
  luaunit.assertNil(invocation_parameters.field1)
end

function TestClass:test_builder_build_withOptionalField_whenSetToNil_didSetFieldToNil()
  local field1_default_value = 'this was a triumph'
  local invocation_count = 0
  local invocation_parameters
  local function builder_function(parameters)
    invocation_count = invocation_count + 1
    invocation_parameters = parameters
  end
  local test_builder_class =
    builder.builder()
      :field{name = 'field1', default = field1_default_value}
      :builder_function(builder_function)
      :build()

  test_builder_class():field1(nil):build()

  luaunit.assertEquals(invocation_count, 1)
  luaunit.assertNil(invocation_parameters.field1)
end

function TestClass:test_builder_buildTwice_whenBuilderFunctionModifiesParams_didUseFreshParams()
  local invocation_count = 0
  local latest_invocation_parameters
  local function builder_function(parameters)
    invocation_count = invocation_count + 1
    latest_invocation_parameters = parameters
    parameters.field1 = parameters.field1 + 1
  end
  local test_builder_class =
    builder.builder()
      :field{name = 'field1', default = 0}
      :builder_function(builder_function)
      :build()

  local test_builder_instance = test_builder_class()
  test_builder_instance:build()
  test_builder_instance:build()

  luaunit.assertEquals(invocation_count, 2)
  luaunit.assertEquals(latest_invocation_parameters.field1, 1)
end

os.exit(luaunit.LuaUnit.run())
