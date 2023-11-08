local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Weapon = import('/lua/sim/Weapon.lua').Weapon
local AWeapons = import('/lua/aeonweapons.lua')
local cWeapons = import('/lua/cybranweapons.lua')

local CDFLaserDisintegratorWeapon = cWeapons.CDFLaserDisintegratorWeapon01
local CDFElectronBolterWeapon = cWeapons.CDFElectronBolterWeapon

local EMPDeathWeapon = AWeapons.ADFChronoDampener

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect

URL0303 = Class(CWalkingLandUnit) {

    PlayEndAnimDestructionEffects = false,

    Weapons = {

        Disintigrator = Class(CDFLaserDisintegratorWeapon) {},
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

    OnKilled = function(self, instigator, type, overkillRatio)

		if self.UnitComplete then
            CreateLightParticle( self, -1, -1, 11, 32, 'flare_lens_add_02', 'ramp_red_10' )
        end
		
        CWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = URL0303