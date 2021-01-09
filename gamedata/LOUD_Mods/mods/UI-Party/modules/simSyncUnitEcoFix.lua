
function Invoke()
	local a, b = pcall(function()
--		local x = GetUnitById(1)
--		local f = x:GetFocusUnit()
		--if f then 
--			LOG(EntityCategoryContains(categories.SILO, x))
		--end
	--LOG(x:GetConsumptionPerSecondMass())
----		 LOG(x:GetBuildCosts(x.SiloProjectile))
----		 LOG(x:GetBuildRate())
--		 LOG(x.SiloProjectile)
--		 LOG("xx")
--		--LOG(x:GetConsumptionPerSecondMass())
--		for k,v in x.SiloProjectile do
--			LOG(k,v)
--		end




--local types = { "Immobile","Moving","Attacking","Guarding","Building","Upgrading","WaitingForTransport","TransportLoading","TransportUnloading","MovingDown","MovingUp","Patrolling","Busy","Attached","BeingReclaimed","Repairing","Diving","Surfacing","Teleporting","Ferrying","WaitForFerry","AssistMoving","PathFinding","ProblemGettingToGoal","NeedToTerminateTask","Capturing","BeingCaptured","Reclaiming","AssistingCommander","Refueling","GuardBusy","ForceSpeedThrough","UnSelectable","DoNotTarget","LandingOnPlatform","CannotFindPlaceToLand","BeingUpgraded","Enhancing","BeingBuilt","NoReclaim","NoCost","BlockCommandQueue","MakingAttackRun","HoldingPattern","SiloBuildingAmmo" }

--for k,v in types do
--	if (last[v] ~= x:IsUnitState(v)) then
--		LOG(v, "changed to", x:IsUnitState(v))
--	end
--end


--_G.last = {}
--for k,v in types do
--	last[v] = x:IsUnitState(v)
--end



--LOG(repr(_G.last))

--INFO:    Immobile
--INFO:    Moving
--INFO:    Attacking
--INFO:    Guarding
--INFO:    Building
--INFO:    Upgrading
--INFO:    WaitingForTransport
--INFO:    TransportLoading
--INFO:    TransportUnloading
--INFO:    MovingDown
--INFO:    MovingUp
--INFO:    Patrolling
--INFO:    Busy
--INFO:    Attached
--INFO:    BeingReclaimed
--INFO:    Repairing
--INFO:    Diving
--INFO:    Surfacing
--INFO:    Teleporting
--INFO:    Ferrying
--INFO:    WaitForFerry
--INFO:    AssistMoving
--INFO:    PathFinding
--INFO:    ProblemGettingToGoal
--INFO:    NeedToTerminateTask
--INFO:    Capturing
--INFO:    BeingCaptured
--INFO:    Reclaiming
--INFO:    AssistingCommander
--INFO:    Refueling
--INFO:    GuardBusy
--INFO:    ForceSpeedThrough
--INFO:    UnSelectable
--INFO:    DoNotTarget
--INFO:    LandingOnPlatform
--INFO:    CannotFindPlaceToLand
--INFO:    BeingUpgraded
--INFO:    Enhancing
--INFO:    BeingBuilt
--INFO:    NoReclaim
--INFO:    NoCost
--INFO:    BlockCommandQueue
--INFO:    MakingAttackRun
--INFO:    HoldingPattern
--INFO:    SiloBuildingAmmo


		Sync.FixedEcoData = {}

		if GetFocusArmy() != -1 then
			local brain = ArmyBrains[GetFocusArmy()]
			local units = brain:GetListOfUnits( categories.ALLUNITS, false)
			for k,unit in units do
--				LOG(unit:GetEconData())
				if not unit:IsDead() then									
				
					local econData = {
						massConsumed = 0,
						energyConsumed = 0,
						--d=unit:GetBlueprint().Description
					}

					local f = unit:GetFocusUnit()
					if f and EntityCategoryContains(categories.SILO, f) and not unit:IsUnitState("Building") then 
						continue;
					else
						econData.massConsumed = unit:GetConsumptionPerSecondMass() * unit:GetResourceConsumed()
						econData.energyConsumed = unit:GetConsumptionPerSecondEnergy() * unit:GetResourceConsumed()
					end
					
					Sync.FixedEcoData[unit:GetEntityId()] = econData
				end
			end
		end
	end)
	
	if not a then 
		LOG("UI PARTY RESULT: ", a, b)   
	end
end

