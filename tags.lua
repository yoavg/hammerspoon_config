local c = require "wm"
--local s = require "scratch"

hs.hotkey.bind({"ctrl"},"tab",c.next_tag)
hs.hotkey.bind({"ctrl","shift"},"tab",c.prev_tag)
hs.hotkey.bind({"ctrl"},"`",c.select_tag)
--hs.hotkey.bind({"ctrl","alt","cmd"},"t",c.select_tag)
hs.hotkey.bind({"ctrl","alt","cmd"},"c",c.show_cur_tag)

--hs.hotkey.bind({"ctrl","alt"},"w",c.select_window)
hs.hotkey.bind({"alt"},"tab",c.next_window)
hs.hotkey.bind({"alt"},"`",c.select_window)
hs.hotkey.bind({"alt","shift"},"tab",c.prev_window)

hs.hotkey.bind({"cmd"},"`",c.select_global_window)
hs.hotkey.bind({"alt","shift"},"`",c.select_global_window)

hs.hotkey.bind({"alt","shift"},"tab",c.prev_window)

hs.hotkey.bind({"ctrl","alt"},"m",c.tag_focused_window)
hs.hotkey.bind({"ctrl","alt","cmd"},"space",c.tag_focused_window)

hs.hotkey.bind({"ctrl","alt","cmd"},"delete",c.remove_selected_tag_from_focused_window)


hs.hotkey.bind({"ctrl"},"e",function () hs.expose.expose(c.windows_for_current_tag():windows())end)
hs.hotkey.bind({"ctrl"},"u",function () c.select_untagged_window() end)

--- some modal stuff
-- TODO: indicate mode with a fixed sign / instructions
tags_mode = hs.hotkey.modal.new('cmd-alt-ctrl', 't')
function tags_mode:entered() hs.alert'tags mode' end
function tags_mode:exited() hs.alert'exit tags mode' end
tags_mode:bind('', 'escape', function() tags_mode:exit() end)
tags_mode:bind('', 'left', nil,function() c.prev_tag() end)
tags_mode:bind('', 'right', nil,function() c.next_tag() end)

-- modal -- all windows cycler
-- TODO visual mode indicator!
local circ = require "circular"
local function all_windows()
    winlist = hs.window.filter.new():getWindows()
    wins = circ.wincirc:new()
    wins:add_windows(winlist)
    return wins
end
local function next_in_app(wins) -- TODO efficiency
    app = wins:cur():application()
    nxt = wins:fwd():application()
    while (nxt ~= app) do
        nxt = wins:fwd():application()
    end
    wins:cur():focus()
end
local function prev_in_app(wins) -- TODO efficiency
    app = wins:cur():application()
    nxt = wins:back():application()
    while (nxt ~= app) do nxt = wins:back():application() end
    wins:cur():focus()
end
local wins_mode = hs.hotkey.modal.new({"ctrl","alt","cmd"},"q")
function wins_mode:entered() _windows = all_windows() hs.alert('wins mode') end
function wins_mode:exited() hs.alert('end wins mode') end
wins_mode:bind('','escape',nil,function() wins_mode:exit() end)
wins_mode:bind('','return',nil,function() wins_mode:exit() end)
wins_mode:bind('','right',nil,function() _windows:fwd():focus() end)
wins_mode:bind('','left',nil,function() _windows:back():focus() hs.alert(hs.window.focusedWindow():title()) end)
wins_mode:bind('','down',nil, function() next_in_app(_windows) end)
wins_mode:bind('','up',nil, function() prev_in_app(_windows) end)
wins_mode:bind('ctrl','c',nil,function() hs.window.focusedWindow():close() end)
wins_mode:bind('ctrl','t',nil, c.tag_focused_window)
wins_mode:bind('ctrl','u',nil,c.remove_selected_tag_from_focused_window)
wins_mode:bind('ctrl','r',nil,hs.grid.show)

