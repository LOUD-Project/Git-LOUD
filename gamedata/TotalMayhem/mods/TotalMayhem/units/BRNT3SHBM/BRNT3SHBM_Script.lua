
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TIFCruiseMissileUnpackingLauncher = WeaponsFile.TIFCruiseMissileUnpackingLauncher
local TANTorpedoLandWeapon = WeaponsFile.TANTorpedoLandWeapon
local TIFCommanderDeathWeapon = WeaponsFile.TIFCommanderDeathWeapon
local TSAMLauncher = WeaponsFile.TSAMLauncher 

local EffectTemplate = import('/lua/EffectTemplates.lua')
local CreateAttachedEmitter = CreateAttachedEmitter

BRNT3SHBM = Class(TWalkingLandUnit) {

    Weapons = {

        MissileWeapon = Class(TIFCruiseMissileUnpackingLauncher) { FxMuzzleFlash = {'/effects/emitters/terran_mobile_missile_launch_01_emit.bp'} },
		
        MissileTube = Class(TSAMLauncher) { FxMuzzleFlash = EffectTemplate.TAAMissileLaunchNoBackSmoke },	
		
        handweapon = Class(TDFGaussCannonWeapon) {
		
            FxMuzzleFlashScale = 1.1,
			
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,
	        FxMuzzleEffect = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
			
		        local army = self.unit:GetArmy()

  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'gun_muzzle01', army, v):ScaleEmitter(1.2)
                    CreateAttachedEmitter(self.unit, 'gun_muzzle02', army, v):ScaleEmitter(1.2)
                    CreateAttachedEmitter(self.unit, 'gun_muzzle03', army, v):ScaleEmitter(1.2)
                    CreateAttachedEmitter(self.unit, 'gun_muzzle04', army, v):ScaleEmitter(1.2)
                end
				
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'gun_muzzle01', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'gun_muzzle02', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'gun_muzzle03', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'gun_muzzle04', army, v):ScaleEmitter(0.5)
                end
            end, 
		},

        rocketweapon = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.1 },
		
        Torpedoes = Class(TANTorpedoLandWeapon) {},		
		
        robottalk = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0 },
		
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)

        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
 
		self:SetWeaponEnabledByLabel('robottalk', true)

	end,
}

TypeClass = BRNT3SHBM