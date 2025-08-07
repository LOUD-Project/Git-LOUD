local SQuantumGateUnit = import('/lua/seraphimunits.lua').SQuantumGateUnit

local SSeraphimSubCommanderGateway01 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway01

XSB0305 = Class(SQuantumGateUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        for k, v in SSeraphimSubCommanderGateway01 do
            CreateAttachedEmitter(self, 'XSB0304', self:GetArmy(), v):ScaleEmitter(0.25)
        end

        SQuantumGateUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = XSB0305
