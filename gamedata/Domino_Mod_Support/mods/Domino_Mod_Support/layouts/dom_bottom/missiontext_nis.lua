
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

function SetLayout()
   -- local controls = import('/lua/ui/game/missiontext.lua').controls
   local controls = import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').controls
    
    if controls.movieBrackets then
        LayoutHelpers.AtLeftTopIn(controls.movieBrackets, GetFrame(0), 20, 100)
        LayoutHelpers.AtLeftTopIn(controls.subtitles.text[1], GetFrame(0), 52, 340)
    end
end