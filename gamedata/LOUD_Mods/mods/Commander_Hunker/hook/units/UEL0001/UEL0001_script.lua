#****************************************************************************
#**
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**
#**  Summary  :  UEF Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local util = import('/lua/utilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')


local OldUEL0001 = UEL0001

local Hunker = import('/mods/Commander_Hunker/lua/hunker.lua')



UEL0001 = Hunker.AddHunker(OldUEL0001)
--[[
UEL0001 = Class(OldUEL0001) {  

	OnStopBeingBuilt = function(self,builder,layer)
        OldUEL0001.OnStopBeingBuilt(self,builder,layer)
		self.AllowHunker = true
		self.IsHunkering = false
		WARN('WHOOP WHOOP, IVE STOPPED BEING BUILT.. FROM UEL0001_SCRIPT')
	end, 
	
	OnDamage = function(self, instigator, amount, vector, damageType)
		if not self.IsHunkering then 
			OldUEL0001.OnDamage(self, instigator, amount, vector, damageType)
		end
	end,
		
	OnExtraToggleClear = function(self, ToggleName)
		OldUEL0001.OnExtraToggleClear(self, ToggleName)
		if ToggleName == 'RULEETC_HunkerToggle' then
			if self.canHunker then 
				self.IsHunkering = true
				self.canHunker = false
				self.AllowHunker = false
								
				IssueStop( {self} )
				IssueClearCommands ( { self } ) 
				self:SetBlockCommandQueue(true)
				self:RemoveExtraCap('RULEETC_HunkerToggle')
				self:SetFireState(1)
				self:SetUnSelectable(true)
				self:SetBusy(true)
				self:SetCanBeKilled(false)
				
				LOG('fired the hunker toggle')
								
				ForkThread(function()
				
					while self:GetMotionStatus() != 'Stopped' do
						WaitTicks(1)
					end
					
					--WaitTicks(3)
					
					local loc = self:GetPosition()
					local ori = self:GetOrientation()
					local layer = self:GetCurrentLayer()
					local FireState = self:GetFireState()
				
					-- Setup Animation
					self.AnimManip = CreateAnimator(self)
					self.AnimManip:SetPrecedence(0)
					self.Trash:Add(self.AnimManip) 
					
					self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationHunkerDown, false):SetRate(2) 
					WaitFor(self.AnimManip)
								
					local Hunker = CreateUnit('UEF_HShield', self:GetArmy(), loc[1], loc[2], loc[3], ori[1], ori[2], ori[3], ori[4], 'Land')
					Hunker:SetCanBeKilled(false)
					Hunker:SetCollisionShape( 'Sphere', 0, 0, 0, 2.100)
					

					WaitSeconds(1)
					
					self:ForkThread(self.Create_Sparks)
					
					WaitSeconds(12)
					
					self:ForkThread(self.Create_Smoke)
				
					WaitSeconds(10)
					
					
					self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationHunkerUp, false):SetRate(2) 
					WaitFor(self.AnimManip)
					
					self:ForkThread(self.CreateShockWaveBlast)
					
					local MaxHealth = self:GetBlueprint().Defense.MaxHealth
					self:SetHealth(self, MaxHealth)
					self:SetFireState(FireState)
					self:SetUnSelectable(false)
					self:SetBusy(false)
					self:SetBlockCommandQueue(false)
					Hunker:SetCanBeKilled(true)
					Hunker:Kill()
					self:SetCanBeKilled(true)
										
					Hunker = nil
					self.IsHunkering = false
				end)
				
			end
		end	
	
	end,
	
	OnExtraToggleSet = function(self, ToggleName)
		OldUEL0001.OnExtraToggleSet(self, ToggleName)
		
	end,
	
	CreateShockWaveBlast = function(self)
		# Smoke ring, explosion effects
		local army = self:GetArmy()
		local pos = self:GetPosition()
		
        CreateLightParticleIntel( self, -1, army, 35, 10, 'glow_02', 'ramp_blue_13' )
	   
	   self:ForkThread(self.Create_Damage_Ring)
		
		for k, v in EffectTemplate.CommanderTeleport01 do
            CreateEmitterOnEntity( self, army, v )
        end
	end,
	
	Create_Smoke = function(self)
		local totalBones = self:GetBoneCount() - 1
		local army = self:GetArmy()
		for k, v in EffectTemplate.UnitTeleportSteam01 do
			for bone = 1, totalBones do
				CreateAttachedEmitter(self,bone,army, v)
			end
		end
	end, 
	
	Create_ShockWave = function(self)
		local blanketSides = 36
		local blanketAngle = (2*math.pi) / blanketSides
		local blanketStrength = 1
		local blanketVelocity = 8
		local projectileList = {}

		for i = 0, (blanketSides-1) do
			local blanketX = math.sin(i*blanketAngle)
			local blanketZ = math.cos(i*blanketAngle)
			local proj = self:CreateProjectile('/effects/Nuke/Shockwave01_proj.bp', blanketX * 2.5, 0.35, blanketZ * 2.5, blanketX, 0, blanketZ):SetVelocity(blanketVelocity):SetAcceleration(-3)
			table.insert( projectileList, proj )
		end

		WaitSeconds( 2.5 )
		
		for k, v in projectileList do
			v:SetAcceleration(0)
		end
	end,
	
	
	Create_Damage_Ring = function(self)
	
		local army = self:GetArmy()
		local pos = self:GetPosition()
		
		WaitSeconds(.1)
        DamageRing(self, pos, .1, 11, 100, 'Force', false, false)

		# Knockdown force rings
        WaitSeconds(0.39)
        DamageRing(self, pos, 11, 20, 1, 'Force', false, false)
        WaitSeconds(.1)
        DamageRing(self, pos, 11, 20, 1, 'Force', false, false)
        WaitSeconds(0.5)

        # Scorch decal and light some trees on fire
        WaitSeconds(0.3)
        DamageRing(self, pos, 20, 27, 1, 'Fire', false, false)
	end, 
	
	Create_Sparks = function(self)
		local army = self:GetArmy()
		local pos = self:GetPosition()
		
		local numSparks = 120
		local angle = (2*math.pi) / numSparks
		local angleInitial = 0.0 #RandomFloat( 0, angle )
		local angleVariation = (2*math.pi) #0.0 #angle * 0.5

		local emit, x, y, z = nil
		local DirectionMul = 0.02
		local OffsetMul = 1

		for i = 0, (numSparks - 1) do
			x = math.sin(angleInitial + (i*angle) + util.GetRandomFloat(-angleVariation, angleVariation))
			y = 0.5 #RandomFloat(0.5, 1.5)
			z = math.cos(angleInitial + (i*angle) + util.GetRandomFloat(-angleVariation, angleVariation))

			for k, v in EffectTemplate.CloudFlareEffects01 do
				emit = CreateEmitterAtEntity( self, army, v )
				emit:OffsetEmitter( x * OffsetMul, y * OffsetMul, z * OffsetMul )
				emit:SetEmitterCurveParam('XDIR_CURVE', x * DirectionMul, 0.01)
				emit:SetEmitterCurveParam('YDIR_CURVE', y * DirectionMul, 0.01)
				emit:SetEmitterCurveParam('ZDIR_CURVE', z * DirectionMul, 0.01)
				emit:ScaleEmitter( 0.25 )
			end

			WaitSeconds(util.GetRandomFloat( 0.1, 0.15 ))
		end
	end,

    CreateEnhancement = function(self, enh)
        OldUEL0001.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
		
		if enh == 'Hunker' then
			if self.AllowHunker then 
				self.canHunker = true
				self:AddExtraCap('RULEETC_HunkerToggle')
			end
        elseif enh == 'HunkerRemove' then
			self.canHunker = false
		end
   end,

}
--]]
TypeClass = UEL0001