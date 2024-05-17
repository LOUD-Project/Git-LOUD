local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashAdd = TrashBag.Add

BRNT3ABB = Class(TWalkingLandUnit) {

    Weapons = {

        topguns = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.25 },

        guns    = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.45 },
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

TypeClass = BRNT3ABB