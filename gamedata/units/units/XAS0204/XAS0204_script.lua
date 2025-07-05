local ASubUnit =  import('/lua/defaultunits.lua').SubUnit

local Torpedo = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XAS0204 = Class(ASubUnit) {

    Weapons = {
	
        Torpedo = Class(Torpedo) {},

    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		ASubUnit.OnStopBeingBuilt(self,builder,layer)

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

TypeClass = XAS0204