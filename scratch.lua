local c = require "circular"

local scratch = c.TTN:new()

--[[
local show_window = function(win_id)
    current_space = sp.activeSpace()
    wspaces = win:spaces()
    if #wspaces == 1 and wspaces[1] ~= current_space then
        sp.moveWindowToSpace(win_id, current_space)
    end
    id_to_window_mapping[win_id]:focus()
end

local hide_window = function(win_id)
    current_space = sp.activeSpace()
    wspaces = win:spaces()
    if #wspaces == 1 and wspaces[1] ~= hidden_space then
        sp.moveWindowToSpace(win_id, hidden_space)
    end
end

local toggle_window = function(win_id)
    current_space = sp.activeSpace()
    local win = id_to_window_mapping[win_id]
    if win == nil then return end
    wspaces = win:spaces()
    if #wspaces == 1 and wspaces[1] == current_space then
        if win:id() ~= hs.window.focusedWindow():id() then win:focus() 
        else sp.moveWindowToSpace(win_id, hidden_space)
        end
    elseif #wspaces == 1 then
        sp.moveWindowToSpace(win_id, current_space)
        win:focus()
    end
end

local toggle_tag_state = function(tag) 
    local win_ids = tags_window_mapping[tag]
    if win_ids == nil then 
        hs.alert.show("no associated windows")
    else
        for win_id,tf in pairs(win_ids) do
            if tf and win_id ~= nil then toggle_window(win_id) end
        end
    end
end

local show_tag_windows = function(tag) 
    local win_ids = tags_window_mapping[tag]
    if win_ids == nil then 
        hs.alert.show("no associated windows")
    else
        hs.alert.show(hs.inspect(win_ids))
        for win_id,tf in pairs(win_ids) do
            if tf and win_id ~= nil then show_window(win_id) end
        end
    end
end

local focus_tag_window = function(tag) 
    local win_ids = tags_window_mapping[tag]
    if win_ids == nil then 
        hs.alert.show("no associated windows")
    else
        hs.alert.show(hs.inspect(win_ids))
        for win_id,tf in pairs(win_ids) do
            if tf and win_id ~= nil then id_to_window_mapping[win_id]:focus() end
        end
    end
end

local tags_menu = function(onselect) 
    local tags = {}
    for k,v in pairs(tags_window_mapping) do table.insert(tags,k) end
    if #tags == 0 then tags[1] = "*NEW*" end
    show_menu(tags, function(tag) onselect(tag) end)
end

local tagFocusedWindow = function()
    local win = hs.window.focusedWindow()
    tags_menu(function (tag)
        add_tag_to_window(win, tag)
        --local key = tag:gmatch("~([^ ]+).*")()
        local key = tag:gmatch(".*~(.).*")()
        if key ~= nil then 
            hs.alert.show("bound " .. key)
            hs.hotkey.bind({"alt"}, key, function() toggle_tag_state(tag) end)
        end
    end)
end
--]]
