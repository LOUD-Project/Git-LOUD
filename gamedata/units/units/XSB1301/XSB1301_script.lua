local SEnergyCreationUnit = import('/lua/seraphimunits.lua').SEnergyCreationUnit

XSB1301 = Class(SEnergyCreationUnit) {

    AmbientEffects = 'ST3PowerAmbient',
    
    OnStopBeingBuilt = function(self, builder, layer)
        SEnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
        self.Trash:Add(CreateRotator(self, 'Orb', 'y', nil, 0, 15, 60 + Random(0, 20)))
    end,

}

TypeClass = XSB1301