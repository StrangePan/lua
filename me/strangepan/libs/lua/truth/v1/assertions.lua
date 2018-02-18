local assertion = require 'me.strangepan.libs.lua.truth.v1.assertion'

local assertions = {}

assertions.is_a_string = assertion.of_type('string')

assertions.is_a_table = assertion.of_type('table')
