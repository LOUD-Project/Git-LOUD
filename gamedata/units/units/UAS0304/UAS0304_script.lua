local ASubUnit =  import('/lua/defaultunits.lua').SubUnit

local WeaponFile = import('/lua/aeonweapons.lua')

local AIFMissileTacticalSerpentineWeapon = WeaponFile.AIFMissileTacticalSerpentineWeapon
local AIFQuantumWarhead = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

WeaponFile = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

UAS0304 = Class(ASubUnit) {
	
    Weapons = {
	
        CruiseMissiles = Class(AIFMissileTacticalSerpentineWeapon) {},
        SubNukeMissiles = Class(AIFQuantumWarhead) {},
		
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

TypeClass = UAS0304

