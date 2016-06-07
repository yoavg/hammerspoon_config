
fn = require "hs.fnutils"
menu = require "menu"


local circ = {}
circ.__index = circ
function circ:new()
      self = setmetatable({}, circ)
      self.i = 1
      self._items = {}
      return self
end

function circ:add(v)
    if not fn.contains(self._items, v) then
        table.insert(self._items, v)
    end
    return self
end

function circ:remove(v)
    self._items = fn.ifilter(self._items,function(x) return x~=v end)
end

function circ:contains(v)
    return fn.contains(self._items, v)
end

function circ:cur()
    if self.i > #(self._items) then self.i = 1 end
    return self._items[self.i]
end

function circ:fwd()
    self.i = self.i + 1
    if self.i > #(self._items) then self.i = 1 end
    return self._items[self.i]
end

function circ:back()
    self.i = self.i - 1
    if self.i < 1 then self.i = #(self._items) end
    return self._items[self.i]
end

function circ:set(v)
    if fn.contains(self._items,v) then
        while self:cur() ~= v do
            self:fwd()
        end
    else
        self:add(v)
        while self:cur() ~= v do
            self:fwd()
        end
    end
end

function circ:_items_str()
    return table.concat(self._items, " ")
end

function circ:items()
    local res = {}
    for i=1,#(self._items) do
        table.insert(res,self:fwd())
    end
    return res
    --return self._items
end

function circ:size()
    return #(self._items)
end

--=========================================================
local id_to_window = {}
local wincirc = {}
wincirc.__index = wincirc
function wincirc:new()
      self = setmetatable({}, wincirc)
      self.circ = circ:new()
      return self
end

function wincirc:add_windows(winlist)
    for i,w in ipairs(winlist) do
        self:add(w)
    end
end

function wincirc:add(win) 
    id_to_window[win:id()] = win
    return self.circ:add(win:id()) end

function wincirc:remove(win)
    id_to_window[win:id()] = win
    return self.circ:remove(win:id()) end

function wincirc:contains(win) 
    id_to_window[win:id()] = win
    return self.circ:contains(win:id()) end

function wincirc:cur() return id_to_window[self.circ:cur()] end
function wincirc:fwd() return id_to_window[self.circ:fwd()] end
function wincirc:back() return id_to_window[self.circ:back()] end
function wincirc:set(win) return self.circ:set(win:id()) end

function wincirc:windows()
    return fn.imap(self.circ:items(), function(wid) return id_to_window[wid] end)
end

function wincirc:titles()
    return fn.imap(self:windows(), function(w) return w:title() end)
end

function wincirc:size() return self.circ:size() end

function wincirc.title(w) return w:title() end
function wincirc.app_title(w) 
    return w:application():title() .. " \t :" .. w:title() end

function wincirc:menu_select(win_to_text, onselect)
    local map = {}
    local items = {}
    for i,win in ipairs(self:windows()) do
        local txt = win_to_text(win)
        map[txt] = win
        table.insert(items,txt)
    end
    menu(items, function(txt) onselect(map[txt]) end)
end


--=========================================================
local TTN = {}
TTN.__index = TTN
function TTN:new()
      self = setmetatable({}, TTN)
      self.tag_to_windows = {}
      self.tagged_windows = {}
      self._tags = circ:new()
      self._tagcb = nil
      return self
end

function TTN:add_tag_to_window(win, tag)
    self._tags:add(tag)
    if self.tag_to_windows[tag] == nil then
        self.tag_to_windows[tag] = wincirc:new()
    end
    self.tagged_windows[win:id()] = true
    self.tag_to_windows[tag]:add(win)
end

function TTN:clear_tags_from_window(win)
    id_to_window[win:id()] = win
    for tag,wins in pairs(self.tag_to_windows) do
        wins:remove(win)
        if wins:size() == 0 then
            self:remove_tag(tag)
        end
    end
end

function TTN:remove_tag_from_window(win, tag)
    if self.tag_to_windows[tag] ~= nil then
        self.tag_to_windows[tag]:remove(win)
        if self.tag_to_windows[tag]:size() == 0 then
            self:remove_tag(tag)
        end
    end
end

function TTN:remove_tag(tag)
    self.tag_to_windows[tag] = nil
    self._tags:remove(tag)
    if #(self:tags()) == 0 and self._tagcb ~= nil then self._tagcb('noTags') end
end

function TTN:windows_for_tag(tag)
    local wins = self.tag_to_windows[tag]
    if wins == nil then
        wins = wincirc:new()
        self.tag_to_windows[tag] = wins
    end
    return wins
end

function TTN:closed_window(win)
    for tag,wins in pairs(self.tag_to_windows) do
        wins:remove(win)
        if wins:size() == 0 then self:remove_tag(tag) end
    end
end

function TTN:show_mapping()
    local res = {}
    for i,tag in ipairs(self:tags()) do
        local wins = self:windows_for_tag(tag)
        local ttls = wins:titles()
        table.insert(res,tag .. " - " .. table.concat(ttls," "))
    end
    hs.alert.show(table.concat(res,"\n"))
end

function TTN:tags()
    return self._tags:items()
end

function TTN:get_tagged_windows_ids()
    local res = {}
    for i,tag in ipairs(self:tags()) do
        local wins = self:windows_for_tag(tag)
        for _,win in ipairs(wins) do
            res[win:id()] = true
        end
    end
    return res
end

function TTN:get_untagged_windows()
    local tagged = self:get_tagged_windows_ids()
    local all_windows = hs.window.filter.new():getWindows()
    local untagged = hs.fnutils.filter(all_windows,
        function (w) return tagged[w:id()] ~= true end)
    local res = wincirc:new()
    res:add_windows(untagged)
    return res
end

--TODO make efficient
function TTN:get_tags_of_window(win)
    local tags = fn.ifilter(self:tags(), function(t) return self.tag_to_windows[t]:contains(win) end)
    return tags
end

function TTN:show_tag(tag) -- show windows for tag
    for i,win in ipairs(self:windows_for_tag(tag):windows()) do
        self:focus(win)
    end
end

function TTN:focus(win)
    if win:role() ~= "" then
        win:focus()
        return 1
    else -- closed window?
        self:closed_window(win)
        return -1
    end
end

function TTN:set_tagchange_callback(cb) self._tagcb = cb end

function TTN:next_tag() return self._tags:fwd() end
function TTN:prev_tag() return self._tags:back() end
function TTN:current_tag() return self._tags:cur() end
function TTN:set_current_tag(tag) 
    if self._tagcb ~= nil then self._tagcb(tag) end
    return self._tags:set(tag)
end




return { wincirc = wincirc, circ = circ, TTN=TTN }
