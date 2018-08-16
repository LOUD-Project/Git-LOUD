local TAirStagingPlatformUnit = import('/lua/terranunits.lua').TAirStagingPlatformUnit

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
}

TypeClass = UEB5202