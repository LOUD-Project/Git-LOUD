local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local Cannon = WeaponsFile.TDFLandGaussCannonWeapon
local Flak   = WeaponsFile.TAAFlakArtilleryCannon
local Plasma = WeaponsFile.TDFPlasmaCannonWeapon

WeaponsFile = nil

local CreateBoneEffects      = import('/lua/effectutilities.lua').CreateBoneEffects
local WeaponSteam            = import('/lua/effecttemplates.lua').WeaponSteam01

BEA0403 = Class(TAirUnit) {

    Weapons = {

        Turret  = Class(Cannon) {},

        AAAFlak = Class(Flak) {},

        GatlingAACannon01 = Class(Plasma){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Front_Left_AAC_Muzzle', self.unit:GetArmy(), WeaponSteam )
                Plasma.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Front_Left_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end

                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                Plasma.PlayFxWeaponUnpackSequence(self)
            end,
        },

        GatlingAACannon02 = Class(Plasma){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Front_Right_AAC_Muzzle', self.unit:GetArmy(), WeaponSteam )
                Plasma.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Front_Right_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end

                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                Plasma.PlayFxWeaponUnpackSequence(self)
            end,
        },

        GatlingAACannon03 = Class(Plasma){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Back_Left_AAC_Muzzle', self.unit:GetArmy(), WeaponSteam )
                Plasma.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then
                    self.SpinManip = CreateRotator(self.unit, 'Back_Left_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end

                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                Plasma.PlayFxWeaponUnpackSequence(self)
            end,
        },

        GatlingAACannon04 = Class(Plasma){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Back_Right_AAC_Muzzle', self.unit:GetArmy(), WeaponSteam )
                Plasma.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then
                    self.SpinManip = CreateRotator(self.unit, 'Back_Right_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                Plasma.PlayFxWeaponUnpackSequence(self)
            end,
        },
    },

    DestroyNoFallRandomChance = 1.1,
    FxDamageScale = 1.5,

    OnStopBeingBuilt = function(self,builder,layer)

		self:HideBone('AttachRepair01', true)
		self:HideBone('AttachRepair02', true)
		self:HideBone('AttachRepair03', true)
        self:HideBone('AttachRepair04', true)
		self:HideBone('AttachRepair05', true)
		self:HideBone('AttachRepair06', true)

        TAirUnit.OnStopBeingBuilt(self,builder,layer)
    end,

}

TypeClass = BEA0403