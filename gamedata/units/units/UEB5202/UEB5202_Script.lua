local TAirStagingPlatformUnit = import('defaultunits.lua').AirStagingPlatformUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/defaultbufffield.lua').DefaultBuffField

UEB5202 = Class(TAirStagingPlatformUnit) {

	BuffFields = {
	
		RegenField = Class(BuffField){
		
			OnCreate = function(self)
				BuffField.OnCreate(self)
			end,
		},
	},

    OnStopBeingBuilt = function(self)
 
        TAirStagingPlatformUnit.OnStopBeingBuilt(self)
		
		self:GetBuffFieldByName('AirStagingBuffField'):Enable()		

    end,

}

TypeClass = UEB5202