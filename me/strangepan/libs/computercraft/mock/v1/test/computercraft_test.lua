local luaunit = require 'luaunit'
local mock_computercraft = require 'me.strangepan.libs.computercraft.mock.v1.computercraft'

TestClass = {}

function TestClass:setup()
  self.system_os = os
  self.system_turtle = turtle
  self.test_os = {'test_os'}
  self.test_turtle = {'test_turtle' }
  self.test_mock_os = {'test_mock_os' }
  self.test_mock_turtle = {'test_mock_turtle'}
  os = self.test_os
  turtle = self.test_turtle
  self.under_test = mock_computercraft.builder():build()
end

function TestClass:teardown()
  os = self.system_os or os
  turtle = self.system_turtle or turtle
end

function TestClass:test_capture_didReturnSelf()
  luaunit.assertIs(self.under_test:capture(), self.under_test)
end

function TestClass:test_capture_didOverwriteOs()
  self.under_test:capture()

  luaunit.assertNotIs(os, self.test_os)
end

function TestClass:test_capture_whenTurtleNotDefined_didOverwriteTurtle()
  turtle = nil
  self.under_test = mock_computercraft.builder():build()

  self.under_test:capture()

  luaunit.assertNotIs(turtle, self.test_turtle)
  luaunit.assertNotNil(turtle)
end

function TestClass:test_capture_whenTurtleDefined_didNotOverwriteTurtle()
  self.under_test:capture()

  luaunit.assertIs(turtle, self.test_turtle)
end

function TestClass:test_release_didReturnSelf()
  luaunit.assertIs(self.under_test:release(), self.under_test)
end

function TestClass:test_capture_thenRelease_didReturnSelf()
  luaunit.assertIs(self.under_test:capture():release(), self.under_test)
end

function TestClass:test_capture_thenRelease_didRestoreOs()
  self.under_test:capture():release()

  luaunit.assertIs(os, self.test_os)
end

function TestClass:test_capture_thenRelease_didRestoreTurtle()
  self.under_test:capture():release()

  luaunit.assertIs(turtle, self.test_turtle)
end

function TestClass:test_capture_thenRelease_whenTurtleNotDefined_didRestoreTurtle()
  turtle = nil
  self.under_test = mock_computercraft.builder():build()

  self.under_test:capture():release()

  luaunit.assertNil(turtle)
end

function TestClass:test_captureTwice_thenRelease_didRestoreOs()
  self.under_test:capture():capture():release()

  luaunit.assertIs(os, self.test_os)
end

function TestClass:test_captureTwice_thenRelease_didRestoreTurtle()
  self.under_test:capture():capture():release()

  luaunit.assertIs(turtle, self.test_turtle)
end

function TestClass:test_capture_withCustomMockOs_didUseCustomOs()
  mock_computercraft.builder():mock_os(self.test_mock_os):build():capture()

  luaunit.assertIs(os, self.test_mock_os)
end

function TestClass:test_capture_withCustonMockTurtle_didUseCustomTurtle()
  mock_computercraft.builder():mock_turtle(self.test_mock_turtle):build():capture()

  luaunit.assertIs(turtle, self.test_mock_turtle)
end

os.exit(luaunit.LuaUnit.run())
