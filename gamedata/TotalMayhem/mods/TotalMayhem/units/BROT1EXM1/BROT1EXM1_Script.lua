local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local DisruptorCannon               = import('/lua/aeonweapons.lua').ADFDisruptorCannonWeapon
local TDFGaussCannonWeapon          = WeaponsFile.TDFLandGaussCannonWeapon
local TDFRiotWeapon                 = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon    --WeaponsFile.TDFMachineGunWeapon

WeaponsFile = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

BROT1EXM1 = Class(CWalkingLandUnit) {

    Weapons = {
        MainGun = Class(DisruptorCannon) {

            FxMuzzleFlashScale = 1,
--[[
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            },
--]]			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,

--	        FxMuzzleEffect = EffectTemplate.ADisruptorCannonMuzzle01,

	        PlayFxMuzzleSequence = function(self, muzzle)

		        local army = self.unit:GetArmy()
		        
--  	            for k, v in self.FxMuzzleEffect do
  --                  CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(0.7)
--                end

  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'vent01', army, v):ScaleEmitter(0.3)
                    CreateAttachedEmitter(self.unit, 'vent02', army, v):ScaleEmitter(0.3)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'stikkflamme', army, v):ScaleEmitter(0.4)
                end
            end,                   
        },
		
        Riotgun = Class(TDFRiotWeapon) {
            --FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
            FxMuzzleFlashScale = 0.25, 
        },
		
        rocket = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.1,
		},

    },
}

TypeClass = BROT1EXM1