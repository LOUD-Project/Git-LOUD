local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local oldSetLayout = SetLayout
function SetLayout()

	oldSetLayout()

    if UIP.Enabled() and UIP.GetSetting("rearrangeBottomPanes") then 

        -- if its a replay there is no orders panel and we need to place it differently
        local controls = import('/lua/ui/game/construction.lua').controls
        local ordersControl = import('/lua/ui/game/construction.lua').ordersControl
        local controlClusterGroup = import('/lua/ui/game/construction.lua').controlClusterGroup
        if not ordersControl then
            controls.constructionGroup.Left:Set(LayoutHelpers.ScaleNumber(330))
        end

    end

end