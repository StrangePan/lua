local SCRIPT_URL = 'http://files.strangepan.me/computercraft/pastebin_entrypoint.lua'

print('This program will download and run a remote program from:\n')
print(SCRIPT_URL)

local user_response

do
  io.write('Continue? (y/n): ')
  user_response = io.read()
  if not {'y'=true, 'n'=true}[user_response] then
    user_response = nil
  end
until user_response ~= nil end

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
loadstring(script_contents)
