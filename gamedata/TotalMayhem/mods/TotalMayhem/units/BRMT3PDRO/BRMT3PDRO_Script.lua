
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRMT3PDRO = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 1.25,
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            },
			
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
	        FxVentEffect5 = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        FxMuzzleEffect = EffectTemplate.CIFCruiseMissileLaunchSmoke,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle2', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle3', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle4', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle5', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle6', army, v):ScaleEmitter(1)
                end

  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(1.5)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle3', army, v):ScaleEmitter(1.5)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle6', army, v):ScaleEmitter(1.5)
                end				
				
  	            for k, v in self.FxVentEffect5 do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzleb', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle2b', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle3b', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle4b', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle5b', army, v):ScaleEmitter(1)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle6b', army, v):ScaleEmitter(1)
                end
            end, 
		},
    },
}

TypeClass = BRMT3PDRO