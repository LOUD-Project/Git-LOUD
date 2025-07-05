local TSubUnit =  import('/lua/defaultunits.lua').SubUnit

local WeaponFile = import('/lua/terranweapons.lua')

local Torpedo       = WeaponFile.TANTorpedoAngler
local FlakCannon    = WeaponFile.TAAFlakArtilleryCannon

WeaponFile = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

WeaponFile = nil

SES0204 = Class(TSubUnit) {

    Weapons = {
        Torpedo = Class(Torpedo) {},
        AAGun = Class(FlakCannon) {},
    },
    
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TSubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
        
        self.DeathWeaponEnabled = true

        -- setup callbacks to engage sonar stealth when not moving
        local StartMoving = function(unit)
            unit:DisableIntel('SonarStealth')
        end
        
        local StopMoving = function(unit)
            unit:EnableIntel('SonarStealth')
        end
        
        self:AddOnHorizontalStartMoveCallback( StartMoving )
        self:AddOnHorizontalStopMoveCallback( StopMoving )

	end,	

}

TypeClass = SES0204
