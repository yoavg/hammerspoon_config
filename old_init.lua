sp = require("hs._asm.undocumented.spaces")

require "movement"
require "debug"




-------- loopy Space switching

local space_list = { }
local space_list_idx = 1
local add_current_space_to_list = function() 
    local spc = sp.activeSpace()
    table.insert(space_list, spc)
end

local remove_current_space_from_list = function()
    local spc = sp.activeSpace()
    space_list = hs.fnutils.ifilter(space_list, function(el) return spc ~= el end)
    if space_list_idx > #space_list then space_list_idx = #space_list end
end

local next_space_in_list = function()
    if #space_list == 0 then return end
    space_list_idx = space_list_idx + 1
    if space_list_idx > #space_list then space_list_idx = 1 end
    if space_list[space_list_idx] ~= sp.activeSpace() then
        sp.changeToSpace(space_list[space_list_idx])
    end
end

hs.hotkey.bind({"cmd","shift"}, "`", add_current_space_to_list)
hs.hotkey.bind({"cmd"}, "`", next_space_in_list)
hs.hotkey.bind({"cmd","shift"}, "escape", remove_current_space_from_list)


--------
buf = require "circular"

local hidden_space = sp.createSpace()
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "R", function()
  sp.removeSpace(hidden_space) -- clean after us
  hs.reload()
end)
hs.alert.show("Config loaded")


local show_menu = function(items, onselect)
    local cmd = "~/.hammerspoon/choose"
    local args = {"-m", "-I", table.concat(items,"\n")}
    hs.task.new(cmd, function(exitCode, stdOut, stdErr)
        if stdOut ~= "" then onselect(stdOut) end
    end, args):start()
end

-- TODO make local
tags_window_mapping = {}
id_to_window_mapping = {}
add_tag_to_window = function(win, tag) 
    if tags_window_mapping[tag] == nil then
        tags_window_mapping[tag] = {}
    end
    tags_window_mapping[tag][win:id()] = true
    id_to_window_mapping[win:id()] = win
end

-- TODO make local
clear_tags_from_window = function(win)
    local win_id = win:id()
    for tag,mappings in pairs(tags_window_mapping) do
        if mappings ~= nil then
            if mappings[win_id] ~= nil then
                hs.alert.show("removing")
                tags_window_mapping[tag][win_id]=nil
                id_to_window_mapping[win_id]=nil
            end
        end
    end
end

-- TODO make local
show_tags_window_mapping = function()
    local s = ""
    for tag,winids in pairs(tags_window_mapping) do
        s = s .. tag .. " : "
        for wid,tf in pairs(winids) do
            local ttl = id_to_window_mapping[wid]:title()
            s = s .. ttl .. "  --  "
        end
        s = s .. "\n"
    end
    hs.alert.show(s,5)
end

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

local titleChooser = function() 
    local cmd = "~/choose"
    --local windows = hs.window.allWindows()
    local windows = hs.window.filter.new():getWindows()
    local titles = hs.fnutils.imap(windows,function(w) 
        return table.concat({w:application():title(), " : ", w:title()}) end)
    show_menu(titles, function(ttl) 
        local idx = hs.fnutils.indexOf(titles, ttl)
        local sel = windows[idx] -- hs.fnutils.ifilter(windows,function(w) return w:title() == ttl end)
        if (sel ~= nil) then sel:focus() end
    end)
end
hs.hotkey.bind({"cmd","alt"},"p",titleChooser)

-- TODO make the keybinds *modal* ??
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"1", function() add_tag_to_window(hs.window.focusedWindow(), "g1") end)
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"2", function() add_tag_to_window(hs.window.focusedWindow(), "g2") end)
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"3", function() add_tag_to_window(hs.window.focusedWindow(), "g3") end)
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"4", function() add_tag_to_window(hs.window.focusedWindow(), "g4") end)
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"5", function() add_tag_to_window(hs.window.focusedWindow(), "g5") end)
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"6", function() add_tag_to_window(hs.window.focusedWindow(), "g6") end)
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"7", function() add_tag_to_window(hs.window.focusedWindow(), "g7") end)

hs.hotkey.bind({"cmd","alt"},"1", function() toggle_tag_state("g1") end)
hs.hotkey.bind({"cmd","alt"},"2", function() toggle_tag_state("g2") end)
hs.hotkey.bind({"cmd","alt"},"3", function() toggle_tag_state("g3") end)
hs.hotkey.bind({"cmd","alt"},"4", function() toggle_tag_state("g4") end)
hs.hotkey.bind({"cmd","alt"},"5", function() toggle_tag_state("g5") end)
hs.hotkey.bind({"cmd","alt"},"6", function() toggle_tag_state("g6") end)
hs.hotkey.bind({"cmd","alt"},"7", function() toggle_tag_state("g7") end)

hs.hotkey.bind({"cmd","alt","ctrl","shift"},"c", function()
    clear_tags_from_window(hs.window.focusedWindow())
end)
hs.hotkey.bind({"cmd","alt","ctrl","shift"},"m", show_tags_window_mapping)

hs.hotkey.bind({"cmd","alt","ctrl"}, "f", function()
    tagFocusedWindow()
end)

hs.hotkey.bind({"cmd","alt"}, "t", function()
    tags_menu(function(tag) hs.alert.show(tag); toggle_tag_state(tag) end) end)

hs.hotkey.bind({"cmd","alt"}, "f", function()
    tags_menu(function(tag) hs.alert.show(tag); focus_tag_window(tag) end) end)



