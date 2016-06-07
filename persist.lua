function persist_ttn(ttn, fname)
    fh, err = io.open(fname,"w")
    for i,tag in ipairs(ttn:tags()) do
        for i,win in ipairs(ttn:windows_for_tag(tag):windows()) do
            fh:write(table.concat({tag,win:id()},"\t"))
            fh:write("\n")
        end
    end
    fh:close()
end

function load_ttn(fname) 
    local id_to_w = {}
    for i, w in ipairs(hs.window.allWindows()) do
        if w ~= nil and w:id() ~= nil then 
            id_to_w[w:id()] = w
        end
    end
    local fh,err = io.open(fname,"r")
    for line in fh:lines() do
        local tag,wid = line:gmatch("([^\t]+)\t([^\t]+)")()
        if wid ~= nil then 
            hs.alert.show("attempting "..wid)
            wid = tonumber(wid)
            local win = id_to_w[wid]
            if win ~= nil then 
                ttn:add_tag_to_window(id_to_w[wid], tag)
                --hs.alert.show(tag..id_to_w[wid]:title())
            else
                hs.alert.show("no window for "..wid)
            end
        end
    end
    hs.alert.show("loaded")
end

