local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

local EffectUtils = import('/lua/effectutilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRMT2PD = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 1,
            FxMuzzleFlash = { 
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_03_emit.bp',
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_06_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
			FxGroundEffect = EffectTemplate.ConcussionRingMed01,
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,
	        FxMuzzleEffect = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    CreateAttachedEmitter(self.unit, 'BRMT2PD', army, v):ScaleEmitter(0.5)
                end
				
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'Muzzle01', army, v):ScaleEmitter(1.5)
                    CreateAttachedEmitter(self.unit, 'Muzzle', army, v):ScaleEmitter(1.5)
                end
				
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(1)
                end

  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'Muzzle', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Muzzle01', army, v):ScaleEmitter(1)
                end
            end,  
		},
    },
}

TypeClass = BRMT2PD