local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BRNT2EPD = Class(TStructureUnit) {
    Weapons = {

        Gauss01 = Class(TDFGaussCannonWeapon) {

            FxMuzzleFlashScale = 0.9,

            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,
	        FxVentEffect4 = EffectTemplate.CDisruptorVentEffect,

	        FxMuzzleEffect = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()

  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(0.8)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'smoke01', army, v):ScaleEmitter(0.6)
                    CreateAttachedEmitter(self.unit, 'smoke02', army, v):ScaleEmitter(0.6)
                    CreateAttachedEmitter(self.unit, 'smoke03', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'smoke04', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'Turret_Muzzle', army, v):ScaleEmitter(0.6)
                end
	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BRNT2EPD', army, v):ScaleEmitter(0.45)
                end
  	            for k, v in self.FxVentEffect4 do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.4)
                end

            end, 
		},      
    },
}

TypeClass = BRNT2EPD