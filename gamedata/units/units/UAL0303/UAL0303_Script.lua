
local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit
local ADFLaserHighIntensityWeapon = import('/lua/aeonweapons.lua').ADFLaserHighIntensityWeapon
local CreateAeonCommanderBuildingEffects = import('/lua/EffectUtilities.lua').CreateAeonCommanderBuildingEffects

UAL0303 = Class(AWalkingLandUnit) {    
    Weapons = {
        FrontTurret01 = Class(ADFLaserHighIntensityWeapon) {}
    },
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  

    OnShieldIsUp = function (self)
        self:SetCanTakeDamage(false)
    end,

    OnShieldIsDown = function (self)
        self:SetCanTakeDamage(true) 
    end,
}

TypeClass = UAL0303