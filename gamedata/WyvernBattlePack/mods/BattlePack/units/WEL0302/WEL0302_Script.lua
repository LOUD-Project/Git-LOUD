local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TDFPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFPlasmaCannonWeapon

local CreateBoneEffects = import('/lua/effectutilities.lua').CreateBoneEffects
local WeaponSteam01 = import('/lua/effecttemplates.lua').WeaponSteam01

local TrashAdd = TrashBag.Add

WEL0302 = Class(TWalkingLandUnit) 
{
    Weapons = {
        GatlingCannon = Class(TDFPlasmaCannonWeapon){     

            PlayFxWeaponPackSequence = function(self)
            
                if self.SpinManip1 then
                    self.SpinManip1:SetTargetSpeed(0)
                end
                
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Arm_Barrel_Muzzle', self.unit.Army, WeaponSteam01 )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Arm_Barrel_Muzzle', self.unit.Army, WeaponSteam01 )
                
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxRackSalvoChargeSequence = function(self)
            
                if not self.SpinManip1 then 
                    self.SpinManip1 = CreateRotator(self.unit, 'LeftArmBarrel', 'z', nil, 300, 30, 135)
                    TrashAdd( self.unit.Trash, self.SpinManip1 )
                end
                
                if not self.SpinManip2 then
                    self.SpinManip2 = CreateRotator(self.unit, 'RightArmBarrel', 'z', nil, 300, 30, 135)
                    TrashAdd( self.unit.Trash, self.SpinManip2 )
                end
                
                self.SpinManip1:SetTargetSpeed(300)

                self.SpinManip2:SetTargetSpeed(300)
                
                TDFPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,            
            
            PlayFxRackReloadSequence = function(self)

                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Arm_Barrel_Muzzle', self.unit.Army, WeaponSteam01 )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Arm_Barrel_Muzzle', self.unit.Army, WeaponSteam01 )
                
                TDFPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)

            end,

        },
    },
}

TypeClass = WEL0302