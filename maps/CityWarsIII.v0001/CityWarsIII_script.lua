local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua') 
local Utilities = import('/lua/Utilities.lua') 


function OnPopulate()
ScenarioUtils.InitializeArmies()
end

function OnStart(self)
--This prevents the engine from crashing with Fatal error in DrawContext.cpp, invalid number of vertices in triangle list		
Utilities.UserConRequest("cam_LowLOD 1.1")
Utilities.UserConRequest("SC_CameraScaleLOD 0")
--Unused for now: ForkThread(AdjustCamLODThread)
end

--Overrides any LOD changes (reload game, ingame video options change,..)
--function AdjustCamLODThread()
--	while true do 
--		--This prevents the engine from crashing with Fatal error in DrawContext.cpp, invalid number of vertices in triangle list		
--		--Utilities.UserConRequest("cam_HighLOD 1.1")
--		--Utilities.UserConRequest("cam_MediumLOD 1.1")
--		Utilities.UserConRequest("cam_LowLOD 1.1")
--		--Utilities.UserConRequest("cam_DefaultLOD 1.1")
--		Utilities.UserConRequest("SC_CameraScaleLOD 0")	
--		WaitSeconds(2) 
--	end 
--end
