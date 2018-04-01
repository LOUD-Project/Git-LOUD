local TAirStagingPlatformUnit = import('/lua/terranunits.lua').TAirStagingPlatformUnit

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