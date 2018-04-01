local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

BAB0003 = Class(SStructureUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,

	OnCreate = function(self, builder, layer)
        SStructureUnit.OnCreate(self, builder, layer)
    end,
    --Make this unit invulnerable
    OnDamage = function()
    end,
    OnKilled = function(self, instigator, type, overkillRatio)
        SStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,  
    DeathThread = function(self)
        self:Destroy()
    end,
}


TypeClass = BAB0003

