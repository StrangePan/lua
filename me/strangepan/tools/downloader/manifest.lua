local class = require 'me.strangepan.libs.util.v1.class'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'

function manifest.parse(source)
  assert_that(source):is_a_string()

  --[[ a manifest contains the following:

  a header containing:
  1. version number

  each file entry has:
  1. uri source
  2. file path destination
  3. (optional) file size
  ]]

  local header = parse_header()
  if not is_compatible_with(header) then
    error('incompatible with given manifest')
  end

  local entries = parse_entries()

  return {
    header = header,
    entries = entries,
  }
end
