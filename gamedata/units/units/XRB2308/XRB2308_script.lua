local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CKrilTorpedoLauncherWeapon = import('/lua/cybranweapons.lua').CKrilTorpedoLauncherWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XRB2308 = Class(CStructureUnit) {

    Weapons = {
        Turret01 = Class(CKrilTorpedoLauncherWeapon) { FxMuzzleFlashScale = 0.5 },
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		CStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

	end,	        
}

TypeClass = XRB2308