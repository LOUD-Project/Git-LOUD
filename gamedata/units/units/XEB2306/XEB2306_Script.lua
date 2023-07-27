local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFHeavyPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFHeavyPlasmaGatlingCannonWeapon

local CreateBoneEffects = import('/lua/effectutilities.lua').CreateBoneEffects
local WeaponSteam01 = import('/lua/effecttemplates.lua').WeaponSteam01

XEB2306 = Class(TStructureUnit) {

    Weapons = {

        Gatling = Class(TDFHeavyPlasmaCannonWeapon){

			OnCreate = function(self)
			
				TDFHeavyPlasmaCannonWeapon.OnCreate(self)
				
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Gun_Barrel', 'z', nil, 0, 100, 0)
                    self.unit.Trash:Add(self.SpinManip)
                end				
			end,	

            PlayFxWeaponUnpackSequence = function(self)
			
                self.SpinManip:SetTargetSpeed(300)

                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)            
            end,
            
            PlayFxWeaponPackSequence = function(self)
			
                self.SpinManip:SetTargetSpeed(0)

                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Exhaust', self.unit:GetArmy(), WeaponSteam01 )
				
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxRackSalvoChargeSequence = function(self)
			
                self.SpinManip:SetTargetSpeed(300)
                
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            
            PlayFxRackSalvoReloadSequence = function(self)

                self.SpinManip:SetTargetSpeed(100)

                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Exhaust', self.unit:GetArmy(), WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'Gun_Barrel', self.unit:GetArmy(), WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'Gun_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
				
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,    
        }
    },
}

TypeClass = XEB2306