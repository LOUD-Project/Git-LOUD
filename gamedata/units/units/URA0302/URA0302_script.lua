local CAirUnit = import('/lua/defaultunits.lua').AirUnit

URA0302 = Class(CAirUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
		
    end,
}
TypeClass = URA0302