
local TLandUnit = import('/lua/terranunits.lua').TLandUnit

local AWeapons = import('/lua/aeonweapons.lua')
local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

local AAASonicPulseBatteryWeapon = AWeapons.AAASonicPulseBatteryWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BROT3BT = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 3,
            FxMuzzleFlash = { 
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_03_emit.bp',
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_06_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            },
			
			FxGroundEffect = EffectTemplate.ConcussionRingLrg01,
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,
			
	        FxMuzzleEffect = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    CreateAttachedEmitter(self.unit, 'BROT3BT', army, v):ScaleEmitter(0.8)
                end
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(1.0)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(1.0)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(1.0)
                    CreateAttachedEmitter(self.unit, 'vent03', army, v):ScaleEmitter(1.0)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(1.0)
                end
	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BROT3BT', army, v):ScaleEmitter(0.8)
                end
            end,    
		},
		
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.45 },
		
        mgweapon2 = Class(AAASonicPulseBatteryWeapon) {
			FxMuzzleFlashScale = 1.2,
			FxMuzzleFlash = {'/effects/emitters/sonic_pulse_muzzle_flash_02_emit.bp',},
        },
    },
}

TypeClass = BROT3BT