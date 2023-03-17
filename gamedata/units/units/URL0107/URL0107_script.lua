local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

local CreateCybranBuildBeams = import('/lua/EffectUtilities.lua').CreateCybranBuildBeams

local ScaleEmitter = moho.IEffect.ScaleEmitter
local TrashDestroy = TrashBag.Destroy

URL0107 = Class(CWalkingLandUnit) {

    Weapons = {
        LaserArms = Class(CDFLaserHeavyWeapon) {},
    },
    
    OnCreate = function(self)
    
        CWalkingLandUnit.OnCreate(self)
        
        if __blueprints[self.BlueprintID].General.BuildBones then
            self:SetupBuildBones()
        end
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       CreateCybranBuildBeams( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,
    
    OnStopBuild = function( self, unitBeingBuilt )

        if self.BuildProjectile then
        
            for _, v in self.BuildProjectile do
            
                TrashDestroy( v.BuildEffectsBag )
                
                ScaleEmitter( v.Emitter, .1)
                ScaleEmitter( v.Sparker, .1)

                if v.Detached then
                    v:AttachTo( self, v.Name )
                end
                
                v.Detached = false
            end
        end
        
        CWalkingLandUnit.OnStopBuild( self, unitBeingBuilt )

    end,
    
}

TypeClass = URL0107
