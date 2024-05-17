local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashAdd = TrashBag.Add

BROT3HM = Class(CWalkingLandUnit) {

    Weapons = {

        MainGun = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.2,
            FxMuzzleFlash = EffectTemplate.AOblivionCannonMuzzleFlash02,
		}, 

        MainGun2 = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.5,
            FxMuzzleFlash = EffectTemplate.AIFBallisticMortarFlash02,
		}, 
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

	end,	
    
}

TypeClass = BROT3HM