local SAirStagingPlatformUnit = import('/lua/seraphimunits.lua').SAirStagingPlatformUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/defaultbufffield.lua').DefaultBuffField

local SeraphimAirStagePlat02 = import('/lua/EffectTemplates.lua').SeraphimAirStagePlat02
local SeraphimAirStagePlat01 = import('/lua/EffectTemplates.lua').SeraphimAirStagePlat01

XSB5202 = Class(SAirStagingPlatformUnit) {

	BuffFields = {
	
		RegenField = Class(BuffField){
		
			OnCreate = function(self)
				BuffField.OnCreate(self)
			end,
		},
	},
	
    OnStopBeingBuilt = function(self,builder,layer)
	
        for k, v in SeraphimAirStagePlat02 do
            CreateAttachedEmitter(self, 'XSB5202', self:GetArmy(), v)
        end
        
        for k, v in SeraphimAirStagePlat01 do
            CreateAttachedEmitter(self, 'Pod01', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Pod02', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Pod03', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Pod04', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Pod05', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Pod06', self:GetArmy(), v)
        end        

        SAirStagingPlatformUnit.OnStopBeingBuilt(self, builder, layer)
		
		self:GetBuffFieldByName('AirStagingBuffField'):Enable()				
    end,

}

TypeClass = XSB5202