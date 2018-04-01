
local trashBtn = nil
local dragging = false

function OnCommandGraphShow(show)
    --Table of all map views to display pings in
    local views = import('/lua/ui/game/worldview.lua').GetWorldViews()
    for i, v in views do
        if v and not v.DisableMarkers then
            v:ShowPings(show)
        end
    end

end

function OnCommandDragBegin()

end

function OnCommandDragEnd(event,cmdId)

end
