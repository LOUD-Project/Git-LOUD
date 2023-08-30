local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TIFCruiseMissileUnpackingLauncher = WeaponsFile.TIFCruiseMissileUnpackingLauncher
local TANTorpedoLandWeapon = WeaponsFile.TANTorpedoLandWeapon
local TIFCommanderDeathWeapon = WeaponsFile.TIFCommanderDeathWeapon
local TDFRiotWeapon = WeaponsFile.TDFRiotWeapon
local TSAMLauncher = WeaponsFile.TSAMLauncher 

local EffectTemplate = import('/lua/EffectTemplates.lua')
local CreateAttachedEmitter = CreateAttachedEmitter

BRNT3SHBM = Class(TWalkingLandUnit) {

    Weapons = {

        TacMissiles = Class(TIFCruiseMissileUnpackingLauncher) {

            FxMuzzleFlashScale = 0.5,

            FxMuzzleFlash = {
                '/effects/emitters/terran_mobile_missile_launch_01_emit.bp'
            }
        },
		
        handweapon = Class(TDFGaussCannonWeapon) {
		
            FxMuzzleFlashScale = 1,
			
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
                    CreateAttachedEmitter(self.unit, muzzle, army, v):ScaleEmitter(1)
                end
				
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, muzzle, army, v):ScaleEmitter(0.6)
                end
            end, 
		},
		
        Rockets = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.5 },
		
        SAM = Class(TSAMLauncher) { FxMuzzleFlash = EffectTemplate.TAAMissileLaunchNoBackSmoke },	
		
        Torpedoes = Class(TANTorpedoLandWeapon) {},		

        Riotgun = Class(TDFRiotWeapon) {
		
            FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
            FxMuzzleFlashScale = 0.2, 
			
        },
		
        robottalk = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0 },
		
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)

        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
 
		self:SetWeaponEnabledByLabel('robottalk', true)

	end,
}

TypeClass = BRNT3SHBM