local awful = require('awful')
local left_panel = require('layout.left-panel')
local workspace_panel = require('layout.workspace-panel')
local tasklist_panel = require('layout.tasklist-panel')
local mode_panel = require('layout.mode-panel')
local date_panel = require('layout.date-panel')
local clock_panel = require('layout.clock-panel')
local systemtray_panel = require('layout.systemtray-panel')
local volume_panel = require('layout.volume-panel')

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
    if s.index == 1 then
        s.left_panel = left_panel(s)
        s.mode_panel = mode_panel(s, true)
        s.tasklist_panel = tasklist_panel(s, true)
        s.workspace_panel = workspace_panel(s, true)
        s.date_panel = date_panel(s, true)
        s.clock_panel = clock_panel(s, true)
        s.systemtray_panel = systemtray_panel(s, true)
        s.volume_panel = volume_panel(s, true)
    else
        s.mode_panel = mode_panel(s, false)
        s.workspace_panel = workspace_panel(s, false)
        s.tasklist_panel = tasklist_panel(s, false)
        s.date_panel = date_panel(s, false)
        s.clock_panel = clock_panel(s, false)
        s.systemtray_panel = systemtray_panel(s, false)
        s.volume_panel = volume_panel(s, false)
    end
end)

local bars_visible = true

-- Toggle bars
function toggleBarsVisibility()
    bars_visible = not bars_visible
    for s in screen do
        s.workspace_panel.visible = bars_visible
        s.mode_panel.visible = bars_visible
        s.tasklist_panel.visible = bars_visible
        s.date_panel.visible = bars_visible
        s.clock_panel.visible = bars_visible
        s.systemtray_panel.visible = bars_visible
        s.volume_panel.visible = bars_visible
        if s.left_panel then
            s.left_panel.visible = bars_visible
        end
    end
end

-- Hide bars when app go fullscreen
function updateBarsVisibility()
    for s in screen do
        if s.selected_tag then
            local fullscreen = s.selected_tag.fullscreenMode
            local visibility = not fullscreen and bars_visible

            s.workspace_panel.visible = visibility
            s.mode_panel.visible = visibility
            s.tasklist_panel.visible = visibility
            s.date_panel.visible = visibility
            s.clock_panel.visible = visibility
            s.systemtray_panel.visible = visibility
            s.volume_panel.visible = visibility
            if s.left_panel then
                s.left_panel.visible = visibility
            end
        end
    end
end

_G.tag.connect_signal('property::selected',
                      function(t) updateBarsVisibility() end)

_G.client.connect_signal('property::fullscreen', function(c)
    c.screen.selected_tag.fullscreenMode = c.fullscreen
    updateBarsVisibility()
end)

_G.client.connect_signal('unmanage', function(c)
    if c.fullscreen then
        c.screen.selected_tag.fullscreenMode = false
        updateBarsVisibility()
    end
end)
