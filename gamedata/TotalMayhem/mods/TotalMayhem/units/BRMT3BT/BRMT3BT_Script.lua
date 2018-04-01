local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local CreateAttachedEmitter = CreateAttachedEmitter

BRMT3BT = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
		
            FxMuzzleFlashScale = 0.6,
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
                    CreateAttachedEmitter(self.unit, 'BRMT3BT', army, v):ScaleEmitter(0.2)
                end
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(0.6)
                end
  	            for k, v in self.FxVentEffect5 do
                    CreateAttachedEmitter(self.unit, 'stikkflamme01', army, v):ScaleEmitter(0.6)
                    CreateAttachedEmitter(self.unit, 'stikkflamme02', army, v):ScaleEmitter(0.6)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.5)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(0.5)
                end
            end,                   
        },
        
        rocket = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.5,                 
        },
    },
}

TypeClass = BRMT3BT