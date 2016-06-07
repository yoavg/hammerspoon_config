
---- For debug purposes
focused_window = nil
hs.hotkey.bind({"cmd","alt","ctrl"},"x", function()
    local win = hs.window.focusedWindow()
    focused_window = win
    hs.alert.show("winid:".. focused_window:id())
end)
---- end debug part
