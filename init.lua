sp = require("hs._asm.undocumented.spaces")

require "debug"
require "movement"
require "tags"



-- Experimental ----------
-- Hide all
hide_all = function()
    apps = hs.application.runningApplications() 
    hs.fnutils.each(apps,function(app) app:hide() end)
end
hs.hotkey.bind({"ctrl","alt","cmd"},"h",hide_all)


--[[
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

--hs.hotkey.bind({"cmd","shift"}, "`", add_current_space_to_list)
--hs.hotkey.bind({"cmd"}, "`", next_space_in_list)
--hs.hotkey.bind({"cmd","shift"}, "escape", remove_current_space_from_list)
--]]

--------
hidden_space = sp.createSpace()
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "R", function()
  sp.removeSpace(hidden_space) -- clean after us
  hs.reload()
end)


