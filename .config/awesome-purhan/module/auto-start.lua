-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require('awful')
local apps = require('configuration.apps')

local function run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(' ')
  if firstspace then
    findme = cmd:sub(0, firstspace - 1)
  end

  awful.spawn.with_shell(string.format("bash -c 'pgrep -u $USER -x %s > /dev/null || (%s)'", findme, cmd))

  --Could use awful.spawn.single_instance() maybe.. research needed

end

for _, app in ipairs(apps.run_on_start_up) do
  run_once(app)
end
