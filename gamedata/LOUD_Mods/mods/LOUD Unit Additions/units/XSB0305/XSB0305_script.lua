local SQuantumGateUnit = import('/lua/seraphimunits.lua').SQuantumGateUnit

local SSeraphimSubCommanderGateway01 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway01
local SSeraphimSubCommanderGateway02 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway02
local SSeraphimSubCommanderGateway03 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway03

XSB0305 = Class(SQuantumGateUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        ###Place emitters at the center of the gateway.
        for k, v in SSeraphimSubCommanderGateway01 do
            CreateAttachedEmitter(self, 'XSB0304', self:GetArmy(), v)
        end
        
        ###Place emitters on certain light bones on the mesh.
        for k, v in SSeraphimSubCommanderGateway02 do
            CreateAttachedEmitter(self, 'Light01', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Light02', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Light03', self:GetArmy(), v)
        end
        
        ###Place emitters on certain OTHER light bones on the mesh.
        for k, v in SSeraphimSubCommanderGateway03 do
            CreateAttachedEmitter(self, 'Light04', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Light05', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Light06', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Light07', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Light08', self:GetArmy(), v)
            CreateAttachedEmitter(self, 'Light09', self:GetArmy(), v)
        end
        

        SQuantumGateUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = XSB0305
