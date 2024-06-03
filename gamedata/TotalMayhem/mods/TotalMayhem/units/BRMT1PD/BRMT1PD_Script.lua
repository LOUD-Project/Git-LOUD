local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRMT1PD = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
		
            FxMuzzleFlashScale = 0.7,
            FxMuzzleFlash = { 
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_03_emit.bp',
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_06_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
			FxVentEffect = EffectTemplate.CDisruptorVentEffect,
			FxVentEffect2 = EffectTemplate.WeaponSteam01,
			FxMuzzleEffect = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'Muzzle', army, v):ScaleEmitter(1.1)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(.75)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'Muzzle', army, v):ScaleEmitter(1.1)
                end
            end,  
		},
    },
}

TypeClass = BRMT1PD