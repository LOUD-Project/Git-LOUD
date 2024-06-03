local TSubUnit =  import('/lua/defaultunits.lua').SubUnit

local WeaponFile = import('/lua/terranweapons.lua')

local TANTorpedoAngler          = WeaponFile.TANTorpedoAngler
local TAAFlakArtilleryCannon    = WeaponFile.TAAFlakArtilleryCannon

WeaponFile = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

WeaponFile = nil

SES0204 = Class(TSubUnit) {

    Weapons = {

        Torpedo = Class(TANTorpedoAngler) {},
        AAGun = Class(TAAFlakArtilleryCannon) {},

    },
    
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TSubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

	end,	
        
}

TypeClass = SES0204
