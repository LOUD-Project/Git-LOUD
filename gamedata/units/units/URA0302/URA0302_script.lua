local CAirUnit = import('/lua/cybranunits.lua').CAirUnit

URA0302 = Class(CAirUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
		
    end,
}
TypeClass = URA0302