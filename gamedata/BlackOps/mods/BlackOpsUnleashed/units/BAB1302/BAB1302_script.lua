local AEnergyCreationUnit = import('/lua/aeonunits.lua').AEnergyCreationUnit

BAB1302 = Class(AEnergyCreationUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        AEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)
		
        local effects = {'/effects/emitters/hydrocarbon_smoke_01_emit.bp'}
        local bones = {'Extension02','Extension06','Extension18','Extension14','Extension10'}
        local scale = 0.75
		
        if self:GetCurrentLayer() == 'Seabed' then
            effects = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp'}
            scale = 3
        end
		
        for keys, values in effects do
            for keysbones, valuesbones in bones do
                self.Trash:Add(CreateAttachedEmitter(self, valuesbones, self:GetArmy(), values):ScaleEmitter(scale):OffsetEmitter(0,-0.2,1))
            end
        end
    end,
}

TypeClass = BAB1302