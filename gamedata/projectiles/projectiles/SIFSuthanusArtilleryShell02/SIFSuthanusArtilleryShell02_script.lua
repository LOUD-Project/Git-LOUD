
local SSuthanusArtilleryShell = import('/lua/seraphimprojectiles.lua').SSuthanusArtilleryShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local CreateDecal = CreateDecal 

SIFSuthanusArtilleryShell02 = Class(SSuthanusArtilleryShell) {
	OnImpact = function(self, TargetType, TargetEntity)
	
		SSuthanusArtilleryShell.OnImpact(self, TargetType, TargetEntity)
		
		if TargetType != 'Shield' and TargetType != 'Water' and TargetType != 'UnitAir' then
			local LOUDPI = math.pi
			local CreateDecal = CreateDecal
			
			local rotation = RandomFloat(0,2*LOUDPI)
	        
			CreateDecal(self:GetPosition(), rotation, 'crater_radial01_normals', '', 'Alpha Normals', 6, 6, 30, 45, self:GetArmy())
			CreateDecal(self:GetPosition(), rotation, 'crater_radial01_albedo', '', 'Albedo', 8, 8, 30, 45, self:GetArmy())
		end
	end,
}

TypeClass = SIFSuthanusArtilleryShell02
