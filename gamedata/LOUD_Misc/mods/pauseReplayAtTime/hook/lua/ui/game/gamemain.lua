local PRAT_modpath = '/mods/pauseReplayAtTime/'
local PRAT = import(PRAT_modpath..'modules/PRAT.lua')

local originalCreateUI = CreateUI 
function CreateUI(isReplay)
	originalCreateUI(isReplay) 
	if isReplay then
		PRAT.init()
	end
end

local originalSetLayout = SetLayout
function SetLayout(layout)
	originalSetLayout(layout)
	PRAT.SetLayout()
end