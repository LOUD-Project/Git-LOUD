local CWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local ADFLaserLightWeapon = import('/lua/aeonweapons.lua').ADFLaserLightWeapon
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BROT3HAM = Class(CWalkingLandUnit) {

    Weapons = {

        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.45 },
		
        Riotgun = Class(ADFLaserLightWeapon) { },
		
        armweapon = Class(TDFGaussCannonWeapon) {
		
            FxMuzzleFlashScale = 1.2,
			
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
            }, 
			
			FxGroundEffect = EffectTemplate.ConcussionRingLrg01,
			FxVentEffect = EffectTemplate.WeaponSteam01,			
	        FxMuzzleEffect = EffectTemplate.AIFBallisticMortarFlash02,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
			
		        local army = self.unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    CreateAttachedEmitter(self.unit, 'BROT3HAM', army, v):ScaleEmitter(1)
                end
			
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, muzzle, army, v):ScaleEmitter(2.4)
                end
				
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, muzzle, army, v):ScaleEmitter(2.2)
                end
            end, 
		},  

    },
}

TypeClass = BROT3HAM