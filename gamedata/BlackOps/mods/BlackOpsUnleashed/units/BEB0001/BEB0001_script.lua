local TAirStagingPlatformUnit = import('/lua/defaultunits.lua').AirStagingPlatformUnit

BEB0001 = Class(TAirStagingPlatformUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,
	OnDamage = function()
    end,
}
TypeClass = BEB0001