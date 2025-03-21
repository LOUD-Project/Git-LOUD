local TQuantumGateUnit = import('/lua/defaultunits.lua').QuantumGateUnit

UEB0304 = Class(TQuantumGateUnit) {

	GateEffectVerticalOffset = 0.35,
	GateEffectScale = 0.42,

    OnStopBeingBuilt = function(self,builder,layer)
        self.GateEffectEntity = import('/lua/sim/Entity.lua').Entity()
        self.GateEffectEntity:AttachBoneTo(-1, self,'UEB0304')
        self.GateEffectEntity:SetMesh('/effects/entities/ForceField01/ForceField01_mesh')
        self.GateEffectEntity:SetDrawScale(self.GateEffectScale)
        self.GateEffectEntity:SetParentOffset(Vector(0,0,self.GateEffectVerticalOffset))
        self.GateEffectEntity:SetVizToAllies('Intel')
        self.GateEffectEntity:SetVizToNeutrals('Intel')
        self.GateEffectEntity:SetVizToEnemies('Intel')          
        self.Trash:Add(self.GateEffectEntity)
    
        CreateAttachedEmitter(self,'Left_Gate_FX',self:GetArmy(),'/effects/emitters/terran_gate_01_emit.bp')
        CreateAttachedEmitter(self,'Right_Gate_FX',self:GetArmy(),'/effects/emitters/terran_gate_01_emit.bp')
                
        TQuantumGateUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = UEB0304