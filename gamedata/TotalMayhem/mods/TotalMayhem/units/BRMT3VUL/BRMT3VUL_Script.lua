local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/cybranweapons.lua')
local WeaponsFile2 = import('/lua/terranweapons.lua')

local CDFElectronBolterWeapon = WeaponsFile.CDFElectronBolterWeapon
local CCannonMolecularWeapon = WeaponsFile.CCannonMolecularWeapon

local TDFGaussCannonWeapon = WeaponsFile2.TDFLandGaussCannonWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect

BRMT3VUL = Class(CWalkingLandUnit) {

    Weapons = {

        rockets = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.4 },
		
        robottalk = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0},

        armweapon = Class(CCannonMolecularWeapon) { FxMuzzleFlashScale = 0.8 },

        HeavyBolter = Class(CDFElectronBolterWeapon) {},

    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        local bp = self:GetBlueprint().Defense.AntiMissile
		
        local antiMissile = MissileRedirect {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
		
        self.Trash:Add(antiMissile)
        self.UnitComplete = true
    end,
    
}

TypeClass = BRMT3VUL