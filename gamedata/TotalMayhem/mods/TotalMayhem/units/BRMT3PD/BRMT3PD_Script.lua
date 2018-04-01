
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local LOUDATTACHEMITTER = CreateAttachedEmitter

BRMT3PD = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 2.0,
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            },
			
			FxGroundEffect = EffectTemplate.ConcussionRingLrg01,
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,

	        FxMuzzleEffect = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    LOUDATTACHEMITTER(self.unit, 'BRMT3PD', army, v):ScaleEmitter(0.5)
                end
				
	            for k, v in self.FxVentEffect3 do
                    LOUDATTACHEMITTER(self.unit, 'BRMT3PD', army, v):ScaleEmitter(1)
                end
				
  	            for k, v in self.FxMuzzleEffect do
                    LOUDATTACHEMITTER(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1.25)
                end
				
  	            for k, v in self.FxVentEffect do
                    LOUDATTACHEMITTER(self.unit, 'cool01', army, v):ScaleEmitter(1)
                    LOUDATTACHEMITTER(self.unit, 'cool02', army, v):ScaleEmitter(1)
                end
				
  	            for k, v in self.FxVentEffect2 do
                    LOUDATTACHEMITTER(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1.25)
                    LOUDATTACHEMITTER(self.unit, 'Turret_Muzzle2', army, v):ScaleEmitter(1.25)
                end
            end, 
		},
    },
}

TypeClass = BRMT3PD