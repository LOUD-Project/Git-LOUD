do

local prevResetSyncTable = ResetSyncTable
function ResetSyncTable()
    prevResetSyncTable()
    Sync.PlayMFDMovieMP = false
	Sync.SetupMFDMovieMP = {}
end

function DoMFD(speaker, video, callback, critical)
	local army = false
	
	if speaker and not speaker:IsDead() then 
		army = speaker:GetArmy()
	end
		
	if not army or army == GetFocusArmy() then
		local video_setup = import('/mods/Domino_Mod_Support/lua/mfd_video/setup_video.lua')
		video_setup.DialogueMP(speaker:GetEntityId(), video, callback, critical)
	end
end

end
