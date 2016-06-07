-- local version of menu
local show_menu = function(items, onselect)
    local ch=hs.chooser.new(function(x) onselect(x) end)
    ch:choices(hs.fnutils.imap(items,function(x) return {text=x} end))
    ch:show()
end

return show_menu
