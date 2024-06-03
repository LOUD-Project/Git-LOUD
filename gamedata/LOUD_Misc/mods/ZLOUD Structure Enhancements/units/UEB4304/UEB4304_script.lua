local TRadarJammerUnit = import('/lua/terranunits.lua').TRadarJammerUnit

UEB4304 = Class(TRadarJammerUnit) {

    IntelEffects = { { Bones = {'UEB4203'}, Offset = {0,0,3}, Type = 'Jammer01'} },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TRadarJammerUnit.OnStopBeingBuilt(self,builder,layer)

    end,
	
}

TypeClass = UEB4304
