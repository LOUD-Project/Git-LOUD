local SEnergyCreationUnit = import('/lua/seraphimunits.lua').SEnergyCreationUnit

local CreateAttachedEmitter = CreateAttachedEmitter

BSB1302 = Class(SEnergyCreationUnit) {
    
    AirEffects = {'/effects/emitters/hydrocarbon_heatshimmer_01_emit.bp'},
    AirEffectsBones = {'Exhaust01','Exhaust02','Exhaust03','Exhaust04','Exhaust05','Exhaust06'},
    WaterEffects = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp',},
    WaterEffectsBones = {'Exhaust01','Exhaust02','Exhaust03','Exhaust04','Exhaust05','Exhaust06'},

    OnStopBeingBuilt = function(self,builder,layer)

        SEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)

        local effects = {}
        local bones = {}
        local scale = 0.75

        if self:GetCurrentLayer() == 'Land' then
            effects = self.AirEffects
            bones = self.AirEffectsBones
        elseif self:GetCurrentLayer() == 'Seabed' then
            effects = self.WaterEffects
            bones = self.WaterEffectsBones
            scale = 3
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

TypeClass = BSB1302