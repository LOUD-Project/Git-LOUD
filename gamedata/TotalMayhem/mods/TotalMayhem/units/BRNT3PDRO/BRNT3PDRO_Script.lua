
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRNT3PDRO = Class(TStructureUnit) {

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
			
	        FxMuzzleEffect = EffectTemplate.CIFCruiseMissileLaunchSmoke,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()

  	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BRNT3PDRO', army, v):ScaleEmitter(0.5)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.25)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.25)
                    CreateAttachedEmitter(self.unit, 'vent03', army, v):ScaleEmitter(0.25)
                    CreateAttachedEmitter(self.unit, 'vent04', army, v):ScaleEmitter(0.25)
                end

  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'muzzle01', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'muzzle02', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'muzzle03', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'muzzle04', army, v):ScaleEmitter(0.5)
                end
				
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'muzzle02', army, v):ScaleEmitter(1.0)
                    CreateAttachedEmitter(self.unit, 'muzzle04', army, v):ScaleEmitter(1.0)
                end
            end, 
		},
    },
}

TypeClass = BRNT3PDRO