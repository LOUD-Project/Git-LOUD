local CQuantumGateUnit = import('/lua/defaultunits.lua').QuantumGateUnit

local CreateCybranQuantumGateEffect = import('/lua/EffectUtilities.lua').CreateCybranQuantumGateEffect

URB0304 = Class(CQuantumGateUnit) {

    GateBones = {
        {   
            'Gate01_Left_FX',
            'Gate01_Right_FX',
        },
        {
            'Gate02_Left_FX',
            'Gate02_Right_FX',
        },
        {
            'Gate03_Left_FX',
            'Gate03_Right_FX',
        },
    },
    
    GateEffects = {
        '/effects/emitters/cybran_gate_01_emit.bp',
        '/effects/emitters/cybran_gate_02_emit.bp',
    },

    OnStopBeingBuilt = function(self,builder,layer)
        CQuantumGateUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[1][1], self.GateBones[1][2], self.Trash, 0.1 )
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[2][1], self.GateBones[2][2], self.Trash, 0.5 )
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[3][1], self.GateBones[3][2], self.Trash, 1.1 )
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[1][1], self.GateBones[1][2], self.Trash, 0.6 )
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[2][1], self.GateBones[2][2], self.Trash, 1.2 )
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[3][1], self.GateBones[3][2], self.Trash, 1.8 ) 
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[1][1], self.GateBones[1][2], self.Trash, 2.3 )
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[2][1], self.GateBones[2][2], self.Trash, 2.7 )
        self:ForkThread( CreateCybranQuantumGateEffect, self.GateBones[3][1], self.GateBones[3][2], self.Trash, 3.1 ) 
        
        local army = self:GetArmy()
        for kBonesSet,vBoneSet in self.GateBones do
            for kBone, vBone in vBoneSet do
                for kEffect, vEffect in self.GateEffects do
                    self.Trash:Add(CreateAttachedEmitter( self, vBone, army, vEffect))
                end
            end
        end            
    end,

}

TypeClass = URB0304