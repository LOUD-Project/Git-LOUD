local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TAAPhalanxWeapon = import('/lua/terranweapons.lua').TAMPhalanxWeapon

local CreateBoneEffects  = import('/lua/effectutilities.lua').CreateBoneEffects
local WeaponSteam        = import('/lua/effecttemplates.lua').WeaponSteam01

local CreateRotator = CreateRotator

BELK002 = Class(TLandUnit) {

    Weapons = {

        GatlingCannon = Class(TAAPhalanxWeapon) {

            PlayFxWeaponPackSequence = function(self)

                if self.SpinManip1 then
                    self.SpinManip1:SetTargetSpeed(0)
                end

                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
				
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Muzzle', self.unit.Army, WeaponSteam )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Muzzle', self.unit.Army, WeaponSteam )
   
                TAAPhalanxWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxRackSalvoChargeSequence = function(self)
            
                if not self.SpinManip1 then 
                    self.SpinManip1 = CreateRotator(self.unit, 'Right_Barrel', 'z', nil, 360, 180, 60)
                    self.unit.Trash:Add(self.SpinManip1)
                end
   
                if not self.SpinManip2 then 
                    self.SpinManip2 = CreateRotator(self.unit, 'Left_Barrel', 'z', nil, 360, 180, 60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
   
                self.SpinManip1:SetTargetSpeed(500)

                self.SpinManip2:SetTargetSpeed(500)

                TAAPhalanxWeapon.PlayFxRackSalvoChargeSequence(self)
            end,            
            
            PlayFxRackSalvoReloadSequence = function(self)
            
                if self.SpinManip1 then
                    self.SpinManip1:SetTargetSpeed(200)
                end
   
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(200)
                end
   
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Muzzle', self.unit.Army, WeaponSteam )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Muzzle', self.unit.Army, WeaponSteam )
                
				TAAPhalanxWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
        },
        
    }, 

}

TypeClass = BELK002