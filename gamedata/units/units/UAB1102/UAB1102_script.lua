
local AEnergyCreationUnit = import('/lua/aeonunits.lua').AEnergyCreationUnit

UAB1102 = Class(AEnergyCreationUnit) {

    AirEffects = {'/effects/emitters/hydrocarbon_smoke_01_emit.bp',},
    AirEffectsBones = {'Extension02'},
    WaterEffects = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp',},
    WaterEffectsBones = {'Extension02'},

    OnStopBeingBuilt = function(self,builder,layer)
        AEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)
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
        
        local army = self:GetArmy()
        local LOUDATTACHEMITTER = CreateAttachedEmitter
        
        for _, values in effects do
            for _, valuesbones in bones do
                self.Trash:Add(LOUDATTACHEMITTER(self, valuesbones, army, values):ScaleEmitter(scale):OffsetEmitter(0,-0.2,1))
            end
        end
    end,
}

TypeClass = UAB1102