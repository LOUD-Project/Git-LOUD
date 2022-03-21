local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TDFRiotWeapon = WeaponsFile.TDFRiotWeapon
local TAAFlakArtilleryCannon = WeaponsFile.TAAFlakArtilleryCannon
local TDFPlasmaCannonWeapon = WeaponsFile.TDFPlasmaCannonWeapon

local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')
local ForkThread = ForkThread

BEA0403 = Class(TAirUnit) {
    Weapons = {

        Turret = Class(TDFGaussCannonWeapon) {},

        AAAFlak = Class(TAAFlakArtilleryCannon) {},

        GatlingAACannon01 = Class(TDFPlasmaCannonWeapon){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Front_Left_AAC_Muzzle', self.unit:GetArmy(), Effects.WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Front_Left_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end

                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                TDFPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)
            end,
        },

        GatlingAACannon02 = Class(TDFPlasmaCannonWeapon){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Front_Right_AAC_Muzzle', self.unit:GetArmy(), Effects.WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Front_Right_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end

                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                TDFPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)
            end,
        },

        GatlingAACannon03 = Class(TDFPlasmaCannonWeapon){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Back_Left_AAC_Muzzle', self.unit:GetArmy(), Effects.WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then
                    self.SpinManip = CreateRotator(self.unit, 'Back_Left_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end

                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                TDFPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)
            end,
        },

        GatlingAACannon04 = Class(TDFPlasmaCannonWeapon){
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Back_Right_AAC_Muzzle', self.unit:GetArmy(), Effects.WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then
                    self.SpinManip = CreateRotator(self.unit, 'Back_Right_AAC_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                TDFPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)
            end,
        },
    },

    DestroyNoFallRandomChance = 1.1,
    FxDamageScale = 1.5,

    OnStopBeingBuilt = function(self,builder,layer)
    
		self.AirPadTable = {}
        
		self:ForkThread(self.AirPad)

        TAirUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    AirPad = function(self)
		if not self:IsDead() then
			WaitSeconds(1)
			if not self:IsDead() then
				self:HideBone('AttachRepair01', true)
				self:HideBone('AttachRepair02', true)
				self:HideBone('AttachRepair03', true)
				self:HideBone('AttachRepair04', true)
				self:HideBone('AttachRepair05', true)
				self:HideBone('AttachRepair06', true)
--[[
				-- Gets the platforms current orientation
				local platOrient = self:GetOrientation()
            
				-- Gets the current position of the platform in the game world
				local location01 = self:GetPosition('AttachRepair01')
				local location02 = self:GetPosition('AttachRepair06')

				-- Creates our AirPad over the platform with a ranomly generated Orientation
				local AirPad01 = CreateUnit('beb0001', self:GetArmy(), location01[1], location01[2]+6, location01[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Air')  
				local AirPad02 = CreateUnit('beb0001', self:GetArmy(), location02[1], location02[2]+6, location02[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Air')
            
				-- Adds the newly created AirPad to the parent platforms AirPad table
				table.insert (self.AirPadTable, AirPad01)
				table.insert (self.AirPadTable, AirPad02)

				-- Sets the platform unit as the AirPad parent
				AirPad01:SetParent(self, 'bea0403')
				AirPad01:SetCreator(self)  
				AirPad02:SetParent(self, 'bea0403')
				AirPad02:SetCreator(self)  

				AirPad01:AttachTo(self, 'AttachRepair01')
				AirPad02:AttachTo(self, 'AttachRepair06')

				-- AirPad clean up scripts
				self.Trash:Add(AirPad01)
				self.Trash:Add(AirPad02)
--]]
			end
		end 
	end,
--[[
    OnScriptBitSet = function(self, bit)
        TAirUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
    	self:SetWeaponEnabledByLabel('RightTurret01', true)
    	self:SetWeaponEnabledByLabel('RightTurret02', true)
    	self:SetWeaponEnabledByLabel('LeftTurret01', true)
    	self:SetWeaponEnabledByLabel('LeftTurret02', true)
    	self:SetSpeedMult(1)
    	end
    end,

    OnScriptBitClear = function(self, bit)
        TAirUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
        self:SetWeaponEnabledByLabel('RightTurret01', true)
    	self:SetWeaponEnabledByLabel('RightTurret02', true)
    	self:SetWeaponEnabledByLabel('LeftTurret01', true)
    	self:SetWeaponEnabledByLabel('LeftTurret02', true)
    	self:SetSpeedMult(1)
    	end
    end,
--]]	
	--Cleans up threads and drones on death
	OnKilled = function(self, instigator, type, overkillRatio)
		self:HideBone('AttachRepair01', true)
		self:HideBone('AttachRepair02', true)
		self:HideBone('AttachRepair03', true)
		self:HideBone('AttachRepair04', true)
		self:HideBone('AttachRepair05', true)
		self:HideBone('AttachRepair06', true)

		if table.getn({self.AirPadTable}) > 0 then
			for k, v in self.AirPadTable do 
				IssueClearCommands({self.AirPadTable[k]}) 
				IssueKillSelf({self.AirPadTable[k]})
			end
		end

        TAirUnit.OnKilled(self, instigator, type, overkillRatio)
	end,
}

TypeClass = BEA0403