
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local AWeapons = import('/lua/aeonweapons.lua')

local AIFArtillerySonanceShellWeapon = AWeapons.AIFArtillerySonanceShellWeapon
local AAAZealotMissileWeapon = AWeapons.AAAZealotMissileWeapon
local TIFCommanderDeathWeapon = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local LOUDATTACHEMITTER = CreateAttachedEmitter

BROT3SHPD = Class(TStructureUnit) {

    Weapons = {
        cannonweapon = Class(AIFArtillerySonanceShellWeapon) {
            FxMuzzleFlashScale = 4.85,
            FxMuzzleFlash = { 
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_03_emit.bp',
            	'/effects/emitters/aeon_quanticcluster_muzzle_flash_06_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
			FxImpactLand = EffectTemplate.TLandGaussCannonHit01,
			FxLandHitScale = 3,
			
			FxGroundEffect = EffectTemplate.ConcussionRingLrg01,
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,

	        FxMuzzleEffect = EffectTemplate.TIonizedPlasmaGatlingCannonHit01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
	            for k, v in self.FxGroundEffect do
                    LOUDATTACHEMITTER(self.unit, 'BROT3SHPD', army, v):ScaleEmitter(0.5)
                end
				
	            for k, v in self.FxVentEffect3 do
                    LOUDATTACHEMITTER(self.unit, 'BROT3SHPD', army, v):ScaleEmitter(0.5)
                end
				
  	            for k, v in self.FxMuzzleEffect do
                    LOUDATTACHEMITTER(self.unit, 'aim2', army, v):ScaleEmitter(1.25)
                end
				
  	            for k, v in self.FxVentEffect do
                    LOUDATTACHEMITTER(self.unit, 'vent01', army, v):ScaleEmitter(0.75)
                    LOUDATTACHEMITTER(self.unit, 'vent02', army, v):ScaleEmitter(1)
                    LOUDATTACHEMITTER(self.unit, 'vent03', army, v):ScaleEmitter(0.75)
                    LOUDATTACHEMITTER(self.unit, 'vent04', army, v):ScaleEmitter(1)
                    LOUDATTACHEMITTER(self.unit, 'vent05', army, v):ScaleEmitter(0.75)
                    LOUDATTACHEMITTER(self.unit, 'vent06', army, v):ScaleEmitter(1)
                    LOUDATTACHEMITTER(self.unit, 'vent07', army, v):ScaleEmitter(0.75)
                    LOUDATTACHEMITTER(self.unit, 'vent08', army, v):ScaleEmitter(1)
                    LOUDATTACHEMITTER(self.unit, 'vent09', army, v):ScaleEmitter(0.75)
                    LOUDATTACHEMITTER(self.unit, 'vent10', army, v):ScaleEmitter(1)
                end
				
  	            for k, v in self.FxVentEffect2 do
                    LOUDATTACHEMITTER(self.unit, 'aim2', army, v):ScaleEmitter(1.25)
                    LOUDATTACHEMITTER(self.unit, 'aim', army, v):ScaleEmitter(1.25)
                end
            end,  
		},
		
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
		
        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
    },
}

TypeClass = BROT3SHPD