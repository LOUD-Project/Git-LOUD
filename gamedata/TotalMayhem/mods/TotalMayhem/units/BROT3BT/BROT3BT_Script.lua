local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFGaussCannonWeapon          = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon
local AAASonicPulseBatteryWeapon    = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local CreateAttachedEmitter = CreateAttachedEmitter

BROT3BT = Class(TLandUnit) {

    Weapons = {

        MainGun = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.5,

            FxMuzzleFlash = { 
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_03_emit.bp',
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_06_emit.bp',
            },

			FxGroundEffect  = EffectTemplate.ConcussionRingLrg01,
	        FxMuzzleEffect  = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
	        FxVentEffect    = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2   = EffectTemplate.WeaponSteam01,
	        FxVentEffect3   = EffectTemplate.CDisruptorGroundEffect,
			
	        PlayFxMuzzleSequence = function(self, muzzle)

                local unit = self.unit
		        local army = unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    CreateAttachedEmitter(unit, 'BROT3BT', army, v):ScaleEmitter(0.3)
                end
                
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(unit, muzzle, army, v):ScaleEmitter(0.5)
                end
                
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(unit, 'vent01', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(unit, 'vent02', army, v):ScaleEmitter(0.35)
                    CreateAttachedEmitter(unit, 'vent03', army, v):ScaleEmitter(0.35)
                end
                
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(unit, muzzle, army, v):ScaleEmitter(0.5)
                end
                
	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(unit, 'BROT3BT', army, v):ScaleEmitter(0.3)
                end
            end,    
		},
		
        mgweapon2 = Class(AAASonicPulseBatteryWeapon) { FxMuzzleFlashScale = 0.6,

			FxMuzzleFlash = {'/effects/emitters/sonic_pulse_muzzle_flash_02_emit.bp',},
        },
		
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.4 },

    },
}

TypeClass = BROT3BT