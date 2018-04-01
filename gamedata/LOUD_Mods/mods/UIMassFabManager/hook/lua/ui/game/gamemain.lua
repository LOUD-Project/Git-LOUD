do
	local originalCreateUI = CreateUI

	function CreateUI(isReplay)
	    originalCreateUI(isReplay)
		import("/mods/uimassfabmanager/massfabmanager.lua").Init()
	end
end
