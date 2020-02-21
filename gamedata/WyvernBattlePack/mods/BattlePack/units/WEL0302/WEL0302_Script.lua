local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local TDFPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFPlasmaCannonWeapon

local CreateBoneEffects = import('/lua/effectutilities.lua').CreateBoneEffects
local WeaponSteam01 = import('/lua/effecttemplates.lua').WeaponSteam01

WEL0302 = Class(TWalkingLandUnit) 
{
    Weapons = {
        GatlingCannon = Class(TDFPlasmaCannonWeapon) 
        {     

            PlayFxWeaponPackSequence = function(self)
            
                if self.SpinManip1 then
                    self.SpinManip1:SetTargetSpeed(0)
                end
                
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Arm_Barrel_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Arm_Barrel_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxRackSalvoChargeSequence = function(self)
            
                if not self.SpinManip1 then 
                    self.SpinManip1 = CreateRotator(self.unit, 'LeftArmBarrel', 'z', nil, 300, 30, 135)
                    self.unit.Trash:Add(self.SpinManip1)
                end
                
                if not self.SpinManip2 then
                    self.SpinManip2 = CreateRotator(self.unit, 'RightArmBarrel', 'z', nil, 300, 30, 135)
                    self.unit.Trash:Add(self.SpinManip2)                
                end
                
                if self.SpinManip1 then
                    self.SpinManip1:SetTargetSpeed(300)
                end
                
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(300)
                end                
                
                TDFPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,            
            
            PlayFxRackReloadSequence = function(self)

                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Arm_Barrel_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Arm_Barrel_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                
                TDFPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)

            end,
--[[            
            PlayFxMuzzleSequence = function(self, muzzle)
            
                if not self.SpinManip1 and not self.unit:IsDead() then 
                    self.SpinManip1 = CreateRotator(self.unit, 'RightArmBarrel', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip1)
                end
                
                if not self.SpinManip2 and not self.unit:IsDead() then
                    self.SpinManip2 = CreateRotator(self.unit, 'LeftArmBarrel', 'z', nil, 270, 180, 60)                
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                --for k, v in self.FxChassisMuzzleFlash do
                  --  CreateAttachedEmitter(self.unit, 'eject1', self.unit:GetArmy(), v):ScaleEmitter(0.5)
                  --  CreateAttachedEmitter(self.unit, 'eject2', self.unit:GetArmy(), v):ScaleEmitter(0.5)
                --end
            end,                        

            CreateProjectileAtMuzzle = function(self, muzzle)
            
                local proj = TDFPlasmaCannonWeapon.CreateProjectileAtMuzzle(self, muzzle)
                
                if self.SpinManip1 and not self.unit:IsDead() then
                    self.SpinManip1:SetTargetSpeed(500)
                end
                
                if self.SpinManip2 and not self.unit:IsDead() then
                    self.SpinManip2:SetTargetSpeed(500)
                end
            end,

            OnLostTarget = function(self)
                if self.SpinManip1 and not self.unit:IsDead() then
                    self.SpinManip1:SetTargetSpeed(0)
                end
                if self.SpinManip2 and not self.unit:IsDead() then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Right_Arm_Barrel_Muzzle', self.unit:GetArmy(), Effects.WeaponSteam01 )
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Left_Arm_Barrel_Muzzle', self.unit:GetArmy(), Effects.WeaponSteam01 )
                TDFPlasmaCannonWeapon.OnLostTarget(self)
            end,
--]]
        },
    },
}

TypeClass = WEL0302