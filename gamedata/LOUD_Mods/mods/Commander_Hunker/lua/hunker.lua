local util = import('/lua/utilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local HunkerShield = import('/lua/shield.lua')
local Explosions = import('/lua/defaultexplosions.lua')

function AddHunker(prevClass)

    return Class(prevClass) {
	
		OnStopBeingBuilt = function(self,builder,layer)
	
			prevClass.OnStopBeingBuilt(self,builder,layer)
			
			LOG("*AI DEBUG Hunker OnStopBeingBuilt")
	
			self.HunkerParams = { IsHunkering = false, CanHunker = false, ChargePaused = false, ChargeTime = false, ChargeFraction = false, ChargeProgress = false, }
		end,

		OnDamage = function(self, instigator, amount, vector, damageType)
		
			if not self:GetHunkerParam('IsHunkering') then 
				prevClass.OnDamage(self, instigator, amount, vector, damageType)
			end	
		end,

		OnExtraToggleClear = function(self, ToggleName)
		
			prevClass.OnExtraToggleClear(self, ToggleName)
		
			if ToggleName == 'RULEETC_HunkerToggle' then
			
				if self:GetHunkerParam('CanHunker') and not self:GetHunkerParam('IsHunkering') then 
					self:ForkThread(self.Init_Hunker)
				end
				
			end	
		
			if ToggleName == 'RULEETC_HunkerPauseToggle' then
			
				self:SetHunkerParam('ChargePaused', false)
				self:ForkThread(self.StartHunkerCharge)
				
			end	
			
		end,
	
		OnExtraToggleSet = function(self, ToggleName)
		
			prevClass.OnExtraToggleSet(self, ToggleName)

			if ToggleName == 'RULEETC_HunkerPauseToggle' then
			
				self:SetHunkerParam('ChargePaused', true)
				self:ForkThread(self.PauseHunkerCharge)
				
			end	
			
		end,
	
		Init_Hunker = function(self)
		
			self:KillHunkerCharge()
			
			-- remove the Hunker button when fired --
			self:RemoveExtraCap('RULEETC_HunkerToggle')
			
			self:SetWorkProgress(-1)
			
			self:SetHunkerParam('IsHunkering', true)
			self:SetHunkerParam('CanHunker', false)
		
			local OlShield = false
			local HadShield = false
			local ShieldStat = self:ShieldIsOn()

			local FireState = self:GetFireState()

			IssueStop( {self} )
			IssueClearCommands ( { self } ) 
		
			if self.MyShield then
			
				HadShield = true
				OldShield = self.MyShieldType
				self:DestroyShield()
				
			end
		
			self:SetBlockCommandQueue(true)
			self:SetFireState(1)
			self:SetUnSelectable(true)
			self:SetBusy(true)
			self:SetCanBeKilled(false)
			
			while self:GetMotionStatus() != 'Stopped' do
				WaitTicks(1)
			end

			local loc = self:GetPosition()
			local ori = self:GetOrientation()
			local layer = self:GetCurrentLayer()
			local Faction = self:GetBlueprint().General.FactionName
			local bp = self:GetBlueprint().Enhancements.Hunker
			local FractionComplete = self:GetHunkerChargeFraction()
			local newHealth, EnergyUsage = self:GetHealthEnergy(FractionComplete)
			local army = self:GetArmy()

			-- Setup Animation
			self.AnimManip = CreateAnimator(self)
			self.AnimManip:SetPrecedence(0)
			self.Trash:Add(self.AnimManip) 

			self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationHunkerDown, false):SetRate(2) 
			
			WaitFor(self.AnimManip)

			if Faction == 'Aeon' then 
			
				self:CreateDomeHunkerShield(bp)
				local emit = '/mods/commander_hunker/lua/emitters/aeon/aeon_suckup.bp'		
				self.SuckUp = CreateAttachedEmitter(self, 0, army, emit):ScaleEmitter(0.25)
				
			elseif Faction == 'Cybran' then 
			
				self:CreateDomeHunkerShield(bp)
				local emit = '/mods/commander_hunker/lua/emitters/cybran/cybran_suckup.bp'		
				self.SuckUp = CreateAttachedEmitter(self, 0, army, emit):ScaleEmitter(0.25)
				
			elseif Faction == 'Seraphim' then 
			
				self:CreateDomeHunkerShield(bp)
				local emit = '/mods/commander_hunker/lua/emitters/seraphim/seraphim_suckup.bp'		
				self.SuckUp = CreateAttachedEmitter(self, 0, army, emit):ScaleEmitter(0.40)
				
			elseif Faction == 'UEF' then 
			
				self:CreateDomeHunkerShield(bp)
				local emit = '/mods/commander_hunker/lua/emitters/uef/uef_suckup.bp'				
				self.SuckUp = CreateAttachedEmitter(self, 0, army, emit):ScaleEmitter(0.25)
			
			else
			
				self:CreatePersonalHunkerShield(bp)
				
			end

			WaitSeconds(1)

			self:ForkThread(self.Create_Sparks)

			WaitSeconds(12)

			self:ForkThread(self.Create_Smoke)
		
			--self:ForkThread(self.StartOverrideEnergy, EnergyUsage)

			WaitSeconds(10)

			self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationHunkerUp, false):SetRate(2) 
			WaitFor(self.AnimManip)
		
			self:PlayUnitSound('CommanderArrival')
			self:ForkThread(self.CreateShockWaveBlast)
		
			self:SetHealth(self, newHealth)
			self:SetFireState(FireState)
			self:SetUnSelectable(false)
			self:SetBusy(false)
			self:SetCanBeKilled(true)
			self:SetBlockCommandQueue(false)

			self:DestroyHunkerShield()
		
			if self.SuckUp then 
				self.SuckUp:Destroy()
				self.SuckUp = nil
			end
		
			if HadShield then 
			
				if OldShield == 'Shield' then 
				
					local bp = self:GetBlueprint().Enhancements.ShieldGeneratorField
					self:CreateShield(bp)
					
				elseif OldShield == 'Personal' then 
				
					local bp = self:GetBlueprint().Enhancements.Shield
					self:CreatePersonalShield(bp)
					
				elseif OldShield == 'AntiArtilleryShield' then 
				
					local bp = self:GetBlueprint().Enhancements.ShieldGeneratorField
					self:CreateAntiArtilleryShield(bp)
					
				end
			
				if not ShieldStat then 
					self:DisableShield()
				end
				
			end
		
			self:SetHunkerParam('IsHunkering', false)
			self:ForkThread(self.StartHunkerCharge)
			
		end,

		GetHealthEnergy = function(self, progress)
		
			if not progress then 
				return 0, 0
			end
		
			local maxHealth = self:GetMaxHealth()
			local Health = self:GetHealth()
			local newHealth = progress * maxHealth + Health
			
			if newHealth > maxHealth then 
				newHealth = maxHealth
			end
				
			if progress > 0.4 and progress <= 0.5 then			
				return newHealth, math.random(200, 500)	
			elseif progress > 0.5 and progress <= 0.6 then			
				return newHealth, math.random(300, 600)
			elseif progress > 0.6 and progress <= 0.7 then		
				return newHealth, math.random(400, 700)
			elseif progress > 0.7 and progress <= 0.8 then
				return newHealth, math.random(500, 800)
			elseif progress > 0.8 and progress <= 0.9 then
				return newHealth, math.random(600, 900)
			else
				return newHealth, math.random(700, 1000)
			end
		end, 
	
		StartOverrideEnergy = function(self, EnergyUsage)
		
			--TODO add something in here to make energy fluctuate a little more.
		
			local Use = self:Get_Econ('EnergyIncome') + EnergyUsage
		
			self:AddEnergyUsage('HunkerOverCharge', Use)		
			WaitSeconds(math.random(5,7))
			self:RemoveEnergyUsage('HunkerOverCharge')
			
		end,

		StartChargeEnergyDrain = function(self)		
		
			local UnitBp = self:GetBlueprint()
			local HunkerChargeEnergy = UnitBp.Enhancements.Hunker.MaintenanceConsumptionPerSecondEnergy or 0
		
			if not self:GetEnergyUsage('HunkerCharge') then 
				self:AddEnergyUsage('HunkerCharge', HunkerChargeEnergy)
			else
				self:SetEnergyUsageActive('HunkerCharge')
			end
		end,
	
		StopChargeEnergyDrain = function(self)
		
			self:SetEnergyUsageInActive('HunkerCharge')
			
		end,

		HunkerChargeTimer = function(self, curProgress, time)
		
			while curProgress < time do
			
				self.ChargingThread = CurrentThread()
			
				if self:GetHunkerParam('ChargePaused') then 
					SuspendCurrentThread()
				end

				local fraction = self:Get_Econ('EnergyStorageRatio')
				
				curProgress = curProgress + ( fraction / 10)
				curProgress = math.min( curProgress, time )

				local workProgress = curProgress / time

				self:UpdateChargingProgress( workProgress )
				
				WaitTicks(1)
			end   
			
		end,
	
		UpdateChargingProgress = function(self, progress)
		
			self:SetWorkProgress(progress)
			self:SetChargingProgress(progress)

			if progress > 0.40 and not self:GetHunkerParam('CanHunker') then
			
				self:SetHunkerParam('CanHunker', true)
				
				-- show the Hunker toggle --
				self:AddExtraCap('RULEETC_HunkerToggle')
				
				DoMFD(self, 'can_hunker')
				
			end
		
			if progress >= 1 then 
			
				self:StopChargeEnergyDrain()
				
				DoMFD(self, 'hunker_full_charged')
				
			end
			
		end,
	
		StartHunkerCharge = function(self)
		
			if not self:GetHunkerParam('ChargePaused') then 
			
				if self:GetHunkerParam('IsHunkering') then 
				
					while self:GetHunkerParam('IsHunkering') do
						WaitSeconds(1)
					end
					
				end
		
				if not self:GetHunkerParam('IsHunkering') then 
				
					local bp = self:GetBlueprint().Enhancements.Hunker
					local ChargeTime = self:GetHunkerParam('ChargeTime')
				
					if not ChargeTime then 
					
						ChargeTime = bp.ChargeTime or 10
						self:SetHunkerParam('ChargeTime', ChargeTime)
						
					end

					if self.ChargingThread then 
					
						local FractionComplete = self:GetHunkerChargeFraction()
					
						if FractionComplete < 1 then 
							ResumeThread(self.ChargingThread)
							self:StartChargeEnergyDrain()
						end
						
					else
					
						local ChargeComplete = self:GetHunkerChargeProgress() 
						self:ForkThread(self.HunkerChargeTimer, ChargeComplete, ChargeTime)
						self:StartChargeEnergyDrain()
						
					end
					
				end
				
			end
			
		end,

		PauseHunkerCharge = function(self)
		
			if self:GetHunkerParam('ChargePaused') then 
			
				if self.ChargingThread then 
				
					local CurrProgress = self:GetHunkerChargeFraction()
			
					if CurrProgress < 1 then 
						self:StopChargeEnergyDrain()
					end
					
				end
				
			end
			
		end,
	
		KillHunkerCharge = function(self)
		
			if self.ChargingThread then
			
				KillThread(self.ChargingThread)
				
				self.ChargingThread = nil
				
				self:SetHunkerParam('ChargeProgress', false)
				self:SetHunkerParam('ChargeFraction', false)
				
				self:StopChargeEnergyDrain()
				
			end
			
		end,
	
		SetChargingProgress = function(self, progress)
		
			if not self:GetHunkerParam('ChargeTime') then
			
				local bp = self:GetBlueprint().Enhancements.Hunker
				local ChargeTime = bp.ChargeTime or 5
			
				self:SetHunkerParam('ChargeTime', ChargeTime)
				
			end
		
			if progress then
			
				local ChargeTime = self:GetHunkerParam('ChargeTime')
				
				curProgress = math.min( progress, ChargeTime )
				
				local workProgress = curProgress * ChargeTime
				
				self:SetHunkerParam('ChargeProgress', workProgress)
				self:SetHunkerParam('ChargeFraction', progress)
				
			end
			
		end,
	
		GetHunkerChargeFraction = function(self)
		
			local bp = self:GetBlueprint().Enhancements.Hunker
			local fraction = 0
	
			if bp then 
		
				local ChargeTime = self:GetHunkerParam('ChargeTime') or bp.ChargeTime or 5
				local progress = self:GetHunkerChargeProgress()
				
				curProgress = math.min( progress, ChargeTime )
				
				local ChargeFraction = curProgress / ChargeTime
				fraction = ChargeFraction
			end
		
			return fraction
			
		end,
	
		GetHunkerChargeProgress = function(self)
		
			if not self:GetHunkerParam('ChargeProgress') then 
				return 0
			end

			return self:GetHunkerParam('ChargeProgress')
		end,
	
		SetHunkerChargeTime = function(self, time)
		
			if time then
				self:SetHunkerParam('ChargeTime', time)
			end	
			
		end,
	
		GetHunkerParam = function(self, key)
		
			local params = self.HunkerParams
		
			if params[key] == nil then 
				return nil
			end
		
			return params[key]
			
		end,

		SetHunkerParam = function(self, key, param)
		
			if key then
			
				if not param then 
					self.HunkerParams[key] = false
				else
					self.HunkerParams[key] = param
				end
				
			end	
			
		end,
	
		ResetHunkerParams = function(self)
		
			self.HunkerParams = { IsHunkering = false, CanHunker = false, ChargePaused = false, ChargeTime = false, ChargeFraction = false, ChargeProgress = false, }
			
		end,
	
		--EFFECTS
		
		CreateShockWaveBlast = function(self)
		
			# Smoke ring, explosion effects
			local army = self:GetArmy()
			local pos = self:GetPosition()
			local EmitterList = {}
		
			CreateLightParticleIntel( self, -1, army, 35, 10, 'glow_02', 'ramp_blue_13' )
			Explosions.CreateScorchMarkDecal(self, 6, army)
	   
			self:ForkThread(self.Create_Damage_Ring)
		
			for k, v in EffectTemplate.CommanderTeleport01 do
				local Emit = CreateEmitterOnEntity( self, army, v )
				table.insert( EmitterList, Emit)
			end
		
			WaitSeconds(8)
		
			for id, effect in EmitterList do
				effect:Destroy()
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
				local proj = self:CreateProjectile('/effects/Nuke/Shockwave01_proj.bp', blanketX * 6, 0.35, blanketZ * 6, blanketX, 0, blanketZ):SetVelocity(blanketVelocity):SetAcceleration(-3)
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


		--ENHANCEMENT
	
		CreateEnhancement = function(self, enh)
		
			LOG("*AI DEBUG Creating Hunker Enhancement")
			
			prevClass.CreateEnhancement(self, enh)
		
			local bp = self:GetBlueprint().Enhancements[enh]
		
			if not bp then return end
			

			if enh == 'Hunker' then
			
				self:SetHunkerParam('CanHunker', false)
				self:SetHunkerParam('ChargePaused', false)
				
				self:AddExtraCap('RULEETC_HunkerToggle')
				self:AddExtraCap('RULEETC_HunkerPauseToggle')
				
				self:SetChargingProgress(0)
				
				self:ForkThread(self.StartHunkerCharge)
				
				DoMFD(self, 'hunker_enhancement_complete')
				
			elseif enh == 'HunkerRemove' then
			
				self:KillHunkerCharge()
				self:ResetHunkerParams()
				self:DestroyHunkeShield()
			
				self:RemoveExtraCap('RULEETC_HunkerToggle')
				self:RemoveExtraCap('RULEETC_HunkerPauseToggle')
			end
		
		end,

    }
	
end






