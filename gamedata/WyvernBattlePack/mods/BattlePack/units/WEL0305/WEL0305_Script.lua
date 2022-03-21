local TerranWeaponFile = import('/lua/terranweapons.lua')

local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local TDFIonizedPlasmaCannon = TerranWeaponFile.TDFIonizedPlasmaCannon
local TDFPlasmaCannonWeapon = TerranWeaponFile.TDFPlasmaCannonWeapon
local TAALinkedRailgun = TerranWeaponFile.TAALinkedRailgun
local TAMPhalanxWeapon = import('/lua/terranweapons.lua').TAMPhalanxWeapon

local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')

WEL0305 = Class(TWalkingLandUnit) {

    Weapons = {
        PlasmaCannon01 = Class(TDFIonizedPlasmaCannon) {},
        
		GatlingCannon = Class(TDFPlasmaCannonWeapon) {
        
			PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Gatgun2', self.unit:GetArmy(), Effects.WeaponSteam01 )
				self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'GatGunBarrel2', self.unit:GetArmy(), Effects.WeaponSteam01 )
				self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'GatGunMuzzle01', self.unit:GetArmy(), Effects.WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxRackSalvoChargeSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'GatGunBarrel2', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                TDFPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,            
            
            PlayFxRackSalvoReloadSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(200)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Gatgun2', self.unit:GetArmy(), Effects.WeaponSteam01 )
				self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'GatGunBarrel2', self.unit:GetArmy(), Effects.WeaponSteam01 )
				self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'GatGunMuzzle01', self.unit:GetArmy(), Effects.WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
		},
        
		AA = Class(TAALinkedRailgun) {},
        
		TML = Class(TAMPhalanxWeapon) {},
    },

}

TypeClass = WEL0305