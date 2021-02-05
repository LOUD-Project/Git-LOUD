
local AEnergyCreationUnit = import('/lua/aeonunits.lua').AEnergyCreationUnit

UAB1306 = Class(AEnergyCreationUnit) {
    AmbientEffects = 'AT3PowerAmbient',

    -- OnStopBeingBuilt = function(self, builder, layer)
        -- AEnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
        -- self.Trash:Add(CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)))
        -- self.Trash:Add(CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)))
        -- self.Trash:Add(CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)))
    -- end,

}

TypeClass = UAB1306