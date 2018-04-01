do

local origOnSync = OnSync

function OnSync()
	origOnSync()
	
	if Sync.PlayMFDMovieMP then
        --import('/lua/ui/game/missiontext.lua').PlayMFDMovieMP(Sync.PlayMFDMovieMP.Params, Sync.VideoText)
		import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').PlayMFDMovieMP(Sync.PlayMFDMovieMP.Params, Sync.VideoText)

		if Sync.PlayMFDMovieMP.Lengh and Sync.PlayMFDMovieMP.Lengh > 0 then
			--import('/lua/ui/game/missiontext.lua').CloseMFDMovie(Sync.PlayMFDMovieMP.Params, Sync.PlayMFDMovieMP.Lengh)
			import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').CloseMFDMovie(Sync.PlayMFDMovieMP.Params, Sync.PlayMFDMovieMP.Lengh)
		end
	end
end


end
