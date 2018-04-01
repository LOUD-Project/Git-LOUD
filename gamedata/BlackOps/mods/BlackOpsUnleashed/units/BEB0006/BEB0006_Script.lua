local TShieldStructureUnit = import('/lua/terranunits.lua').TShieldStructureUnit

BEB0006 = Class(TShieldStructureUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,
    OnCreate = function(self, builder, layer)
        TShieldStructureUnit.OnCreate(self, builder, layer)
    end,
    --Make this unit invulnerable
    OnDamage = function()
    end,
    OnKilled = function(self, instigator, type, overkillRatio)
        TShieldStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    DeathThread = function(self)
        self:Destroy()
    end,  
}

TypeClass = BEB0006

