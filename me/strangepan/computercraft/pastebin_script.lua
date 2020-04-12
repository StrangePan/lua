local FILE_NAME = 'pastebin_entrypoint.lua'
local SCRIPT_URL = 'http://files.strangepan.me/computercraft/'..FILE_NAME

print('This program will download and run:')
print(SCRIPT_URL)

local user_response

repeat
  io.write('Continue? (y/n): ')
  user_response = io.read()
  local supported_responses = {
    y=true,
    n=true,
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

print('Downloaded '..#script_contents..' bytes')

local TEMP_FILE_NAME = FILE_NAME..'.tmp'
print('Saving to temp file '..TEMP_FILE_NAME)
local f = fs.open(TEMP_FILE_NAME, 'w')
f.write(script_contents)
f.close()

print('Running script...')
local function run_script() 
  dofile(TEMP_FILE_NAME)
end

local success, result = pcall(run_script)

if not success then
  print('Error while running downloaded script: '..result)
end

print('Deleting temporary file '..TEMP_FILE_NAME)
fs.delete(TEMP_FILE_NAME)

print('Done')
