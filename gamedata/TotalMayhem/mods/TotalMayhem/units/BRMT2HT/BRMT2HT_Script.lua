local TLandUnit = import('/lua/terranunits.lua').TLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TDFMachineGunWeapon = WeaponsFile.TDFMachineGunWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtils = import('/lua/effectutilities.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRMT2HT = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.8,
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,

	        FxVentEffect5 = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        FxMuzzleEffect = EffectTemplate.CElectronBolterMuzzleFlash01,

	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()

	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BRMT2HT', army, v):ScaleEmitter(0.2)
                end
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1.2)
                end
  	            for k, v in self.FxVentEffect5 do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle01', army, v):ScaleEmitter(0.7)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle02', army, v):ScaleEmitter(0.7)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.7)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.7)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1.25)
                end
            end, 
		},
		
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.45, },

    },
}

TypeClass = BRMT2HT