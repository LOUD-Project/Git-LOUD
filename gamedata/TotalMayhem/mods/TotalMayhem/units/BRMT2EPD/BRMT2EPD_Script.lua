local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRMT2EPD = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {

            FxMuzzleFlashScale = 1.5,

            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,

	        FxMuzzleEffect = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BRMT2EPD', army, v):ScaleEmitter(0.5)
                end
	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(2)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(1)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'smoke01', army, v):ScaleEmitter(1)
                end
            end, 
		}, 
    },
}

TypeClass = BRMT2EPD