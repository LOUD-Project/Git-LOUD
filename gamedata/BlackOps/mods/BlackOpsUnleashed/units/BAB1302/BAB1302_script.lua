local AEnergyCreationUnit = import('/lua/defaultunits.lua').StructureUnit

local TrashAdd = TrashBag.Add

BAB1302 = Class(AEnergyCreationUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        AEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)
		
        local effects = {'/effects/emitters/hydrocarbon_smoke_01_emit.bp'}
        local bones = {'Extension02','Extension06','Extension18','Extension14','Extension10'}
        local scale = 0.75
		
        if self.CacheLayer == 'Seabed' then
            effects = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp'}
            scale = 3
        end
		
        for _, values in effects do
        
            for _, valuesbones in bones do
            
                TrashAdd( self.Trash, CreateAttachedEmitter( self, valuesbones, self.Army, values ):ScaleEmitter(scale):OffsetEmitter(0,-0.2,1))
            end
        end
    end,
}

TypeClass = BAB1302