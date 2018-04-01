local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon
local TIFCommanderDeathWeapon = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon

local HawkGaussCannonWeapon = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').HawkGaussCannonWeapon
local TDFGoliathShoulderBeam = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').TDFGoliathShoulderBeam
local GoliathTMDGun = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').GoliathTMDGun
local GoliathRocket = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').GoliathRocket

local utilities = import('/lua/utilities.lua')
local RandomFloat = utilities.GetRandomFloat

local EffectTemplate = import('/lua/EffectTemplates.lua')

local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone

local ForkThread = ForkThread
local ChangeState = ChangeState
local CreateAttachedEmitter = CreateAttachedEmitter

BEL0402 = Class(TWalkingLandUnit) {

	FlamerEffects = { '/mods/BlackOpsUnleashed/effects/emitters/ex_flamer_torch_01.bp' },
	
	Weapons = {
	
		Flamer = Class(HawkGaussCannonWeapon) {},
		
		MissileWeapon = Class(GoliathRocket) {
		
			CreateProjectileAtMuzzle = function(self, muzzle)
                self.unit:PlayUnitSound('MissileFire')
				GoliathRocket.CreateProjectileAtMuzzle(self, muzzle)
            end,
			
		},
		
		TMDTurret = Class(GoliathTMDGun) {},
		
		Laser = Class(TDFGoliathShoulderBeam) {},
		
		HeadWeapon = Class(TDFMachineGunWeapon){},
		
		GoliathDeathNuck = Class(TIFCommanderDeathWeapon) {},
	},
	
	
	--+ Unit Callbacks +--
	
	OnStartBeingBuilt = function(self, builder, layer)
	
		TWalkingLandUnit.OnStartBeingBuilt(self, builder, layer)
		
		if not self.AnimationManipulator then
			self.AnimationManipulator = CreateAnimator(self)
			self.Trash:Add(self.AnimationManipulator)
		end
		
		self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, false):SetRate(0)
	end,
	
	OnStopBeingBuilt = function(self,builder,layer)
	
		TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)		
		
		if self.AnimationManipulator then
			self:SetUnSelectable(true)
			self.AnimationManipulator:SetRate(1)			
			self:ForkThread(function()
				WaitSeconds(self.AnimationManipulator:GetAnimationDuration()*self.AnimationManipulator:GetRate())
				self:SetUnSelectable(false)
				self.AnimationManipulator:Destroy()
			end)
		end 
		
		--Button status toggles
		self.DroneMaintenance = true	--Drone repair/reconstruction toggle; when off, drones will not be automatically repaired and rebuilt
		self.DroneAssist = true			--Drone assistance/management toggle; when off, drones will stay docked unless manually controlled
		
		--Assist management globals
		self.MyAttacker = nil			--Our current attacker
		self.MyTarget = nil				--Our current target (from missile launcher)

		--Drone construction/repair buildrate
		self.BuildRate = self:GetBlueprint().Economy.BuildRate or 30

		--Drone setup (load globals/tables & create drones)
		self:DroneSetup()
		
		self.FlamerEffectsBag = {}
		
		if self.FlamerEffectsBag then
		
			for k, v in self.FlamerEffectsBag do
				v:Destroy()
			end
			
			self.FlamerEffectsBag = {}
		end

		local CreateAttachedEmitter = CreateAttachedEmitter

		for k, v in self.FlamerEffects do
			table.insert( self.FlamerEffectsBag, CreateAttachedEmitter( self, 'Right_Pilot_Light', self:GetArmy(), v ):ScaleEmitter(0.0625) )
			table.insert( self.FlamerEffectsBag, CreateAttachedEmitter( self, 'Left_Pilot_Light', self:GetArmy(), v ):ScaleEmitter(0.0625) )
		end
	end,
	
	--Places the Goliath's first drone-targetable attacker into a global
	OnDamage = function(self, instigator, amount, vector, damagetype)
	
		if not self.Dead --if not dead
		and self.MyAttacker == nil --no existing attacker
		and self:IsValidDroneTarget(instigator) then --attacker is a valid drone target
		
			self.MyAttacker = instigator
			--LOG("Mithy: OnDamage: MyAttacker = " .. self.MyAttacker:GetBlueprint().BlueprintId)
		end
		
		TWalkingLandUnit.OnDamage(self, instigator, amount, vector, damagetype)
	end,
	
	--Drone control buttons
	OnScriptBitSet = function(self, bit)
		--Drone assist toggle, on
		if bit == 1 then
			self.DroneAssist = false
		--Drone recall button
		elseif bit == 7 then
			self:RecallDrones()
			--Pop button back up, as it's not actually a toggle
			self:SetScriptBit('RULEUTC_SpecialToggle', false)
		else
			TWalkingLandUnit.OnScriptBitSet(self, bit)
		end
	end,
	
	OnScriptBitClear = function(self, bit)
		--Drone assist toggle, off
		if bit == 1 then
			self.DroneAssist = true
		--Recall button reset, do nothing
		elseif bit == 7 then
		else
			TWalkingLandUnit.OnScriptBitClear(self, bit)
		end
	end,
	
	--Handles drone docking
    OnTransportAttach = function(self, attachBone, unit)
    	--LOG("Mithy: OnTransportAttach: " .. unit.Name .. " docked at " .. attachBone)
    	self.DroneData[unit.Name].Docked = attachBone
    	unit:SetDoNotTarget(true)
    	--unit.DisallowCollisions = true --too problematic, disabled
        TWalkingLandUnit.OnTransportAttach(self, attachBone, unit)
    end,
    
    --Handles drone undocking, also called when docked drones die
    OnTransportDetach = function(self, attachBone, unit)
    	--LOG("Mithy: OnTransportDetach: " .. unit.Name .. " undocked from " .. attachBone)
	    self.DroneData[unit.Name].Docked = false
	    unit:SetDoNotTarget(false)
    	--unit.DisallowCollisions = false --too problematic, disabled
		--Cancel any in-progress repairs for undocking/dying drones
		if unit.Name == self.BuildingDrone then
			self:CleanupDroneMaintenance(self.BuildingDrone)
		end
        TWalkingLandUnit.OnTransportDetach(self, attachBone, unit)
    end,

	--Cleans up threads and drones on death
	OnKilled = function(self, instigator, type, overkillRatio)
		--Kill our heartbeat thread
		KillThread(self.HeartBeatThread)
		--Clean up any in-progress construction
		ChangeState(self, self.DeadState)
		--Immediately kill existing drones
		if self.DroneTable then
			for name, drone in self.DroneTable do
				IssueClearCommands({drone})
				IssueKillSelf({drone})
			end
		end 
        TWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
	end,
	
	
	--+ Drone Setup / Creation +--

	--Initial drone setup - loads globals, DroneData table, and creates drones
	DroneSetup = function(self)
		--Drone handle table, used to issue orders to all drones at once
		self.DroneTable = {}
		
		--Drone construction globals
		self.BuildingDrone = false	--Holds the name (string) of the drone currently being repaired or rebuilt
		
		local bp = self:GetBlueprint()
		
		--Drone control parameters (inherited by drones in SetParent)
		self.ControlRange = bp.AI.DroneControlRange or 70   --Range at which drones will be recalled
		self.ReturnRange = bp.AI.DroneReturnRange or (ControlRange / 2)	--Range at which returning drones will be released
		self.AssistRange = self.ControlRange + 10	--Max target distance for retaliation - drones can engage targets just beyond recall range
		self.AirMonitorRange = bp.AI.AirMonitorRange or (self.AssistRange / 2)	--Air target search distance
		self.HeartBeatInterval = bp.AI.AssistHeartbeatInterval or 1 # Heartbeat wait time, in seconds

		--Load DroneData table from Goliath BP (name, attachpoint, unitid)
		--Only drones with entries in this table (including unique key names and the other two required values) will be spawned!
		self.DroneData = table.deepcopy(bp.DroneData)
		
		--Load other data from drone BP and spawn drones
		for droneName, droneData in self.DroneData do
			--Set drone name variable
			if not droneData.Name then
				droneData.Name = droneName
			end
			droneData.Blueprint = table.deepcopy(GetUnitBlueprintByName(droneData.UnitID))
			droneData.Economy = droneData.Blueprint.Economy
			droneData.BuildProgress = 1	--Holds the progress of drone rebuilds

			--Create this drone
			self:ForkThread(self.CreateDrone, droneName)
		end
			
		--Assist/monitor heartbeat thread
		self.HeartBeatThread = self:ForkThread(self.AssistHeartBeat)
		
		--Begin drone maintenance monitoring
		ChangeState(self, self.DroneMaintenanceState)
	end,
	
	--Creates specified drone from its entry in DroneData and creates handles
	CreateDrone = function(self, droneName)
		if not self.Dead and not self.DroneTable[droneName] and not self.DroneData[droneName].Active then
		
			if not self:IsValidBone(self.DroneData[droneName].Attachpoint) then
				error("*ERROR: Attachpoint '" .. self.DroneData[droneName].Attachpoint .. "' not a valid bone!", 2)
				return
			end
			
			local location = self:GetPosition(self.DroneData[droneName].Attachpoint)
			local newdrone = CreateUnitHPR(self.DroneData[droneName].UnitID, self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
			
			newdrone:SetParent(self, self.DroneData[droneName].Name)
			newdrone:SetCreator(self)
			self.DroneTable[droneName] = newdrone
			self.DroneData[droneName].Active = newdrone
			self.DroneData[droneName].Docked = false
			self.DroneData[droneName].Damaged = false
			self.DroneData[droneName].BuildProgress = 1
			self.Trash:Add(newdrone)
			self:RequestRefreshUI()
		end
	end,
	
	--Clears all handles and active DroneData variables for the calling drone.
	NotifyOfDroneDeath = function(self,droneName)
		--LOG("Mithy: NotifyOfDroneDeath: " .. droneName)
		self.DroneTable[droneName] = nil
		self.DroneData[droneName].Active = false
		self.DroneData[droneName].Docked = false
		self.DroneData[droneName].Damaged = false
		self.DroneData[droneName].BuildProgress = 0
	end,



	--+ Drone Maintenance/Reconstruction +--

	DroneMaintenanceState = State {
		Main = function(self)
			self.DroneMaintenance = true			
			--Resume any interrupted drone rebuilds
			if self.BuildingDrone then
				ChangeState(self, self.DroneRebuildingState)
			end			
			--Check for dead or damaged drones
			while self and not self.Dead and not self.BuildingDrone do
			
				for droneName, droneData in self.DroneData do
				
					if not droneData.Active or (droneData.Active and droneData.Damaged and droneData.Docked) then
						self.BuildingDrone = droneName
						ChangeState(self, self.DroneRebuildingState)
					end
				end
				WaitTicks(2)
			end
		end,

		OnPaused = function(self)
			ChangeState(self, self.PausedState)
		end,
	},
	
	--Active construction/repair state - consumes resources and advances progress
	DroneRebuildingState = State {
		Main = function(self)
			--Flag as repair if drone is alive and damaged
			local isRepair = self.DroneData[self.BuildingDrone].Active and self.DroneData[self.BuildingDrone].Damaged
			--Calculate build time from buildrate
			local buildTimeSeconds = self.DroneData[self.BuildingDrone].Economy.BuildTime / self.BuildRate
			--Enable econ consumption
			self:EnableResourceConsumption(self.DroneData[self.BuildingDrone].Economy)
			
			--Begin or resume construction if not repair
			if not isRepair then
				self:CreateDroneEffects(self.DroneData[self.BuildingDrone].Attachpoint)
				--Set progress bar/variable to 0 for fresh drone construction
				if not self.DroneData[self.BuildingDrone].BuildProgress then
					self:SetWorkProgress(0.01)
				end
				--Construction runs until buildprogress >= 1
				while self and not self.Dead
				and self.DroneData[self.BuildingDrone].BuildProgress < 1 do
					WaitTicks(1)
					local tickprogress = (self:GetResourceConsumed() * 0.1) / buildTimeSeconds
					self.DroneData[self.BuildingDrone].BuildProgress = self.DroneData[self.BuildingDrone].BuildProgress + tickprogress
					self:SetWorkProgress(self.DroneData[self.BuildingDrone].BuildProgress)
				end
				self:CreateDrone(self.BuildingDrone)
			--Otherwise begin repair
			elseif isRepair then
			
				self:CreateDroneEffects(self.DroneData[self.BuildingDrone].Docked)
				local repairingDrone = self.DroneData[self.BuildingDrone].Active
				local maxhealth = repairingDrone:GetMaxHealth()
				
				--Repair runs while drone is alive, damaged, and docked
				while self and not self.Dead and self.DroneData[self.BuildingDrone].Damaged	and self.DroneData[self.BuildingDrone].Docked
				and repairingDrone and not repairingDrone.Dead do
				
					WaitTicks(1)
					
					local restorehealth = ((self:GetResourceConsumed() * 0.1) / buildTimeSeconds) * maxhealth
					
					repairingDrone:AdjustHealth(self, restorehealth)
					
					--Repair progress = drone health percent, and the progressbar reflects this
					local totalprogress = repairingDrone:GetHealth() / maxhealth
					
					self:SetWorkProgress(totalprogress)
					
					if totalprogress >= 1 and not repairingDrone.Dead then
						self.DroneData[self.BuildingDrone].Damaged = false
					end
				end
			end
			--Return to Maintenance State to check/wait for other jobs
			self:CleanupDroneMaintenance(self.BuildingDrone)
			ChangeState(self, self.DroneMaintenanceState)
		end,
		
		OnPaused = function(self)
			ChangeState(self, self.PausedState)
		end,
	},
	
	--Paused state, econ and construction progress halted
	PausedState = State {
		Main = function(self)
			self:CleanupDroneEffects()
			self:DisableResourceConsumption()
			self.DroneMaintenance = false
		end,

		OnUnpaused = function(self)
			ChangeState(self, self.DroneMaintenanceState)
		end,		
	},
	
	--Set on unit death, ends production and consumption immediately
	DeadState = State {
		Main = function(self)
			self:CleanupDroneMaintenance(nil, true)
		end,		
	},
	
	
	--Enables economy drain
	EnableResourceConsumption = function(self, econdata)
		local energy_rate = econdata.BuildCostEnergy / (econdata.BuildTime / self.BuildRate)
		local mass_rate = econdata.BuildCostMass / (econdata.BuildTime / self.BuildRate)
		self:SetConsumptionPerSecondEnergy(energy_rate)
		self:SetConsumptionPerSecondMass(mass_rate)
		self:SetConsumptionActive(true)
	end,

	--Disables economy drain
	DisableResourceConsumption = function(self)
		self:SetConsumptionPerSecondEnergy(0)
		self:SetConsumptionPerSecondMass(0)
		self:SetConsumptionActive(false)
	end,
	
	--Resets resume/progress data, clears effects
	--Used to clean up finished construction and repair, and to interrupt repairs when undocking
	CleanupDroneMaintenance = function(self, droneName, deadState)
		if deadState or (droneName and droneName == self.BuildingDrone) then
			self:SetWorkProgress(0)
			self.BuildingDrone = false
			self:CleanupDroneEffects()
			self:DisableResourceConsumption()
		end
	end,

    CreateDroneEffects = function(self, bone)

    end,

	CleanupDroneEffects = function(self)
		#if self.BuildEffectsBag and not table.empty(self.BuildEffectsBag) then
		#	self.BuildEffectsBag:Destroy()
		#end
	end,


	--+ Drone Assist Management
	
	--Manages drone assistance and firestate propagation
	AssistHeartBeat = function(self)
		local SuspendAssist = 0
		local LastFireState
		local LastDroneTarget
		--The Goliath's current weapon target is now used for better, earlier drone deployment
		--Best results achieved so far have been with the missile launcher, due to range
		local TargetWeapon = self:GetWeaponByLabel('Laser')
		
		while not self.Dead do
			--Refresh current firestate and check for holdfire
			local MyFireState = self:GetFireState()
			local HoldFire = MyFireState == 1
			--De-blip our weapon target, nil MyTarget if none
			local TargetBlip = TargetWeapon:GetCurrentTarget()
			
			if TargetBlip != nil then
				self.MyTarget = self:GetRealTarget(TargetBlip)
			else
				self.MyTarget = nil
			end
			
			--Propagate the Goliath's fire state to the drones, to keep them from retaliating when the Goliath is on hold-fire
			--This also allows you to set both drones to target-ground, although I'm not sure how that'd be useful
			if LastFireState != MyFireState then
				LastFireState = MyFireState
				self:SetDroneFirestate(MyFireState)
			end
			
			--Drone Assist management
			--New target priority:
			--1. Nearby gunships - these can attack both drones and Goliath, otherwise often killing drones while they're elsewise occupied
			--2. Goliath's current target - whatever the missile launcher is shooting at; this also responds to force-attack calls
			--3. Goliath's last drone-targetable attacker - this is only used when something is hitting the Goliath out of launcher range
			--
			--Drones are not re-assigned to a new target unless their old target is dead, or a higher-priority class of target is found.
			--The exception is newly-constructed drones, which are dispatched to the current drone target on the next heartbeat.
			--Acquisition of a gunship target suspends further assist management for 7 heartbeats - with the new logic this is somewhat
			-- vestigial, but it does insure that the drones aren't jerked around between gunship targets if one of them strays slightly
			-- outside the air monitor range.
			--
			--Existing target validity and distance is checked every heartbeat, so we don't get stuck trying to send drones after a
			-- submerged, recently taken-off highaltair, or out-of-range target.  Likewise, when the Goliath submerges, the drones will
			-- continue engaging only until the last assigned target is destroyed, at which point they will dock with the underwater Goliath.
			if self.DroneAssist and not HoldFire and SuspendAssist <= 0 then
				local NewDroneTarget
				
				local GunshipTarget = self:SearchForGunshipTarget(self.AirMonitorRange)
				if GunshipTarget and not GunshipTarget.Dead then
					if GunshipTarget != LastDroneTarget then
						--LOG("Mithy: Heartbeat - DroneAssist: GunshipTarget")
						NewDroneTarget = GunshipTarget
					end
					--[[
				elseif self.MyTarget != nil and not self.MyTarget:IsDead() then
					if self.MyTarget != LastDroneTarget then
						--LOG("Mithy: Heartbeat - DroneAssist: MyTarget")
						NewDroneTarget = self.MyTarget
					end
					]]--
				elseif self.MyAttacker != nil and not self.MyAttacker.Dead and self:IsTargetInRange(self.MyAttacker) then
					if self.MyAttacker != LastDroneTarget then
						--LOG("Mithy: Heartbeat - DroneAssist: MyAttacker")
						NewDroneTarget = self.MyAttacker
					end
				--If our previous attacker is no longer valid, clear MyAttacker to re-enable the OnDamage check
				elseif self.MyAttacker != nil then
					--LOG("Mithy: Heartbeat - DroneAssist: MyAttacker = nil")
					self.MyAttacker = nil
				end
				
				--Assign chosen target, if valid
				if NewDroneTarget and self:IsValidDroneTarget(NewDroneTarget) then
					--LOG("Mithy: Heartbeat - DroneAssist: Assigning New Target")
					if NewDroneTarget == GunshipTarget then
						--Suspend the assist targeting for 7 heartbeats if we have a gunship target, to keep them at top priority
						SuspendAssist = 7
					end
					LastDroneTarget = NewDroneTarget
					self:AssignDroneTarget(NewDroneTarget)
				--Otherwise re-check our existing target:
				else
					if LastDroneTarget and self:IsValidDroneTarget(LastDroneTarget)
					and self:IsTargetInRange(LastDroneTarget) then
						--Dispatch any docked (usually newly-built) drones, if it's still valid
						if self:GetDronesDocked() then
							self:AssignDroneTarget(LastDroneTarget)
						end
					else
						--Clear last target if no longer valid, forcing re-acquisition on the next beat
						LastDroneTarget = nil
					end
				end
				
			--Otherwise, tick down the assistance suspension timer (if set)
			elseif SuspendAssist > 0 then
				--LOG("Mithy: Heartbeat - SuspendAssist countdown: " .. repr(SuspendAssist))
				SuspendAssist = SuspendAssist - 1
			end --DroneAssist
			
			WaitSeconds(self.HeartBeatInterval)
		end --while not dead
	end, --AssistHeartBeat
			
	--Recalls all drones to the carrier at 2x speed under temp command lockdown
	RecallDrones = function(self)
		if next(self.DroneTable) then
			for id, drone in self.DroneTable do
				drone:DroneRecall()
			end
		end		
	end,
	
	--Issues an attack order for all drones
	AssignDroneTarget = function(self, dronetarget)
		if next(self.DroneTable) then
			for id, drone in self.DroneTable do
				if drone.AwayFromCarrier == false then --now that idle, docked drones are auto-reassigned, we only want to command released drones
					local targetblip = dronetarget:GetBlip(self:GetArmy())
					if targetblip != nil then
						IssueClearCommands({drone})
						IssueAttack({drone}, targetblip) --send drones after unit's recon blip, if we can see it
					else
						--LOG("Mithy: AssignDroneTarget - Failure: Target blip not visible")
					end
				end
			end
		end
	end,
	
	--Sets a firestate for all drones
	SetDroneFirestate = function(self, firestate)
		if next(self.DroneTable) then
			for id, drone in self.DroneTable do
				if drone and not drone:IsDead() then
					drone:SetFireState(firestate)
				end
			end
		end
	end,
	
	--Checks whether any drones are docked.  Used by AssistHeartBeat.
	--Returns a table of dronenames that are currently docked, or false if none
	GetDronesDocked = function(self)
		local docked = {}
		if next(self.DroneTable) then
			for id, drone in self.DroneTable do
				if drone and not drone:IsDead() and self.DroneData[id].Docked then
					table.insert(docked, id)
				end
			end
		end
		if next(docked) then
			return docked
		else
			return false
		end
	end,

	--Returns a hostile gunship/transport in range for drone targeting, or nil if none
	SearchForGunshipTarget = function(self, radius)
		local targetindex, target
		local units = self:GetAIBrain():GetUnitsAroundPoint(categories.AIR - (categories.UNTARGETABLE), self:GetPosition(), radius, 'Enemy')
		if next(units) then
			targetindex, target = next(units)
		end
		return target
	end,
	
	--De-blip a weapon target - stolen from the GC tractorclaw script
	GetRealTarget = function(self, target)
		if target and not IsUnit(target) then
			local unitTarget = target:GetSource()
			local unitPos = unitTarget:GetPosition()
			local reconPos = target:GetPosition()
			local dist = VDist2(unitPos[1], unitPos[3], reconPos[1], reconPos[3])
			if dist < 5 then
				return unitTarget
			end
		end
		return target	  
	end,
	
	--Runs a potential target through filters to insure that drones can attack it; checks are as simple and efficient as possible
	IsValidDroneTarget = function(self, target)
		local ivdt
		if target != nil --target still exists!
		--and IsUnit(target) != nil --is a unit
		and target.Dead != nil --is a unit
		and not target.Dead --isn't dead
		and IsEnemy(self:GetArmy(), target:GetArmy()) --is hostile
		and not EntityCategoryContains(categories.UNTARGETABLE, target) --is not a bomber/interceptor or otherwise untargetable
		and target:GetCurrentLayer() != 'Sub' --is not submerged
		and target:GetBlip(self:GetArmy()) != nil then --has a recon blip we can see
			ivdt = true
		end
		return ivdt
	end,
	
	--Insures that potential retaliation targets are within drone control range
	IsTargetInRange = function(self, target)
		local tpos = target:GetPosition()
		local mpos = self:GetPosition()
		local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
		local itir
		if dist <= self.AssistRange then
			itir = true
		end
		return itir
	end,



	--+ Destruction Effects +--


	DestructionEffectBones = {
		'Left_Arm_Muzzle',
	},
	
	
	CreateDamageEffects = function(self, bone, army )
        for k, v in EffectTemplate.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(3.0)
        end
    end,

	CreateExplosionDebris = function( self, bone, Army )
	
		local CreateAttachedEmitter = CreateAttachedEmitter
		
		for k, v in EffectTemplate.ExplosionEffectsSml01 do
			CreateAttachedEmitter( self, bone, Army, v ):ScaleEmitter(2.0)
		end
	end,
	
	CreateDeathExplosionDustRing = function( self )
        local blanketSides = 18
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2.8

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)

            local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 1.5, blanketZ + 4, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end        
    end,

	CreateAmmoCookOff = function( self, Army, bones, yBoneOffset )
		### Fire plume effects
		local basePosition = self:GetPosition()
		for k, vBone in bones do
			local position = self:GetPosition(vBone)
			local offset = utilities.GetDifferenceVector( position, basePosition )
			velocity = utilities.GetDirectionVector( position, basePosition ) 
			velocity.x = velocity.x + GetRandomFloat(-0.45, 0.45)
			velocity.z = velocity.z + GetRandomFloat(-0.45, 0.45)
			velocity.y = velocity.y + GetRandomFloat( 0.0, 0.65)

			### Ammo Cookoff projectiles and damage
			self.DamageData = {
				BallisticArc = 'RULEUBA_LowArc',
				UseGravity = true, 
				CollideFriendly = true, 
				DamageFriendly = true, 
				Damage = 500,
				DamageRadius = 3,
				DoTPulses = 15,
				DoTTime = 2.5, 
				DamageType = 'Normal',
				} 
			ammocookoff = self:CreateProjectile('/mods/BlackOpsUnleashed/projectiles/NapalmProjectile01/Napalm01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
			### SetVelocity controls how far away the ammo will be thrown
			ammocookoff:SetVelocity(Random(2,5))  
			ammocookoff:SetLifetime(20) 
			ammocookoff:PassDamageData(self.DamageData)
			self.Trash:Add(ammocookoff)
		end
	end,
	
	CreateGroundPlumeConvectionEffects = function(self,army)
    for k, v in EffectTemplate.TNukeGroundConvectionEffects01 do
          CreateEmitterAtEntity(self, army, v ) 
    end
    
    local sides = 10
    local angle = (2*math.pi) / sides
    local inner_lower_limit = 2
        local outer_lower_limit = 2
        local outer_upper_limit = 2
    
    local inner_lower_height = 1
    local inner_upper_height = 3
    local outer_lower_height = 2
    local outer_upper_height = 3
      
    sides = 8
    angle = (2*math.pi) / sides
    for i = 0, (sides-1)
    do
        local magnitude = RandomFloat(outer_lower_limit, outer_upper_limit)
        local x = math.sin(i*angle+RandomFloat(-angle/2, angle/4)) * magnitude
        local z = math.cos(i*angle+RandomFloat(-angle/2, angle/4)) * magnitude
        local velocity = RandomFloat( 1, 3 ) * 3
        self:CreateProjectile('/effects/entities/UEFNukeEffect05/UEFNukeEffect05_proj.bp', x, RandomFloat(outer_lower_height, outer_upper_height), z, x, 0, z)
            :SetVelocity(x * velocity, 0, z * velocity)
    end 
    end,
	
	CreateInitialFireballSmokeRing = function(self)
        local sides = 12
        local angle = (2*math.pi) / sides
        local velocity = 5
        local OffsetMod = 8       

        for i = 0, (sides-1) do
            local X = math.sin(i*angle)
            local Z = math.cos(i*angle)
            self:CreateProjectile('/effects/entities/UEFNukeShockwave01/UEFNukeShockwave01_proj.bp', X * OffsetMod , 1.5, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity):SetAcceleration(-0.5)
        end   
    end,  
    
    CreateOuterRingWaveSmokeRing = function(self)
        local sides = 32
        local angle = (2*math.pi) / sides
        local velocity = 7
        local OffsetMod = 8
        local projectiles = {}

        for i = 0, (sides-1) do
            local X = math.sin(i*angle)
            local Z = math.cos(i*angle)
            local proj =  self:CreateProjectile('/effects/entities/UEFNukeShockwave02/UEFNukeShockwave02_proj.bp', X * OffsetMod , 2.5, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity)
            table.insert( projectiles, proj )
        end  
        
        WaitSeconds( 3 )

        # Slow projectiles down to normal speed
        for k, v in projectiles do
            v:SetAcceleration(-0.45)
        end         
    end,      
    
    CreateFlavorPlumes = function(self)
        local numProjectiles = 8
        local angle = (2*math.pi) / numProjectiles
        local angleInitial = RandomFloat( 0, angle )
        local angleVariation = angle * 0.75
        local projectiles = {}

        local xVec = 0 
        local yVec = 0
        local zVec = 0
        local velocity = 0

        # yVec -0.2, requires 2 initial velocity to start
        # yVec 0.3, requires 3 initial velocity to start
        # yVec 1.8, requires 8.5 initial velocity to start

        # Launch projectiles at semi-random angles away from the sphere, with enough
        # initial velocity to escape sphere core
        for i = 0, (numProjectiles -1) do
            xVec = math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))
            yVec = RandomFloat(0.2, 1)
            zVec = math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation)) 
            velocity = 3.4 + (yVec * RandomFloat(2,5))
            table.insert(projectiles, self:CreateProjectile('/effects/entities/UEFNukeFlavorPlume01/UEFNukeFlavorPlume01_proj.bp', 0, 0, 0, xVec, yVec, zVec):SetVelocity(velocity) )
        end

        WaitSeconds( 3 )

        # Slow projectiles down to normal speed
        for k, v in projectiles do
            v:SetVelocity(2):SetBallisticAcceleration(-0.15)
        end
    end,
	
	CreateHeadConvectionSpinners = function(self)
        local sides = 8
        local angle = (2*math.pi) / sides
        local HeightOffset = 0
        local velocity = 1
        local OffsetMod = 10
        local projectiles = {}        

        for i = 0, (sides-1) do
            local x = math.sin(i*angle) * OffsetMod
            local z = math.cos(i*angle) * OffsetMod
            local proj = self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/GoliathNukeEffect03/GoliathNukeEffect03_proj.bp', x, HeightOffset, z, x, 0, z)
                :SetVelocity(velocity)
            table.insert(projectiles, proj)
        end   
    
    WaitSeconds(1)
        for i = 0, (sides-1) do
            local x = math.sin(i*angle)
            local z = math.cos(i*angle)
            local proj = projectiles[i+1]
		proj:SetVelocityAlign(false)
		proj:SetOrientation(OrientFromDir(utilities.Cross( Vector(x,0,z), Vector(0,1,0))),true)
		proj:SetVelocity(0,3,0) 
          proj:SetBallisticAcceleration(-0.05)            
        end   
    end,
	
	
	DeathThread = function( self, overkillRatio , instigator)
	
		local army = self:GetArmy()
        local position = self:GetPosition()
		local numExplosions =  math.floor( table.getn( self.DestructionEffectBones ) * Random(0.4, 1.0))
		self:PlayUnitSound('Destroyed')
		# Create small explosions effects all over
		local ranBone = utilities.GetRandomInt( 1, numExplosions )
		CreateDeathExplosion( self, 'Torso', 6)
        CreateAttachedEmitter(self, 'Torso', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):OffsetEmitter( 0, 0, 0 )
		self:ShakeCamera(20, 2, 1, 1)
		WaitSeconds(3)
		explosion.CreateDefaultHitExplosionAtBone( self, 'Torso', 5.0 )
		WaitSeconds(1)
		explosion.CreateDefaultHitExplosionAtBone( self, 'Missile_Hatch_B', 5.0 )
		self:CreateDamageEffects( 'Missile_Hatch_B', army )
		self:ShakeCamera(20, 2, 1, 1.5)
		WaitSeconds(1)
		CreateDeathExplosion( self, 'Left_Arm_Extra', 1.0 )
		WaitSeconds(0.5)
		CreateDeathExplosion( self, 'Left_Arm_Muzzle', 1.0 )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Left_Arm_Pitch', 1.0 )
		self:CreateDamageEffects( 'Left_Arm_Pitch', army )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Left_Leg_B', 1.0 )
		self:CreateDamageEffects( 'Left_Leg_B', army )
		WaitSeconds(0.6)
		CreateDeathExplosion( self, 'Right_Arm_Extra', 1.0 )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		CreateDeathExplosion( self, 'Left_Arm_Yaw', 1.0 )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Right_Leg_B', 1.0 )
		WaitSeconds(1)
		CreateDeathExplosion( self, 'Pelvis', 1.0 )
		CreateDeathExplosion( self, 'Beam_Barrel', 1.0 )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Head', 1.0 )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		WaitSeconds(0.5)
		CreateDeathExplosion( self, 'AttachSpecial01', 1.0 )
		self:CreateDamageEffects( 'AttachSpecial01', army )
		WaitSeconds(0.3)
		CreateDeathExplosion( self, 'TMD_Turret', 1.0 )
		self:CreateDamageEffects( 'TMD_Turret', army )
		WaitSeconds(0.3)
		CreateDeathExplosion( self, 'Left_Leg_C', 1.0 )
		self:CreateDamageEffects( 'Left_Leg_C', army )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'L_FootFall', 1.0 )
		CreateDeathExplosion( self, 'Left_Foot', 1.0 )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		WaitSeconds(0.1)
		CreateDeathExplosion( self, 'Right_Foot', 1.0 )
		WaitSeconds(0.7)
		CreateDeathExplosion( self, 'Beam_Turret', 2.0 )
		self:CreateDamageEffects( 'Beam_Turret', army )
		self:CreateDamageEffects( 'Right_Arm_Extra', army )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		WaitSeconds(0.7)
		CreateDeathExplosion( self, 'Torso', 1.0 )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Right_Leg_B', 1.0 )
		self:CreateDamageEffects( 'Right_Leg_B', army )
		WaitSeconds(0.4)
		CreateDeathExplosion( self, 'Right_Arm_Pitch', 1.0 )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		--self:CreateAmmoCookOff( self:GetArmy(), {ranBone}, Random(0,2) )
		self:CreateDamageEffects( 'Right_Arm_Pitch', army )
		WaitSeconds(2)
		
		local x, y, z = unpack(self:GetPosition())
        z = z + 3
        -- Knockdown force rings
        
		
        -- Create initial fireball dome effect
		--CreateLightParticle(self, -1, self:GetArmy(), 50, 100, 'beam_white_01', 'ramp_blue_16')
		CreateLightParticle(self, -1, army, 35, 4, 'glow_02', 'ramp_red_02')
        WaitSeconds(0.25)
        CreateLightParticle(self, -1, army, 80, 20, 'glow_03', 'ramp_fire_06')
		self:PlayUnitSound('NukeExplosion')
        local FireballDomeYOffset = -7
        self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/GoliathNukeEffect01/GoliathNukeEffect01_proj.bp',0,FireballDomeYOffset,0,0,0,1)
        local PlumeEffectYOffset = 1
        self:CreateProjectile('/effects/entities/UEFNukeEffect02/UEFNukeEffect02_proj.bp',0,PlumeEffectYOffset,0,0,0,1) 
		DamageRing(self, position, 0.1, 18, 1, 'Force', true)
        WaitSeconds(0.8)
        DamageRing(self, position, 0.1, 18, 1, 'Force', true)
		local bp = self:GetBlueprint()
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'GoliathDeathNuck') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end
		
		for k, v in EffectTemplate.TNukeRings01 do
			CreateEmitterAtEntity(self, army, v )
        end
        
        self:CreateInitialFireballSmokeRing()
        self:ForkThread(self.CreateOuterRingWaveSmokeRing)
        self:ForkThread(self.CreateHeadConvectionSpinners)
        self:ForkThread(self.CreateFlavorPlumes)
		
		CreateLightParticle(self, -1, army, 200, 150, 'glow_03', 'ramp_nuke_04')
		WaitSeconds( 1 )
		WaitSeconds(0.1)
		--self:CreateFireBalls()
		WaitSeconds(0.1)
		--self:CreateFireBalls()
		WaitSeconds(0.5)
		--self:CreateFireBalls()
		WaitSeconds(0.2)
		--self:CreateFireBalls()
		WaitSeconds(0.5)
		--self:CreateFireBalls()
		WaitSeconds(0.5)
		self:CreateGroundPlumeConvectionEffects(army)
		
		local army = self:GetArmy()
        CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), 'nuke_scorch_003_albedo', '', 'Albedo', 40, 40, 500, 0, army)
		
		--self:CreateHeadConvectionSpinners()
        
        self:CreateWreckage(0.1)
        self:Destroy()
		
	end,
	
	
}

TypeClass = BEL0402