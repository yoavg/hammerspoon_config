
local show_menu = function(items, onselect)
    local cmd = "~/.hammerspoon/choose"
    if #items == 0 then items = {"*NEW*"} end
    local args = {"-m", "-I", table.concat(items,"\n")}
    hs.task.new(cmd, function(exitCode, stdOut, stdErr)
        if stdOut ~= "" then onselect(stdOut) end
    end, args):start()
end

return show_menu
