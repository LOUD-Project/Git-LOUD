
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

function SetLayout()
   -- local controls = import('/lua/ui/game/missiontext.lua').controls
    local controls = import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').controls
    
    if controls.movieBrackets then
       if import('/lua/ui/game/gamemain.lua').IsNISMode() then
            LayoutHelpers.AtLeftTopIn(controls.movieBrackets, GetFrame(0), 20, 100)
			LayoutHelpers.AtLeftTopIn(controls.subtitles.text[1], GetFrame(0), 52, 340)
        else
            LayoutHelpers.AtLeftTopIn(controls.movieBrackets, GetFrame(0), 2, 147)
			LayoutHelpers.AtLeftTopIn(controls.subtitles.text[1], GetFrame(0), 30, 395)
        end
    end
end