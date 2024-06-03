local AEnergyCreationUnit = import('/lua/defaultunits.lua').EnergyCreationUnit

UAB1102 = Class(AEnergyCreationUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        AEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)

        local effects = {'/effects/emitters/hydrocarbon_smoke_01_emit.bp'}
        local bones = {'Extension02'}
        local scale = 0.75
        
        if self:GetCurrentLayer() == 'Seabed' then
            effects = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp'}
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