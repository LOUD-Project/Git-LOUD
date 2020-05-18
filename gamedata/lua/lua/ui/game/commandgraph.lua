
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

-- this is triggered whenever you start to drag a movement order around
-- not sure about others yet
function OnCommandDragBegin()
    --LOG("*AI DEBUG OnCommandDragBegin")
end

function OnCommandDragEnd(event,cmdId)

end
