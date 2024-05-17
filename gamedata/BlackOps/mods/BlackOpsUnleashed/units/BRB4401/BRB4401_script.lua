local CRadarJammerUnit = import('/lua/defaultunits.lua').RadarJammerUnit

BRB4401 = Class(CRadarJammerUnit) {

    IntelEffects = {
		{Bones = {'Emitter'}, Offset = {0,3,0}, Type = 'Jammer01'},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
    
        CRadarJammerUnit.OnStopBeingBuilt(self,builder,layer)
        
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
    end,

}

TypeClass = BRB4401