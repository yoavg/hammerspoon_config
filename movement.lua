
--=================== MOVE / RESIZE / FOCUS ===========================
-- cmd+alt      + arrows  -- resize
-- cmd+alt      + /       -- maximize/center
-- cmd+alt      + g       -- grid resize
-- ^+alt        + arrows  -- move
-- ^+cmd+alt    + arrows  -- focus, sort-of

-- Toggle a window between its normal size, and being maximized
local frameCache = {}
function toggle_window_maximized()
    local win = hs.window.focusedWindow()
    if frameCache[win:id()] ~= nil then
        win:setFrame(frameCache[win:id()], 0)
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize(0)
    end
end

RESIZE={"cmd","alt"}
MOVEW={"ctrl","alt"}
FOCUSW={"ctrl","alt","cmd"}

hs.grid.GRIDWIDTH = 4
hs.grid.GRIDHEIGHT = 4
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

hs.hotkey.bind(RESIZE, "g", hs.grid.show)

hs.hotkey.bind(MOVEW, "left", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    jump = max.w / 4
    f.x = f.x - jump
    win:setFrame(f, 0)
end)
hs.hotkey.bind(MOVEW, "right", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    jump = max.w / 4
    f.x = f.x + jump
    win:setFrame(f, 0)
end)
hs.hotkey.bind(MOVEW, "up", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    jump = max.h / 4
    f.y = f.y - jump
    win:setFrame(f, 0)
end)
hs.hotkey.bind(MOVEW, "down", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    jump = max.h / 4
    f.y = f.y + jump
    win:setFrame(f, 0)
end)

hs.hotkey.bind(RESIZE, "/", toggle_window_maximized)

hs.hotkey.bind(RESIZE, "c", function() 
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    dy = max.h / 4
    dx = max.w / 4
    f.x = max.x + dx
    f.w = max.w - dx - dx
    f.y = max.y + dy
    f.h = max.h - dy - dy
    win:setFrame(f, 0)
end)

hs.hotkey.bind(RESIZE, "right", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local EPS = 5

    local jump = max.w / 4

    if (f.x + f.w >= max.w - EPS) -- at edge, shrink
    then
        f.x = f.x + jump
        f.w = f.w - jump
    else -- not at edge, grow
        f.w = f.w + jump
    end
    if f.x + f.w > max.w then f.w = max.w - f.x end
    win:setFrame(f, 0)
	if win:isStandard() then hs.grid.snap(win) end
end)

hs.hotkey.bind(RESIZE, "left", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local EPS = 5

    local jump = max.w / 4

    if (f.x <= max.x + EPS) -- at edge, shrink
    then
        f.w = f.w - jump
    else -- not at edge, grow
        f.x = f.x - jump
        f.w = f.w + jump
    end
    if f.x < max.x then f.x = max.x end
    win:setFrame(f, 0)
	if win:isStandard() then hs.grid.snap(win) end
end)

hs.hotkey.bind(RESIZE, "up", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local EPS = 5

    local jump = max.h / 4

    if (f.y < max.y + EPS) -- at edge, shrink
    then
        f.h = f.h - jump
    else -- not at edge, grow
        f.y = f.y - jump
        f.h = f.h + jump
    end
    if f.y < max.y then f.y = max.y end
    win:setFrame(f, 0)
	if win:isStandard() then hs.grid.snap(win) end
end)

hs.hotkey.bind(RESIZE, "down", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local EPS = 5

    local jump = (max.h - max.y) / 4

    if (f.y + f.h > max.y + max.h - EPS) -- at edge, shrink
    then
        f.y = f.y + jump
        f.h = f.h - jump
    else -- not at edge, grow
        f.h = f.h + jump
    end
    if f.y + f.h > max.h then f.h = max.y + max.h - f.y end
    win:setFrame(f, 0)
	if win:isStandard() then hs.grid.snap(win) end
end)

hs.hotkey.bind(FOCUSW, "left", function()
	local win = hs.window.focusedWindow()
    win:focusWindowWest(nil,true,false)	
end)
hs.hotkey.bind(FOCUSW, "right", function()
	local win = hs.window.focusedWindow()
	win:focusWindowEast(nil,true,false)	
end)
hs.hotkey.bind(FOCUSW, "up", function()
	local win = hs.window.focusedWindow()
	win:focusWindowNorth(nil,true,false)	
end)
hs.hotkey.bind(FOCUSW, "down", function()
	local win = hs.window.focusedWindow()
	win:focusWindowSouth(nil,true,false)	
end)

local all_switcher=hs.window.switcher.new()
hs.hotkey.bind({"alt","cmd"},"]",all_switcher.nextWindow)
hs.hotkey.bind({"alt","cmd"},"[",all_switcher.previousWindow)

--======================================================
