#****************************************************************************
#**  File     :  /lua/unit.lua
#**  Author(s):  John Comes, David Tomandl, Gordon Duclos
#**  Edited by Domino 
#**  Summary  : The Unit lua module
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 

local AvailableToggles =  __DMSI.Custom_Toggles()

local Game = import('/lua/game.lua')

local oldUnit = Unit

Unit = Class(oldUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
	
		oldUnit.OnStopBeingBuilt(self,builder,layer)

		self.Usages = {	Energy = {},Mass = {},BuildRate = {},}
		
		local UnitBp = self:GetBlueprint()
		local BpToggles = self:GetBlueprint().General.ExtraCaps or false
		local BpAbilities = self:GetBlueprint().Abilities or false

		if BpToggles and table.getsize(BpToggles) > 0 then
		
			for Cap, Param in BpToggles do
			
				if string.sub(Cap,1,8) == 'RULEETC_' and AvailableToggles[Cap] then
				
					if Param then 
						self:AddExtraCap(Cap)
					end
					
				end
				
			end
			
		end
		
		if self:GetArmy() == GetFocusArmy() and UnitBp.Categories then
		
			if table.find(UnitBp.Categories, 'HOLOGRAM') or table.find(UnitBp.Categories, 'PASSTHROUGH') then
			
				if UnitBp.OldHitBoxSize then 
					self:ForkThread(self.CreateUnitHitBox)
				end
				
			end
			
		end
		
		if not self.Sync.Abilities and BpAbilities and table.getsize(BpAbilities) > 0 then
		
			self.Sync.Abilities = BpAbilities
			
		end

		self:RequestRefreshUI()
		
    end,
	
	CreateUnitHitBox = function(self)	

		local bp = self:GetBlueprint()
		local scale = bp.Display.UniformScale or 1
		
		self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, bp.CollisionOffsetY or 0, bp.CollisionOffsetZ or 0, bp.OldHitBoxSize.SizeX * scale, bp.OldHitBoxSize.SizeY  * scale, bp.OldHitBoxSize.SizeZ  * scale)
		
	end,


	############
    ## MOTION
    ############
	
	create_crator = function(self)
		--> call with this --> self:ForkThread(self.create_crator)
		
		local x, y, z = unpack(self:GetPosition())
		
		local DeformTerrain = { artilery = { radiusI = 2, radiusO = 2, Depth = 1.5,	mound = 0.5	},	}

		import('/mods/domino_mod_support/lua/deform/deformterrain.lua').Deform(x, z, DeformTerrain)
	
	end,
	
	GetMotionStatus = function(self)
	
		if self.MotionStatus.new then 
			return self.MotionStatus.new
		else
			return false
		end
	end, 
	
	GetOldMotionStatus = function(self)
	
		if self.MotionStatus.old then 
			return self.MotionStatus.old
		else
			return false
		end
	end, 
	
	GetIsSelected = function(self)
	
		if self.IsSelected then 
			return true
		else
			return false
		end
	end,
	
	#################
    ## TRANSFER UNIT
    #################

	Transferre_Unit = function(self, Newunit, Layer)
		
		# B E F O R E
	    local bp = self:GetBlueprint()
        local unitId = self:GetEntityId()
		local bpUnit = self:GetBlueprint().BlueprintId
		local bpToggles = { self:GetBlueprint().General.ToggleCaps }
		local bpExtraToggles = { self:GetBlueprint().General.ExtraToggleCaps }
		local loc = self:GetPosition()
		local ori = self:GetOrientation()
		local firestate = self:GetFireState()
		local layer = Layer or self:GetCurrentLayer()
        local numNukes = self:GetNukeSiloAmmoCount()
        local numTacMsl = self:GetTacticalSiloAmmoCount()
        local unitKills = self:GetStat('KILLS', 0).Value
        local unitHealth = self:GetHealth()
        local shieldIsOn = false
        local ShieldHealth = 0
        local hasFuel = false
        local fuelRatio = 0
        local enh = {}
		local EnabledToggles = {}
		local ExtraToggles = {}
		local Guards = self:GetGuards() 
		local Rallypoint = false
		local TheTarget = self:GetMyRealTarget()

		if EntityCategoryContains(categories.CONSTRUCTION, self) and EntityCategoryContains(categories.FACTORY, self) and EntityCategoryContains(categories.RALLYPOINT, self) then
			Rallypoint = self:GetRallyPoint()
		end
		
        if self.MyShield then
            shieldIsOn = self:ShieldIsOn()
            ShieldHealth = self.MyShield:GetHealth()
        end
		 		
        if bp.Physics.FuelUseTime and bp.Physics.FuelUseTime > 0 then  
            fuelRatio = self:GetFuelRatio() 
            hasFuel = true
        end
		
        local posblEnh = bp.Enhancements
        if posblEnh then
            for k,v in posblEnh do
                if self:HasEnhancement( k ) then
                   table.insert( enh, k )
                end
            end
        end
		
		if bpToggles then
			for k,v in bpToggles do
				if self:GetScriptBit(k) == false then
					table.insert( EnabledToggles, k)
				end
			end
		end

		#-- A F T E R

		--Create the new unit.
		local newunit = CreateUnit(Newunit, self:GetArmy(), loc[1], loc[2], loc[3], ori[1], ori[2], ori[3], ori[4], layer)																	
		local nubp = newunit:GetBlueprint()

		if Rallypoint then 
			IssueFactoryRallyPoint( { newunit }, Rallypoint)
			newunit.Rallypoint = Rallypoint
		end
		
        if unitKills and unitKills > 0 then
            newunit:AddKills( unitKills )
        end
		
        if enh and table.getn(enh) > 0 then
            for k, v in enh do
                newunit:CreateEnhancement( v )
            end
        end
		
		if EnabledToggles and table.getn(EnabledToggles) > 0 then
			for k,v in EnabledToggles do
				newunit:SetScriptBit(v, false)
			end
		end
        
		newunit:SetFireState(firestate)
		newunit:SetHealth(newunit, unitHealth)
		
        if hasFuel and nubp.Physics.FuelUseTime and nubp.Physics.FuelUseTime > 0 then
            newunit:SetFuelRatio(fuelRatio)
        end
		
        if numNukes and numNukes > 0 then
            newunit:GiveNukeSiloAmmo(numNukes)
        end
		
        if numTacMsl and numTacMsl > 0 then
            newunit:GiveTacticalSiloAmmo(numTacMsl)
        end
		
        if newunit.MyShield then
            newunit.MyShield:SetHealth(newunit, ShieldHealth)
            if shieldIsOn then
                newunit:EnableShield()
            else
                newunit:DisableShield()
            end
        end
		
		if table.getn(Guards) > 0 then
			IssueGuard(Guards, newunit)
		end

		if TheTarget then 
			IssueAttack({ newunit }, TheTarget)

			self:Destroy()		
			newunit = nil
		else
			self:Destroy()						
			newunit = nil
		end
    end,

	GetMyRealTarget = function(self)
	
		local HasATarget = false
		local MyRealTarget
		local numWep = self:GetWeaponCount()
		
		if numWep == 1 then 
			local wep = self:GetWeapon(1)
			if wep:GetCurrentTarget() then
				HasATarget = true
				MyRealTarget = wep:GetCurrentTarget()
			end   
		end
		
		if numWep > 1 then 
			for w = 1, numWep do
				local wep = self:GetWeapon(w)
				if wep:GetCurrentTarget() then
					HasATarget = true
					MyRealTarget = wep:GetCurrentTarget()
				end   
			end                         
		end

		if HasATarget then 
			return MyRealTarget
		else 
			return false
		end
		
	end,	
	
	###########
    ## Economy
    ###########
	
	Get_Econ = function(self, what)
	
		local aiBrain = GetArmyBrain(self:GetArmy())
		local value = false
		
		local Econ = {
						MassTrend = aiBrain:GetEconomyTrend('MASS'),
						EnergyTrend = aiBrain:GetEconomyTrend('ENERGY'),
						
						MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS'),
						EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY'),
						
						EnergyIncome = aiBrain:GetEconomyIncome('ENERGY'),
						MassIncome = aiBrain:GetEconomyIncome('MASS'),
						
						EnergyUsage = aiBrain:GetEconomyUsage('ENERGY'),
						MassUsage = aiBrain:GetEconomyUsage('MASS'),
						
						EnergyRequested = aiBrain:GetEconomyRequested('ENERGY'),
						MassRequested = aiBrain:GetEconomyRequested('MASS'),
						
						EnergyStorage = aiBrain:GetEconomyStored('ENERGY'),
						MassStorage = aiBrain:GetEconomyStored('MASS'),
					}
					
		if Econ[what] then 
			value = Econ[what]
		end
		
		return value
	end, 
	
	
	############
    ## Energy
    ############
	
	AddEnergyUsage = function(self, key, amount)
	
		local ValidEntry = true
		if not key then 
			WARN('AddEnergyUsage --> No key specified')
			ValidEntry = false
		elseif not amount then 
			WARN('AddEnergyUsage --> No amount specified')
			ValidEntry = false
		end
		
		if ValidEntry then 
			local Entry = { amount = amount, enabled = true }
			self.Usages.Energy[key] = Entry
			self:SetMaintenanceConsumptionActive()
		end
		
	end,
	
	RemoveEnergyUsage = function(self, key)
	
		local ValidEntry = true
		
		if not key then 
			WARN('RemoveEnergyUsage --> No key specified')
			ValidEntry = false
		elseif not self.Usages.Energy[key] then 
			WARN('RemoveEnergyUsage --> No energy usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 			
			self.Usages.Energy[key] = nil
			self:SetMaintenanceConsumptionActive()
		end
	end, 
	
	SetEnergyUsage = function(self, key, amount)
	
		local ValidEntry = true
		if not key then 
			WARN('SetEnergyUsage --> No key specified')
			ValidEntry = false
		elseif not amount then 
			WARN('SetEnergyUsage --> No amount specified')
			ValidEntry = false
		elseif not self.Usages.Energy[key] then 
			WARN('SetEnergyUsage --> No energy usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 
			self.Usages.Energy[key].amount = amount
			self:SetMaintenanceConsumptionActive()
		end
	end,
	
	SetEnergyUsageActive = function(self, key)
	
		local ValidEntry = true
		if not key then 
			WARN('SetEnergyUsageActive --> No key specified')
			ValidEntry = false
		elseif not self.Usages.Energy[key] then 
			WARN('SetEnergyUsageActive --> No energy usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 
			self.Usages.Energy[key].enabled = true
			self:SetMaintenanceConsumptionActive()
		end
	end,
	
	SetEnergyUsageInActive = function(self, key)
	
		local ValidEntry = true
		if not key then 
			WARN('SetEnergyUsageInActive --> No key specified')
			ValidEntry = false
		elseif not self.Usages.Energy[key] then 
			WARN('SetEnergyUsageInActive --> No energy usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 
			self.Usages.Energy[key].enabled = false
			self:SetMaintenanceConsumptionActive()
		end
	end,
	
	GetEnergyUsage = function(self, key)
	
		local ValidEntry = true
		if not key then 
			ValidEntry = false
		elseif not self.Usages.Energy[key] then 
			return false
		end
		
		if ValidEntry then 
			return self.Usages.Energy[key].amount
		else
			return 0
		end
	end,
	
	GetTotalEnergyUsage = function(self)
	
		local mai_energy = 0
			
		if self.Usages and table.getsize(self.Usages.Energy) > 0 then 
			for id, entry in self.Usages.Energy do
				local Usage = entry.amount
				if entry.enabled then 
					mai_energy = mai_energy + Usage
				end
			end
		end
		return mai_energy
	end,
	
	#########
    ## Mass
    #########
	
	AddMassUsage = function(self, key, amount)
		local ValidEntry = true
		if not key then 
			WARN('AddMassUsage --> No key specified')
			ValidEntry = false
		elseif not amount then 
			WARN('AddMassUsage --> No amount specified')
			ValidEntry = false
		end
		
		if ValidEntry then 
			local Entry = { amount = amount, enabled = true }
			self.Usages.Mass[key] = Entry
			self:SetMaintenanceConsumptionActive()
		end
		
	end,
	
	RemoveMassUsage = function(self, key)
		local ValidEntry = true
		if not key then 
			WARN('RemoveMassUsage --> No key specified')
			ValidEntry = false
		elseif not self.Usages.Mass[key] then 
			WARN('RemoveMassUsage --> No Mass usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 			
			self.Usages.Mass[key] = nil
			self:SetMaintenanceConsumptionActive()
		end
	end, 
	
	SetMassUsage = function(self, key, amount)
		local ValidEntry = true
		if not key then 
			WARN('SetMassUsage --> No key specified')
			ValidEntry = false
		elseif not amount then 
			WARN('SetMassUsage --> No amount specified')
			ValidEntry = false
		elseif not self.Usages.Mass[key] then 
			WARN('SetMassUsage --> No Mass usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 
			self.Usages.Mass[key].amount = amount
			self:SetMaintenanceConsumptionActive()
		end
	end,
	
	SetMassUsageActive = function(self, key)
		local ValidEntry = true
		if not key then 
			WARN('SetMassUsageActive --> No key specified')
			ValidEntry = false
		elseif not self.Usages.Mass[key] then 
			WARN('SetMassUsageActive --> No Mass usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 
			self.Usages.Mass[key].enabled = true
			self:SetMaintenanceConsumptionActive()
		end
	end,
	
	SetMassUsageInActive = function(self, key)
		local ValidEntry = true
		if not key then 
			WARN('SetMassUsageInActive --> No key specified')
			ValidEntry = false
		elseif not self.Usages.Mass[key] then 
			WARN('SetMassUsageInActive --> No Mass usage entry named ' .. key)
			ValidEntry = false
		end
		
		if ValidEntry then 
			self.Usages.Mass[key].enabled = false
			self:SetMaintenanceConsumptionActive()
		end
	end,
	
	GetMassUsage = function(self, key)
		local ValidEntry = true
		if not key then 
			ValidEntry = false
		elseif not self.Usages.Mass[key] then 
			return false
		end
		
		if ValidEntry then 
			return self.Usages.Mass[key].amount
		else
			return 0
		end
	end,
	
	GetTotalMassUsage = function(self)
		local mai_Mass = 0

		if self.Usages and table.getsize(self.Usages.Mass) > 0 then 
			for id, entry in self.Usages.Mass do
				local Usage = entry.amount
				if entry.enabled then 
					mai_Mass = mai_Mass + Usage
				end
			end
		end
		
		return mai_Mass
	end,
	

	-----------------------------------------------------------------------------------------
	--Thanks to furyofthestars for this function.. slightly modified.
	UpdateConsumptionValues = function(self)
	
		local energy_rate = 0
		local mass_rate = 0
		
		--FotS: CBFP v4 had a change in this function which I have (unfortunately) destructively
		--hooked.  I've copy/pasted that change here to ensure this mod doesn't break that.
		--Start CBFP v4 copy/paste
		
		--added by brute51 - to make sure we use the proper consumption values. [132]
		if self.ActiveConsumption then
		
			local focus = self:GetFocusUnit()
			
			if focus and self.WorkItem and self.WorkProgress < 1 and (focus:IsUnitState('Enhancing') or focus:IsUnitState('Building')) then
			
				self.WorkItem = focus.WorkItem    --set our workitem to the focus unit work item, is specific for enhancing
				
			end
			
		end
		
		--FotS: End CBFP v4 copy/paste
		local myBlueprint = self:GetBlueprint()


		local build_rate = 0
		
		if not self.Dead then

			if self.ActiveConsumption then

				local focus = self:GetFocusUnit()
				
				local time = 1
				local mass = 0
				local energy = 0
			
				-- if the unit is enhancing (as opposed to upgrading ie. - commander, subcommander)
				if self.WorkItem then
				
					time, energy, mass = Game.GetConstructEconomyModel(self, self.WorkItem)
				
				-- if the unit is assisting something that is building ammo
				elseif focus and focus:IsUnitState('SiloBuildingAmmo') then
				
					--GPG: If building silo ammo; create the energy and mass costs based on build rate
					--of the silo against the build rate of the assisting unit
					time, energy, mass = focus:GetBuildCosts(focus.SiloProjectile)

					local siloBuildRate = focus:GetBuildRate() or 1
					
					energy = (energy / siloBuildRate) * (self:GetBuildRate() or 1)
					mass = (mass / siloBuildRate) * (self:GetBuildRate() or 1)
				
				-- if the unit is upgrading or assisting an upgrade, or repairing something
				elseif focus then
				
					--GPG: bonuses are already factored in by GetBuildCosts
					time, energy, mass = self:GetBuildCosts(focus:GetBlueprint())
					
				end
			
				energy = energy * (self.EnergyBuildAdjMod or 1)
				
				if energy < 1 then
				
					energy = 0
					
				end
			
				mass = mass * (self.MassBuildAdjMod or 1)
			
				if mass < .1 then
				
					mass = 0
					
				end

				energy_rate = energy / time
				mass_rate = mass / time
				
				-- LOUD -- add in the specific -- but possibly seperate -- active costs
				if myBlueprint.Economy.ActiveConsumptionPerSecondEnergy or myBlueprint.Economy.ActiveConsumptionPerSecondMass then
					
					energy_rate = energy_rate + (myBlueprint.Economy.ActiveConsumptionPerSecondEnergy or 0)
					mass_rate = mass_rate + (myBlueprint.Economy.ActiveConsumptionPerSecondMass or 0)
					
				end
				
			end

			if self.MaintenanceConsumption then
			
				local mai_energy = (self.EnergyMaintenanceConsumptionOverride or myBlueprint.Economy.MaintenanceConsumptionPerSecondEnergy) or 0
				local mai_mass = (self.MassMaintenanceConsumptionOverride or myBlueprint.Economy.MaintenanceConsumptionPerSecondMass) or 0
			
				--add our custom usages.
				mai_energy = mai_energy + self:GetTotalEnergyUsage()
				mai_mass = mai_mass + self:GetTotalMassUsage()

				--GPG: apply bonuses
				mai_energy = mai_energy * (100 + (self.EnergyModifier or 0)) * (self.EnergyMaintAdjMod or 1) * 0.01
				mai_mass = mai_mass * (100 + (self.MassModifier or 0)) * (self.MassMaintAdjMod or 1) * 0.01

				energy_rate = energy_rate + mai_energy
				mass_rate = mass_rate + mai_mass
			end

			--GPG: apply minimum rates
			energy_rate = math.max(energy_rate, myBlueprint.Economy.MinConsumptionPerSecondEnergy or 0)
			mass_rate = math.max(mass_rate, myBlueprint.Economy.MinConsumptionPerSecondMass or 0)

		end
		
		self:SetConsumptionPerSecondEnergy(energy_rate)
		self:SetConsumptionPerSecondMass(mass_rate)

		if (energy_rate > 0) or (mass_rate > 0) then
		
			self:SetConsumptionActive(true)
			
		else
		
			self:SetConsumptionActive(false)
			
		end
		
	end,
	
}
