local AQuantumGateUnit = import('/lua/aeonunits.lua').AQuantumGateUnit
local AQuantumGateAmbient = import('/lua/EffectTemplates.lua').AQuantumGateAmbient

UAB0304 = Class(AQuantumGateUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
    
        local army = self:GetArmy()
		local CreateAttachedEmitter = CreateAttachedEmitter
        
        for _, v in AQuantumGateAmbient do
            CreateAttachedEmitter(self, 'UAB0304', army, v)
        end
        
        AQuantumGateUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = UAB0304

