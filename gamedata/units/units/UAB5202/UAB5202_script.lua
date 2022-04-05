local AirStagingPlatformUnit = import('/lua/defaultunits.lua').AirStagingPlatformUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/defaultbufffield.lua').DefaultBuffField

UAB5202 = Class(AirStagingPlatformUnit) {

	BuffFields = {
	
		RegenField = Class(BuffField){
		
			OnCreate = function(self)
				BuffField.OnCreate(self)
			end,
		},
	},
	

    OnStopBeingBuilt = function(self)
 
        AirStagingPlatformUnit.OnStopBeingBuilt(self)
		
		self:GetBuffFieldByName('AirStagingBuffField'):Enable()		

    end,
	
}

TypeClass = UAB5202