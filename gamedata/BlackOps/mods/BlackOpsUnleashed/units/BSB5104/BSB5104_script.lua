local SAirStagingPlatformUnit = import('/lua/seraphimunits.lua').SAirStagingPlatformUnit
local SeraphimAirStagePlat02 = import('/lua/EffectTemplates.lua').SeraphimAirStagePlat02
local SeraphimAirStagePlat01 = import('/lua/EffectTemplates.lua').SeraphimAirStagePlat01

local CreateAttachedEmitter = CreateAttachedEmitter

BSB5104 = Class(SAirStagingPlatformUnit) {
    OnStopBeingBuilt = function(self,builder,layer)
    
        local army = self:GetArmy()
        
        for k, v in SeraphimAirStagePlat02 do
            CreateAttachedEmitter(self, 'XSB5104', army, v)
        end
        
        for k, v in SeraphimAirStagePlat01 do
            CreateAttachedEmitter(self, 'Pod01', army, v)
            CreateAttachedEmitter(self, 'Pod02', army, v)
        end        

        SAirStagingPlatformUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = BSB5104