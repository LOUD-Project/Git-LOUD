local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local EffectUtil = import('/lua/EffectUtilities.lua')

WSB0104 = Class(SStructureUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

}

TypeClass = WSB0104

