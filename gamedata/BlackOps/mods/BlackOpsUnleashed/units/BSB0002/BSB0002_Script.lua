
local SLandFactoryUnit = import('/lua/seraphimunits.lua').SLandFactoryUnit


BSB0002 = Class(SLandFactoryUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,

    --Make this unit invulnerable
    OnDamage = function()
    end,
}


TypeClass = BSB0002

