
local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TDFMachineGunWeapon = WeaponsFile.TDFMachineGunWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRNT2MT = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 1.0,
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
	
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
			
	        FxMuzzleEffect = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()

  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle2', army, v):ScaleEmitter(0.5)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.5)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle2', army, v):ScaleEmitter(1)
                end
			end, 
		},
		
        commanderw = Class(TDFMachineGunWeapon) {},
		
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.2, },
    },
}

TypeClass = BRNT2MT