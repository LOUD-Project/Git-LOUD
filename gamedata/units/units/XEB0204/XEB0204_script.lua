local TPodTowerUnit = import('/lua/defaultunits.lua').StructureUnit

local CreateDefaultBuildBeams = import('/lua/EffectUtilities.lua').CreateDefaultBuildBeams
local CreateUEFBuildSliceBeams = import('/lua/EffectUtilities.lua').CreateUEFBuildSliceBeams

XEB0204 = Class(TPodTowerUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
	
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
		
        -- If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
		
            CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
			
        else
		
            CreateUEFBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        
			
        end           
    end,
	
}

TypeClass = XEB0204