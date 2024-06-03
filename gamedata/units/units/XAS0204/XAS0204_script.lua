local ASubUnit =  import('/lua/defaultunits.lua').SubUnit

local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XAS0204 = Class(ASubUnit) {

    Weapons = {
	
        Torpedo = Class(AANChronoTorpedoWeapon) {},

    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		ASubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

	end,	
    
}

TypeClass = XAS0204