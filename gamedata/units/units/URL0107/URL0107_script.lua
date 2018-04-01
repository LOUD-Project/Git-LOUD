
local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

local SpawnBuildBots = import('/lua/EffectUtilities.lua').SpawnBuildBots
local CreateCybranBuildBeams = import('/lua/EffectUtilities.lua').CreateCybranBuildBeams


URL0107 = Class(CWalkingLandUnit) {
    Weapons = {
        LaserArms = Class(CDFLaserHeavyWeapon) {},
    },
    OnCreate = function(self)
        CWalkingLandUnit.OnCreate(self)
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
    end,
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       SpawnBuildBots( self, unitBeingBuilt, 1, self.BuildEffectsBag )
       CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,
    
}

TypeClass = URL0107
