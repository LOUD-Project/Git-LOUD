#****************************************************************************
#**
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**
#**  Summary  :  UEF Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local EffectTemplate = import('/lua/EffectTemplates.lua')
local OldUAL0001 = UAL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')

UAL0001 = Hunker.AddHunker(OldUAL0001)
--[[

UAL0001 = Class(OldUAL0001) {  
    
	OnStopBeingBuilt = function(self,builder,layer)
        OldUAL0001.OnStopBeingBuilt(self,builder,layer)
		self.AllowHunker = true
		self.IsHunkering = false
	end, 
	
	OnDamage = function(self, instigator, amount, vector, damageType)
		if not self.IsHunkering then 
			OldUAL0001.OnDamage(self, instigator, amount, vector, damageType)
		end
	end,
	
	OnScriptBitSet = function(self, bit)
		OldUAL0001.OnScriptBitSet(self, bit)
		
		if bit == 7 then
			if self.canHunker then 
				self.IsHunkering = true
				local loc = self:GetPosition()
				local ori = self:GetOrientation()
				local layer = self:GetCurrentLayer()
				local FireState = self:GetFireState()
				IssueStop( {self} )
				IssueClearCommands ( { self } ) 
				self:RemoveToggleCap('RULEUTC_SpecialToggle')
				self:SetFireState(1)
				self:SetUnSelectable(true)
				self:SetBusy(true)
				self:SetBlockCommandQueue(true)
				self:SetCanBeKilled(false)
								
				ForkThread(function()
				
					-- Setup Animation
					self.AnimManip = CreateAnimator(self)
					self.AnimManip:SetPrecedence(0)
					self.Trash:Add(self.AnimManip)             
					self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationHunkerDown, false):SetRate(2) 
					WaitFor(self.AnimManip)
								
					local Hunker = CreateUnit('AEON_HShield', self:GetArmy(), loc[1], loc[2], loc[3], ori[1], ori[2], ori[3], ori[4], 'Land')
					Hunker:SetCanBeKilled(false)
					Hunker:SetCollisionShape( 'Sphere', 0, 0, 0, 2.100)
					
					WaitSeconds(12)
					
					local totalBones = self:GetBoneCount() - 1
					local army = self:GetArmy()
					for k, v in EffectTemplate.UnitTeleportSteam01 do
						for bone = 1, totalBones do
							CreateAttachedEmitter(self,bone,army, v)
						end
					end
				
					WaitSeconds(6)
					
					self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationHunkerUp, false):SetRate(2) 
					WaitFor(self.AnimManip)
					
					local MaxHealth = self:GetBlueprint().Defense.MaxHealth
					self:SetHealth(self, MaxHealth)
					self:SetFireState(FireState)
					self:SetUnSelectable(false)
					self:SetBusy(false)
					self:SetBlockCommandQueue(false)
					Hunker:SetCanBeKilled(true)
					Hunker:Kill()
					self:SetCanBeKilled(true)
					
					self.canHunker = false
					self.AllowHunker = false
					Hunker = nil
					self.IsHunkering = false
				end)
				
			end
		end			
    end,

    CreateEnhancement = function(self, enh)
        OldUAL0001.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
		
		if enh == 'Hunker' then
			if self.AllowHunker then 
				self.canHunker = true
				self:AddToggleCap('RULEUTC_SpecialToggle')
			end
        elseif enh == 'HunkerRemove' then
			self.canHunker = false
		end
   end,

}
--]]
TypeClass = UAL0001