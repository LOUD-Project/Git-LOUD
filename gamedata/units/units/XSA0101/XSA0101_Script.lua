local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit

local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

XSA0101 = Class(SAirUnit) {

	OnKilled = function(self, instigator, type, overkillRatio)
	
        SAirUnit.OnKilled(self, instigator, type, overkillRatio)
		
        local pos = self:GetPosition()
		
        local spec = {
            X = pos[1],
            Z = pos[3],
            Radius = self:GetBlueprint().Intel.VisionRadiusOnDeath,
            LifeTime = self:GetBlueprint().Intel.IntelDurationOnDeath,
            Army = self:GetArmy(),
            Omni = false,
            WaterVision = false,
        }
		
        local vizEntity = VizMarker(spec)
		
  	end,
}

TypeClass = XSA0101