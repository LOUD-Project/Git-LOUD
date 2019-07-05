---  /lua/RemoteViewing.lua
---  Author(s):  Dru Staltman
---  Summary  :  File that creates in units ability to create Remote Entities

local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local WaitTicks = coroutine.yield

-- TODO: make sure each new instance is using a previous metatable
function RemoteViewing(SuperClass)

    return Class(SuperClass) {
	
        OnCreate = function(self)
		
            SuperClass.OnCreate(self)
			
            self.RemoteViewingData = {}
            self.RemoteViewingData.RemoteViewingFunctions = {}
            self.RemoteViewingData.DisableCounter = 0
            self.RemoteViewingData.IntelButton = true
			
            -- makes sure all scrying buttons are visible. sometimes they don't become visible by themselves.
            self.Sync.Abilities = self:GetBlueprint().Abilities --# dont use self:EnableRemoteViewingButtons()
            self.Sync.Abilities.TargetLocation.Active = true
            self:AddToggleCap('RULEUTC_IntelToggle')
        end,

        OnStopBeingBuilt = function(self,builder,layer)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self:SetMaintenanceConsumptionInactive()
            SuperClass.OnStopBeingBuilt(self,builder,layer)
        end,

        OnKilled = function(self, instigator, type, overkillRatio)
            SuperClass.OnKilled(self, instigator, type, overkillRatio)
            if self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:DisableIntel('Vision')
                self.RemoteViewingData.Satellite:Destroy()
            end
            self:SetMaintenanceConsumptionInactive()
        end,
        
        DisableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = false
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        end,
        
        EnableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = true
            self:AddToggleCap('RULEUTC_IntelToggle')
        end,

        OnTargetLocation = function(self, location)
			if self.RemoteViewingData.IntelButton then
			
				-- Initial energy drain here - we drain resources instantly when an eye is relocated (including initial move)
				local aiBrain = self:GetAIBrain()
				local drain = self:GetBlueprint().Economy.InitialRemoteViewingEnergyDrain
				
				if not ( aiBrain:GetEconomyStored('ENERGY') > drain ) then
					FloatingEntityText( self.Sync.id, "Insufficient Energy Storage")
					return
				end
            
				-- Drain economy here
				aiBrain:TakeResource( 'ENERGY', drain )

				self.RemoteViewingData.VisibleLocation = location
				self:CreateVisibleEntity()
			end
        end,

        CreateVisibleEntity = function(self)
		
			local VisibilityEntityWillBeCreated = (self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton)
			
            -- Only give a visible area if we have a location and intel button enabled
            if not self.RemoteViewingData.VisibleLocation then
                self:SetMaintenanceConsumptionInactive()
                return
            end
			
			-- here is where we would drop in a function to defeat remote viewing (ie - antiteleport)
			-- essentially costing the user the energy but remote entity fails to materialize
			-- this code taken from Black Ops
			
			--LOG("*AI DEBUG Checking for AntiRemoteViewing")

			for num, brain in ArmyBrains do
		
				local unitList = brain:GetListOfUnits(categories.ANTITELEPORT, false)
				local location = self.RemoteViewingData.VisibleLocation
			
				for i, unit in unitList do
					--	if it's an ally, then we skip.
					if not IsEnemy(self.Sync.army, unit.Sync.army) then 
						continue
					end
				
					local noTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
					local atposition = unit:GetPosition()

					local targetdestdistance = VDist2(location[1], location[3], atposition[1], atposition[3])

					-- if the antiteleport range covers the targetlocation
					if noTeleDistance and noTeleDistance > targetdestdistance then
						FloatingEntityText(self.Sync.id,'Remote Viewing Destination Scrambled')
						self.RemoteViewingData.VisibleLocation = false
						
						-- play audio warning
						if GetFocusArmy() == self.Sync.army then
							local Voice = Sound {Bank = 'XGG', Cue = 'XGG_Computer_CV01_04765',}
							local Brain = self:GetAIBrain()

							ForkThread(Brain.PlayVOSound, Brain, Voice, 'RemoteViewingFailed')
						end						
						
						return
					end
				end
			end			
            
            if self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton then
			
                local bp = self:GetBlueprint()
                self:SetMaintenanceConsumptionActive()
				
                -- Create new visible area
                if not self.RemoteViewingData.Satellite then
                    local spec = {
                        X = self.RemoteViewingData.VisibleLocation[1],
                        Z = self.RemoteViewingData.VisibleLocation[3],
                        Radius = bp.Intel.RemoteViewingRadius,
                        LifeTime = -1,
                        Omni = false,
                        Radar = false,
                        Vision = true,
                        Army = self:GetAIBrain():GetArmyIndex(),
                    }
                    self.RemoteViewingData.Satellite = VizMarker(spec)
                    self.Trash:Add(self.RemoteViewingData.Satellite)
                else
                    -- Move and reactivate old visible area
                    if not self.RemoteViewingData.Satellite:BeenDestroyed() then
                        Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )
                        self.RemoteViewingData.Satellite:EnableIntel('Vision')
                    end
                end
				
                -- monitor resources
                if self.RemoteViewingData.ResourceThread then
                    self.RemoteViewingData.ResourceThread:Destroy()
                end
				
                self.RemoteViewingData.ResourceThread = self:ForkThread(self.DisableResourceMonitor)
            end
			
            if VisibilityEntityWillBeCreated then
			
                local bp = self:GetBlueprint().Intel
				
                -- start the cooldown period before allowing target to be moved again
				if bp.Cooldown and bp.Cooldown > 0 then
                    self.CooldownThread = self:ForkThread(self.Cooldown, bp.Cooldown)  # cooldown
                    self.Trash:Add(self.CooldownThread)
                end
				
				-- start the timer that will auto-shut off the eye
                if bp.Viewtime and bp.Viewtime > 0 then
                    self.ViewtimeThread = self:ForkThread(self.Viewtime, bp.Viewtime)  # auto-remove view
                    self.Trash:Add(self.ViewtimeThread)
                end
				
				-- grow the viewing radius in steps
                if bp.RemoteViewingRadiusFinal and bp.RemoteViewingRadiusFinal > 0 and bp.RemoteViewingRadiusFinal != bp.RemoteViewingRadius then
				
                    -- for a growing viewing radius
                    local initRadius = bp.RemoteViewingRadius
                    local finalRadius = bp.RemoteViewingRadiusFinal
                    local step = bp.RadiusGrowStepSize or 0.2
					
                    self.ViewingRadiusThread = self:ForkThread(self.ViewingRadius, initRadius, finalRadius, step)
                    self.Trash:Add(self.ViewingRadiusThread)
                end
            end
        end,

        DisableVisibleEntity = function(self)
            -- if visible entity already off
            if self.RemoteViewingData.DisableCounter > 1 then
				return
			end
			
            -- disable vis entity and monitor resources
            if not self:IsDead() and self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:DisableIntel('Vision')
                self:SetMaintenanceConsumptionInactive() #-- remove power consumption while off            
            end
			
            -- kill any thread that isn't used anymore
            if self.ViewtimeThread then
                KillThread(self.ViewtimeThread)
            end
			
            if self.ViewingRadiusThread then
                KillThread(self.ViewingRadiusThread)
            end
        end,

        OnIntelEnabled = function(self)
            -- Make sure the button is only calculated once rather than once per possible intel type
            if not self.RemoteViewingData.IntelButton then
                self.RemoteViewingData.IntelButton = true
                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1
                self:CreateVisibleEntity()
            end
            SuperClass.OnIntelEnabled(self)
        end,

        OnIntelDisabled = function(self)
            -- make sure button is only calculated once rather than once per possible intel type
            if self.RemoteViewingData.IntelButton then
                self.RemoteViewingData.IntelButton = false
                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1
                self:DisableVisibleEntity()

            end
            SuperClass.OnIntelDisabled(self)
        end,

        DisableResourceMonitor = function(self)
            WaitTicks( 5 )
            local fraction = self:GetResourceConsumed()
            while fraction == 1 do
                WaitTicks( 5 )
                fraction = self:GetResourceConsumed()
            end
            if self.RemoteViewingData.IntelButton then
                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1
                self.RemoteViewingData.ResourceThread = self:ForkThread(self.EnableResourceMonitor)
                self:DisableVisibleEntity()
            end
        end,

        EnableResourceMonitor = function(self)
            local recharge = self:GetBlueprint().Intel.ReactivateTime or 10
            WaitTicks( recharge * 10 )
            self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1
            self:CreateVisibleEntity()
        end,
		
		-- a cooldown period. the vision marker cannot be changed during this period
        Cooldown = function(self, time)
            if time > 0 then
                self.Sync.Abilities = self:GetBlueprint().Abilities # dont use self:DisableRemoteViewingButtons(), that introduces a bug when using multiple remote viewing units
                self.Sync.Abilities.TargetLocation.Active = false
                self:RemoveToggleCap('RULEUTC_IntelToggle')
                WaitTicks(time * 10)
                self.Sync.Abilities = self:GetBlueprint().Abilities # dont use self:EnableRemoteViewingButtons()
                self.Sync.Abilities.TargetLocation.Active = true
                self:AddToggleCap('RULEUTC_IntelToggle')
            end
        end,
		
        -- an auto disable feature. removes the view after a set period
        Viewtime = function(self, viewtime)
            if viewtime > 0 then
                WaitTicks(viewtime * 10)
                self:DisableVisibleEntity()
            end
        end,

        -- changes the size of the camera each tick. Should be able to handle growing and shrinking
        ViewingRadius = function(self, initialRadius, endingRadius, step)
		
			local LOUDCEIL = math.ceil
			local LOUDMIN = math.min
			
            local sat = self.RemoteViewingData.Satellite
            local nTicks = LOUDCEIL( (endingRadius - initialRadius) / step )
			
            if initialRadius > endingRadius then
                step = LOUDMIN( step, -step)  -- make sure we get a negative stepsize
                nTicks = -nTicks
            end
			
            sat:SetIntelRadius('vision', initialRadius)
			
            local curRadius = initialRadius
			
            for i=1, nTicks do
                WaitTicks(1)
                if not sat or sat:BeenDestroyed() then return end
                curRadius = curRadius + step
                sat:SetIntelRadius('vision', curRadius)
            end
			
            sat:SetIntelRadius('vision', endingRadius)
        end,
    }    
end