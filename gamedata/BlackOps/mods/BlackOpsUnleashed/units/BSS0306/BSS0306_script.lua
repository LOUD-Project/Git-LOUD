local SSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local SWeapon = import('/lua/seraphimweapons.lua')

local SDFUnstablePhasonBeam = import('/lua/kirvesweapons.lua').SDFUnstablePhasonBeam

local EffectTemplate = import('/lua/kirveseffects.lua')

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashAdd = TrashBag.Add


BSS0306 = Class(SSeaUnit) {

    Weapons = {
	
        MainGun         = Class(SWeapon.SDFShriekerCannon){},

        LazorTurret     = Class(SWeapon.SDFUltraChromaticBeamGenerator) {},
		
        BombardTurret   = Class(SWeapon.SIFSuthanusArtilleryCannon) {},
		
        AAGun = Class(SWeapon.SAALosaareAutoCannonWeapon) {},
		
        PhasonBeam = Class(SDFUnstablePhasonBeam) { FxMuzzleFlash = {'/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_01_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_02_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_03_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_04_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_05_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_06_emit.bp','/mods/BlackOpsUnleashed/Effects/Emitters/seraphim_electricity_emit.bp'}, },

    },
    
    AmbientEffects = 'OrbGlowEffect',
    
    OnStopBeingBuilt = function(self,builder,layer)
	
		SSeaUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitters
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
		
		IssueDive({self})
		
		self:HideBone('Orb', true)
		
		self.Trash:Add(CreateRotator(self, 'Orb_Spinner', 'y', nil, 90, 0, 0))
		
        local army =  self.Army
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        if self.AmbientEffects then
            for k, v in EffectTemplate[self.AmbientEffects] do
				CreateAttachedEmitter(self, 'Orb', army, v):ScaleEmitter(2)
            end
        end
		
    end,
	
	OnKilled = function(self, inst, type, okr)
	
        self.Trash:Destroy()
        self.Trash = TrashBag()

        SSeaUnit.OnKilled(self, inst, type, okr)
		
    end,
}
TypeClass = BSS0306
