local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local AWeapons = import('/lua/aeonweapons.lua')
local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

local AAASonicPulseBatteryWeapon = AWeapons.AAASonicPulseBatteryWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BROT3BT = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
			
	        FxMuzzleEffect = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,

            FxMuzzleFlash = { 
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_03_emit.bp',
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_06_emit.bp',
            },

            FxMuzzleFlashScale = 1.5,			

			FxGroundEffect = EffectTemplate.ConcussionRingLrg01,
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    CreateAttachedEmitter(self.unit, 'BROT3BT', army, v):ScaleEmitter(0.3)
                end
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, muzzle, army, v):ScaleEmitter(0.7)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent03', army, v):ScaleEmitter(0.4)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, muzzle, army, v):ScaleEmitter(0.5)
                end
	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BROT3BT', army, v):ScaleEmitter(0.3)
                end
            end,    
		},
		
        mgweapon2 = Class(AAASonicPulseBatteryWeapon) {
			FxMuzzleFlashScale = 0.7,
			FxMuzzleFlash = {'/effects/emitters/sonic_pulse_muzzle_flash_02_emit.bp',},
        },
		
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.45 },

    },
}

TypeClass = BROT3BT