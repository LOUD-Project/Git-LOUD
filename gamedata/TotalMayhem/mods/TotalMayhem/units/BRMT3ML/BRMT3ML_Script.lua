local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local LOUDATTACHEMITTER = CreateAttachedEmitter

BRMT3ML = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.6,
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,
	        FxVentEffect4 = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        FxMuzzleEffect = EffectTemplate.CIFCruiseMissileLaunchSmoke,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
  	            for k, v in self.FxMuzzleEffect do
                    LOUDATTACHEMITTER(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1.0)
                end
  	            for k, v in self.FxVentEffect2 do
                    LOUDATTACHEMITTER(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(0.35)
                end
	            for k, v in self.FxVentEffect3 do
                    LOUDATTACHEMITTER(self.unit, 'BRMT3ML', army, v):ScaleEmitter(0.25)
                end
	            for k, v in self.FxVentEffect4 do
                    LOUDATTACHEMITTER(self.unit, 'vent01', army, v):ScaleEmitter(3.1)
                    LOUDATTACHEMITTER(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(0.5)
                end
            end, 
		},
    },
}

TypeClass = BRMT3ML