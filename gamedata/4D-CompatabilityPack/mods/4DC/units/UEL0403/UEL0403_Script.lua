-----------------------------------------------------------------
--  File     :  /units/UEL0403/UEL0403_script.lua
--  Author(s):  EbolaSoup, Resin Smoker, Optimus Prime, Vissroid
--  Summary  :  EbolaSoup's Experimental Quadruped Bot for UEF
--  Copyright © 2010 4DC  All rights reserved.
----------------------------------------------------------------

local TerranWeaponFile = import('/lua/terranweapons.lua') 
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit 
local EffectTemplate = import('/lua/EffectTemplates.lua')

local WeaponSteam01 = import('/lua/effecttemplates.lua').WeaponSteam01

local WeaponFile = import('/lua/terranweapons.lua')

local TSAMLauncher = WeaponFile.TSAMLauncher 
local TDFIonizedPlasmaCannon = TerranWeaponFile.TDFIonizedPlasmaCannon 
local TIFCommanderDeathWeapon = TerranWeaponFile.TIFCommanderDeathWeapon 
local BalrogMagmaCannonWeapon = import('/mods/4DC/lua/4D_weapons.lua').BalrogMagmaCannonWeapon 
local TIFCruiseMissileLauncher = WeaponFile.TIFCruiseMissileLauncher 
local TDFHeavyPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFHeavyPlasmaGatlingCannonWeapon 

UEL0403 = Class(TWalkingLandUnit) { 

    Weapons = {
	
        MagmaCannon = Class(BalrogMagmaCannonWeapon) {},
		
        ChainGun_L = Class(TDFHeavyPlasmaCannonWeapon) {
		
            PlayFxWeaponUnpackSequence = function(self)
			
                if not self.SpinManip_L then
                    self.SpinManip_L = CreateRotator(self.unit, 'LeftShoulder_GunBarrel_A', 'z', nil, -100, -100, 100) 
                    self.unit.Trash:Add(self.SpinManip_L)
                end
				
                if self.SpinManip_L then 
                    self.SpinManip_L:SetTargetSpeed(-500) 
                end
				
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self) 
            end,
			
            PlayFxWeaponPackSequence = function(self)
			
                if self.SpinManip_L then 
                    self.SpinManip_L:SetTargetSpeed(0) 
                end
				
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponPackSequence(self) 
            end,
			
            PlayFxRackSalvoReloadSequence = function(self)
			
                if self.SpinManip_L then
                    self.SpinManip_L:SetTargetSpeed(200)
                end
				
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'LeftShoulder_GunBarrel_A', self.unit:GetArmy(), WeaponSteam01 )
				
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,

            PlayFxRackSalvoChargeSequence = function(self)
			
                if not self.SpinManip_L then 
                    self.SpinManip_L = CreateRotator(self.unit, 'LeftShoulder_GunBarrel_A', 'z', nil, -100, -100, 100)
                    self.unit.Trash:Add(self.SpinManip_L)
                end
                
                if self.SpinManip_L then
                    self.SpinManip_L:SetTargetSpeed(-500)
                end
				
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,   			
        },
		
        ChainGun_R = Class(TDFHeavyPlasmaCannonWeapon) {
		
            PlayFxWeaponUnpackSequence = function(self)
			
                if not self.SpinManip_R then
                    self.SpinManip_R = CreateRotator(self.unit, 'RightShoulder_GunBarrel_A', 'z', nil, 100, 100, 100) 
                    self.unit.Trash:Add(self.SpinManip_R) 
                end
				
                if self.SpinManip_R then
                    self.SpinManip_R:SetTargetSpeed(500)
                end
				
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self) 
            end,
			
            PlayFxWeaponPackSequence = function(self)
			
                if self.SpinManip_R then
                    self.SpinManip_R:SetTargetSpeed(0)
                end
				
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
			
            PlayFxRackSalvoReloadSequence = function(self)
			
                if self.SpinManip_R then
                    self.SpinManip_R:SetTargetSpeed(200)
                end
				
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'RightShoulder_GunBarrel_A', self.unit:GetArmy(), WeaponSteam01 )
				
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end, 			
        },
        
        PlasmaCannon = Class(TDFIonizedPlasmaCannon) {},
        
        MissileTube = Class(TSAMLauncher) { FxMuzzleFlash = EffectTemplate.TAAMissileLaunchNoBackSmoke },
		
        CruiseMissile_L = Class(TIFCruiseMissileLauncher) {
		
            CurrentRack_L = 1,
			
            CreateProjectileAtMuzzle = function(self, muzzle)
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack_L].MuzzleBones[1] 
                if self.CurrentRack_L >= 2 then 
                    self.CurrentRack_L = 1 
                else 
                    self.CurrentRack_L = self.CurrentRack_L + 1 
                end 
                TIFCruiseMissileLauncher.CreateProjectileAtMuzzle(self, muzzle) 
            end, 
        },
		
        CruiseMissile_R = Class(TIFCruiseMissileLauncher) { 
            CurrentRack_R = 1, 
            CreateProjectileAtMuzzle = function(self, muzzle) 
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack_R].MuzzleBones[1] 
                if self.CurrentRack_R >= 2 then 
                    self.CurrentRack_R = 1 
                else 
                    self.CurrentRack_R = self.CurrentRack_R + 1 
                end 
                TIFCruiseMissileLauncher.CreateProjectileAtMuzzle(self, muzzle) 
            end, 
        },
		
        DeathWeapon = Class(TIFCommanderDeathWeapon) {}, 
    },                
} 
TypeClass = UEL0403