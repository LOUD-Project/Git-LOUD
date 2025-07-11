local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local Cannon    = WeaponsFile.TDFLandGaussCannonWeapon
local Torpedo   = WeaponsFile.TANTorpedoAngler

WeaponsFile = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

WEB0404 = Class(TStructureUnit) {

    Weapons = {
    
        TurretLarge = Class(Cannon) { FxMuzzleFlashScale = 0.6 },
        
        Turret      = Class(Cannon) { FxMuzzleFlash = false },

        Torpedo     = Class(Torpedo) { FxMuzzleFlash = false },
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TStructureUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
        
    end,
}

TypeClass = WEB0404