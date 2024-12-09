local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local oldSplitMapGroup = SplitMapGroup
function SplitMapGroup(splitState, forceSplit)
	oldSplitMapGroup(splitState, forceSplit)

	if not UIP.Enabled() then 
		return
	end

	-- move avatars
	if UIP.GetSetting("moveAvatarsToLeftSplitScreen")then 

		local avatars = import('/lua/ui/game/avatars.lua')
		if splitState then
			LayoutHelpers.AtRightTopIn(avatars.controls.avatarGroup, avatars.controls.parent, controls.mapGroupLeft.Width() + 30, 0)
			LayoutHelpers.AtRightTopIn(avatars.controls.collapseArrow, avatars.controls.parent, controls.mapGroupLeft.Width() + 30, 22)
		else
			LayoutHelpers.AtRightTopIn(avatars.controls.avatarGroup, avatars.controls.parent, 0, 200)
			LayoutHelpers.AtRightTopIn(avatars.controls.collapseArrow, avatars.controls.parent, 0, 222)
		end

	end

	-- move bottom panes
	if UIP.GetSetting("smallerContructionTabWhenSplitScreen")then 

		MoveBuilders(splitState)

	end

end

function MoveBuilders(halfMode)

	local controlClusterGroup = import('/lua/ui/game/construction.lua').controlClusterGroup
	local controls = import('/lua/ui/game/construction.lua').controls
	controls.constructionGroup.Right:Set(function() 
		local w = GetFrame(0).Width()
		if halfMode then 
			w = w / 2
		end 
		return w - LayoutHelpers.ScaleNumber(20)
	end)

end