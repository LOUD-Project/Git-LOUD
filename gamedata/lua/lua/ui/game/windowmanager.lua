
local windows = {}

function AddWindow(windowData)
    windows[windowData.id] = {closeFunc = windowData.closeFunc}
end

function OpenWindow(id)
    for i, val in windows do
        if id then
            if i != id then
                --val.closeFunc()
                val.isOpen = false
            else
                val.isOpen = true
            end
        else
            if val.isOpen then
                val.isOpen = false
                --val.closeFunc()
            end
        end
    end
end

function CloseWindow(id)
    if windows[id] then
        windows[id].isOpen = false
    end
end

function IsWindowOpen()
    for i, v in windows do
        if v.isOpen then
            return true
        end
    end
    return false
end