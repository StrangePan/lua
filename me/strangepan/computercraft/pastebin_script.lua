local SCRIPT_URL = 'http://files.strangepan.me/computercraft/pastebin_entrypoint.lua'

print('This program will download and run:')
print(SCRIPT_URL)

local user_response

repeat
  io.write('Continue? (y/n): ')
  user_response = io.read()
  local supported_responses = {
    'y'=true,
    'n'=true,
  }
  if not supported_responses[user_response] then
    user_response = nil
  end
until user_response

if user_response == 'n' then
  return
end

print('Downloading script...')

local script_handle = http.get(SCRIPT_URL)
if not script_handle then
  print('Script download failed')
  return
end

local script_contents = script_handle.readAll()
script_handle.close()

print('Running script...')
loadstring(script_contents)()
