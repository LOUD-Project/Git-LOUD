local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRNT3WT = Class(TLandUnit) {

    Weapons = {
	
        MainGun = Class(TDFGaussCannonWeapon) {
		
            FxMuzzleFlashScale = 1.0,
            FxMuzzleFlash = { '/effects/emitters/proton_artillery_muzzle_01_emit.bp' },
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,

	        FxMuzzleEffect = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash,

	        PlayFxMuzzleSequence = function(self, muzzle)
			
		        local army = self.unit:GetArmy()
		        
  	            for k, v in self.FxMuzzleEffect do
				
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle2', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle3', army, v):ScaleEmitter(0.5)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle4', army, v):ScaleEmitter(0.5)
					
                end
				
  	            for k, v in self.FxVentEffect do
				
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.2)
                end
				
  	            for k, v in self.FxVentEffect2 do
				
                    CreateAttachedEmitter(self.unit, 'aim', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent03', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent04', army, v):ScaleEmitter(0.4)
					
                end
            end, 
		},
	
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.25 },
    },
}

TypeClass = BRNT3WT