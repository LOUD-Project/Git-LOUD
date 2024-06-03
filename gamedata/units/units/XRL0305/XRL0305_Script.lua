local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CDFHeavyDisintegratorWeapon   = import('/lua/cybranweapons.lua').CDFHeavyDisintegratorWeapon
local CANNaniteTorpedoWeapon        = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashAdd = TrashBag.Add

XRL0305 = Class(CWalkingLandUnit){

    Weapons = {
        Disintegrator   = Class(CDFHeavyDisintegratorWeapon) {},
        Torpedo         = Class(CANNaniteTorpedoWeapon) {},
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

TypeClass = XRL0305