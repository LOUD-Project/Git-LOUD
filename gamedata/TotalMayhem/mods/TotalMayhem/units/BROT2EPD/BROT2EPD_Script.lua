local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon
local TIFCommanderDeathWeapon = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon
local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BROT2EPD = Class(TStructureUnit) {

    Weapons = {
	
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.6,
            FxMuzzleFlash = { 
            	'/effects/emitters/aeon_dualquantum_cannon_muzzle_flash_emit.bp',
            	'/effects/emitters/aeon_commander_overcharge_flash_01_emit.bp',
                '/effects/emitters/cannon_muzzle_smoke_06_emit.bp',                                
            }, 

	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,
			
	        FxMuzzleEffect = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
			
		        local army = self.unit:GetArmy()
				
	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BROT2EPD', army, v):ScaleEmitter(0.5)
                end
				
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(0.5)
                end
				
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent03', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent04', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent05', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent06', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent07', army, v):ScaleEmitter(0.4)
                    CreateAttachedEmitter(self.unit, 'vent08', army, v):ScaleEmitter(0.4)
                end
				
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(0.3)
                end
            end, 
		},      
		
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
    },
}

TypeClass = BROT2EPD