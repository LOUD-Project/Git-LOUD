local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon
local CDFHeavyMicrowaveLaserGenerator = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGenerator

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

URB2306 = Class(CStructureUnit) {
    Weapons = {
    
        BeamCannon = Class(CDFHeavyMicrowaveLaserGenerator) {

            FxMuzzleFlashScale = 1.25,

            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            },
			
	        FxMuzzleEffect = EffectTemplate.CIFCruiseMissileLaunchSmoke,
			
	        FxVentEffect = EffectTemplate.WeaponSteam01,			
	        FxVentEffect2 = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)

		        local army = self.unit:GetArmy()
		        
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'LaserTurretSleeve', army, v):ScaleEmitter(1.5)
                end

  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'Sleeve', army, v):ScaleEmitter(1.5)
                end				
				
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, muzzle, army, v):ScaleEmitter(1)
                end
            end, 
        },

        AutoCannon = Class(CDFLaserHeavyWeapon) {}
    },
}
TypeClass = URB2306