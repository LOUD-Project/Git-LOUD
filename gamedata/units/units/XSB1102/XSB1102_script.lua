local SEnergyCreationUnit = import('/lua/seraphimunits.lua').SEnergyCreationUnit

XSB1102 = Class(SEnergyCreationUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        SEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)

        local effects   = {'/effects/emitters/hydrocarbon_heatshimmer_01_emit.bp'}
        local bones     = {'Exhaust01','Exhaust02','Exhaust03'}
        local scale     = 0.75
        
        if  self:GetCurrentLayer() == 'Seabed' then
        
            effects     = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp'}
            bones       = {'Exhaust01'}
            scale       = 3
        end

        for keys, values in effects do
            for keysbones, valuesbones in bones do
                self.Trash:Add(CreateAttachedEmitter(self, valuesbones, self:GetArmy(), values):ScaleEmitter(scale):OffsetEmitter(0,-0.2,1))
            end
        end

        local bp = self:GetBlueprint().Display

        self.LoopAnimation = CreateAnimator(self)
        self.LoopAnimation:PlayAnim(bp.LoopingAnimation, true)
        self.LoopAnimation:SetRate(0.5)
        self.Trash:Add(self.LoopAnimation)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        SEnergyCreationUnit.OnKilled(self, instigator, type, overkillRatio)
        if self.LoopAnimation then
            self.LoopAnimation:SetRate(0.0)
        end
    end,
}

TypeClass = XSB1102