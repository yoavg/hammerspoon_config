--========================================= THE WM ===================
local c = require "circular"
local menu = require "menu"
--local menu = require "lmenu"

ttn = c.TTN:new()

local next_tag = function()
    local t = ttn:next_tag()
    hs.alert.show(t)
    ttn:show_tag(t)
end
local prev_tag = function()
    local t = ttn:prev_tag()
    hs.alert.show(t)
    ttn:show_tag(t)
end
local show_cur_tag = function()
    hs.alert.show(ttn:current_tag())
end
local select_tag = function()
    menu(ttn:tags(), function(tag)
        hs.alert.show(tag)
        ttn:set_current_tag(tag); ttn:show_tag(tag) end)
end
local next_window = function()
    local t = ttn:current_tag()
    if t == nil then return t end
    local wins = ttn.tag_to_windows[t]
    if wins == nil then return wins end
    if wins:cur():id() ~= hs.window.focusedWindow():id() then
        ttn:focus(wins:cur())
    else
        while (ttn:focus(wins:fwd()) < 0) do end
    end
end
local prev_window = function()
    local t = ttn:current_tag()
    if t == nil then return t end
    local wins = ttn.tag_to_windows[t]
    if wins == nil then return wins end
    while (ttn:focus(wins:back()) < 0) do end
end
local select_window_for_current_tag = function()
    local t = ttn:current_tag()
    if t == nil then return t end
    local wins = ttn.tag_to_windows[t]
    wins:menu_select(wins.app_title, function(win)
        wins:set(win)
        ttn:focus(win)
    end)
end

local switch_to_tag = function(tag)
        ttn:set_current_tag(tag); ttn:show_tag(tag) end

local _tag_window_with_optional_hotkey = function(win, tag)
        ttn:add_tag_to_window(win, tag)
        local key = tag:gmatch(".*~(.).*")()
        if key ~= nil then 
            hs.alert.show("bound " .. key)
            hs.hotkey.bind({"alt","ctrl"}, key, function() ttn:set_current_tag(tag); ttn:show_tag(tag) end)
            hs.hotkey.bind({"alt"}, key,        function() ttn:show_tag(tag) end)
        end
end

local tag_focused_window = function()
    menu(ttn:tags(), function(tag)
        hs.alert.show(tag)
        _tag_window_with_optional_hotkey(hs.window.focusedWindow(), tag)
    end)
end

local remove_selected_tag_from_focused_window = function()
    local win = hs.window.focusedWindow()
    menu(ttn:get_tags_of_window(win), function(tag)
        ttn:remove_tag_from_window(win, tag) end)
end

--[[
local select_global_window = function() 
    --local windows = hs.window.allWindows()
    local windows = hs.window.filter.new():getWindows()
    local titles = hs.fnutils.imap(windows,function(w) 
        return table.concat({w:application():title(), " : ", w:title()}) end)
    menu(titles, function(ttl) 
        local idx = hs.fnutils.indexOf(titles, ttl)
        local sel = windows[idx] -- hs.fnutils.ifilter(windows,function(w) return w:title() == ttl end)
        if (sel ~= nil) then sel:focus() end
    end)
end
--]]

local select_window = function(winlist_func, win_titles_func, win_action_func)
    local windows = winlist_func()
    local titles = win_titles_func(windows)
    menu(titles, function(ttl)
        local idx = hs.fnutils.indexOf(titles, ttl)
        local sel = windows[idx]
        if (sel ~= nil) then 
            win_action_func(sel) end
    end)
end

ALL_WINDOWS = function()
    return hs.window.filter.new():getWindows() 
end

WIN_TITLES = function(windows)
    return hs.fnutils.imap(windows,
                    function(w) 
                        return table.concat({w:application():title(), 
                                            " : ", 
                                            w:title()}) end)
end


local select_global_window = function() 
    select_window(ALL_WINDOWS, WIN_TITLES, function (w) w:focus() end)
end

local select_untagged_window = function() 
    select_window(function() return ttn:get_untagged_windows():windows() end, WIN_TITLES, function (w) w:focus() end)
end


local _all_wins_filter = hs.window.filter.new():setDefaultFilter()
_all_wins_filter:subscribe(hs.window.filter.windowCreated,
                    function (_win, _ttl, _last)
                        if ttn:current_tag() ~= nil then
                            _tag_window_with_optional_hotkey(_win, ttn:current_tag())
                        end
                    end)
_all_wins_filter:subscribe(hs.window.filter.windowDestroyed,function(win,b,c) ttn:closed_window(win) end)

-- menubar item
local tags_mb = hs.menubar.newWithPriority(hs.menubar.priorities['system'])
tags_mb:setTitle('noTag')
function tags_cb(tag)
    tags_mb:setTitle("-- " .. tag .. " --")
end
ttn:set_tagchange_callback(tags_cb)
menuFn = function() -- first tags, then windows in current tag
    local _tags_menu = fn.imap(ttn:tags(), function(tag) return {title=tag, fn=function() ttn:set_current_tag(tag) ttn:show_tag(tag) end} end) 
    local _windows = ttn:windows_for_tag(ttn:current_tag())
    local _windows_menu = fn.imap(_windows:windows(), function (win) return {title=win:title(), fn=function() _windows:set(win) ttn:focus(win) end} end)
    _tags_menu = hs.fnutils.concat(_tags_menu,{{title="-----",fn=function() end}} )
    return hs.fnutils.concat(_tags_menu,_windows_menu)
end
tags_mb:setMenu(menuFn)

return { next_tag = next_tag,
         prev_tag = prev_tag,
         show_cur_tag = show_cur_tag,
         select_tag = select_tag,
         next_window = next_window,
         prev_window = prev_window,
         select_window = select_window_for_current_tag,
         select_global_window = select_global_window,
         tag_focused_window = tag_focused_window,
         remove_selected_tag_from_focused_window = remove_selected_tag_from_focused_window,
         windows_for_current_tag = function() return ttn:windows_for_tag(ttn:current_tag()) end,
         untagged_windows = function() return ttn:get_untagged_windows() end,
         select_untagged_window = select_untagged_window,
     }
    
