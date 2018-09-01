local CAirStagingPlatformUnit = import('/lua/cybranunits.lua').CAirStagingPlatformUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/defaultbufffield.lua').DefaultBuffField

URB5202 = Class(CAirStagingPlatformUnit) {

	BuffFields = {
	
		RegenField = Class(BuffField){
		
			OnCreate = function(self)
				BuffField.OnCreate(self)
			end,
		},
	},

    OnStopBeingBuilt = function(self)
 
        CAirStagingPlatformUnit.OnStopBeingBuilt(self)
		
		self:GetBuffFieldByName('AirStagingBuffField'):Enable()		

    end,

}

TypeClass = URB5202