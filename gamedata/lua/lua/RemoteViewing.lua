---  /lua/RemoteViewing.lua
---  Author(s):  Dru Staltman
---  Summary  :  File that creates in units ability to create Remote Entities

local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local WaitTicks = coroutine.yield

-- TODO: make sure each new instance is using a previous metatable
function RemoteViewing(SuperClass)

    local RemoteViewingDebug = false

    return Class(SuperClass) {
	
        OnCreate = function(self)
		
            SuperClass.OnCreate(self)
			
            self.RemoteViewingData = {
                Abilities               = self:GetBlueprint().Abilities,

                Intel                   = self:GetBlueprint().Intel,

                DisableCounter          = 0,
                PendingVisibleLocation  = false,
                Satellite               = false,
                VisibleLocation         = false,
            }

        end,

        OnStopBeingBuilt = function(self,builder,layer)

            self.Sync.Abilities = self.RemoteViewingData.Abilities            
            self.Sync.Abilities.TargetLocation.Active = true

            self.RechargeThread = self:ForkThread( self.RechargeEmitter )

            SuperClass.OnStopBeingBuilt(self,builder,layer)
        end,

        OnKilled = function(self, instigator, type, overkillRatio)
        
            if self.RechargeThread then
                KillThread(self.RechargeThread)
            end

            SuperClass.OnKilled(self, instigator, type, overkillRatio)

            if self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:DisableIntel('Vision')
                self.RemoteViewingData.Satellite:Destroy()
            end

        end,
        
        DisableRemoteViewingButtons = function(self)

            self.Sync.Abilities = self.RemoteViewingData.Abilities
            self.Sync.Abilities.TargetLocation.Active = false

        end,
        
        EnableRemoteViewingButtons = function(self)

            self.Sync.Abilities = self.RemoteViewingData.Abilities
            self.Sync.Abilities.TargetLocation.Active = true

        end,

        OnTargetLocation = function(self, location)

            -- if there already is a location just change it
            if self.RemoteViewingData.PendingVisibleLocation then
                self.RemoteViewingData.PendingVisibleLocation = location
            else
                -- set the location and begin to process the target
                self.RemoteViewingData.PendingVisibleLocation = location
                self:ForkThread(self.TargetLocationThread)
            end
        end,

        TargetLocationThread = function(self)
        
            if RemoteViewingDebug then
                LOG("*AI DEBUG Target Location Thread")
            end

            self:RequestRefreshUI()

            self.RemoteViewingData.VisibleLocation = self.RemoteViewingData.PendingVisibleLocation
            self.RemoteViewingData.PendingVisibleLocation = nil

            self:CreateVisibleEntity()

        end,
        
        AntiTeleportBlock = function( self, aiBrain, location )

			for num, brain in ArmyBrains do
		
				local unitList = brain:GetListOfUnits(categories.ANTITELEPORT, false, true)
				local location = self.RemoteViewingData.VisibleLocation
			
				for i, unit in unitList do

					--	if it's an ally, then we skip.
					if not IsEnemy(self.Army, unit.Army) then 
						continue
					end
				
					local noTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
					local atposition = unit:GetPosition()

					local targetdestdistance = VDist2(location[1], location[3], atposition[1], atposition[3])

					-- if the antiteleport range covers the targetlocation
					if noTeleDistance and noTeleDistance > targetdestdistance then

						FloatingEntityText(self.EntityID,'Remote Viewing Destination Scrambled')

                        self.RemoteViewingData.PendingVisibleLocation = false
						self.RemoteViewingData.VisibleLocation = false

						-- play audio warning
						if GetFocusArmy() == self.Army then

							local Voice = Sound {Bank = 'XGG', Cue = 'XGG_Computer_CV01_04765',}
							local Brain = self:GetAIBrain()

							ForkThread(Brain.PlayVOSound, Brain, Voice, 'RemoteViewingFailed')
						end						
						
						return true
					end
				end

			end	

            return false
            
        end,
        

        CreateVisibleEntity = function(self)
		
			local VisibilityEntityWillBeCreated = (self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0)

            if RemoteViewingDebug then        
                LOG("*AI DEBUG CreateVisibleEntity "..repr(VisibilityEntityWillBeCreated) )
			end
            
            -- Only give a visible area if we have a location and intel button enabled
            if not self.RemoteViewingData.VisibleLocation then
                return
            end
			
			-- here is where we would drop in a function to defeat remote viewing (ie - antiteleport)
			-- essentially costing the user the energy but remote entity fails to materialize
			-- this code taken from Black Ops
            if RemoteViewingDebug then
                LOG("*AI DEBUG Checking for AntiRemoteViewing")
            end
            
            VisibleEntityWillBeCreated = self:AntiTeleportBlock( self:GetAIBrain(), self.RemoteViewingData.VisibleLocation )
            
            if VisibilityEntityWillBeCreated then

                -- Create new visible entity
                if not self.RemoteViewingData.Satellite then

                    local spec = {
                        X = self.RemoteViewingData.VisibleLocation[1],
                        Z = self.RemoteViewingData.VisibleLocation[3],

                        Radius      = self.RemoteViewingData.Intel.RemoteViewingRadius or 26,
                        LifeTime    = self.RemoteViewingData.Intel.RemoteViewingLifetime or -1,

                        Omni = false,
                        Radar = false,
                        Vision = true,
                        Army = self:GetAIBrain():GetArmyIndex(),
                    }
                    
                    self.RemoteViewingData.Satellite = VizMarker(spec)
                    
                    -- this functionality is for remoteviewing that attaches to a specific unit
                    -- rather than just at a specific place
                    if self.RemoteViewingData.TargetUnit then
                        self.RemoteViewingData.Satellite:AttachTo(self.RemoteViewingData.TargetUnit, -1)
                    end

                    self.Trash:Add(self.RemoteViewingData.Satellite)

                else

                    -- Move and reactivate old visible area
                    if not self.RemoteViewingData.Satellite:BeenDestroyed() then
                    
                        if RemoteViewingDebug then
                            LOG("*AI DEBUG Moving Existing RemoteViewing Entity and Enabling Vision")
                        end
                        
                        Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )

                        if self.RemoteViewingData.TargetUnit then
                            self.RemoteViewingData.Satellite:DetachFrom()
                            self.RemoteViewingData.Satellite:AttachTo(self.RemoteViewingData.TargetUnit, -1)
                        end

                        self.RemoteViewingData.Satellite:EnableIntel('Vision')
                    end

                end

            end
			
            if VisibilityEntityWillBeCreated then
			
                local bp = self.RemoteViewingData.Intel
				
                -- start the cooldown period before allowing target to be moved again
				if bp.Cooldown and bp.Cooldown > 0 then
   
                    if RemoteViewingDebug then
                        LOG("*AI DEBUG Cooldown Thread "..repr(self.CooldownThread) )
                    end
                   
                    if self.CooldownThread then
                        KillThread(self.CooldownThread)
                    end
                    
                    self.CooldownThread = self:ForkThread(self.Cooldown, bp.Cooldown)
                    self.Trash:Add(self.CooldownThread)
                end
				
				-- start the timer that will auto-shut off the viewing entity
                if bp.Viewtime and bp.Viewtime > 0 then
   
                    if RemoteViewingDebug then
                        LOG("*AI DEBUG Viewtime Thread "..repr(self.ViewtimeThread) )
                    end

                    -- kill any existing thread
                    if self.ViewtimeThread then
                        KillThread(self.ViewtimeThread)
                    end

                    self.ViewtimeThread = self:ForkThread(self.Viewtime, bp.Viewtime)  -- auto-remove view
                    self.Trash:Add(self.ViewtimeThread)
                end
				
				-- grow the viewing radius in steps
                if bp.RemoteViewingRadiusFinal and bp.RemoteViewingRadiusFinal > 0 and bp.RemoteViewingRadiusFinal != bp.RemoteViewingRadius then
   
                    if RemoteViewingDebug then
                        LOG("*AI DEBUG ViewingRadius Thread "..repr(self.ViewingRadiusThread) )
                    end
				
                    if self.ViewingRadiusThread then
                        KillThread(self.ViewingRadiusThread)
                    end
                    
                    -- for a growing viewing radius
                    local initRadius = bp.RemoteViewingRadius
                    local finalRadius = bp.RemoteViewingRadiusFinal
                    local step = bp.RadiusGrowStepSize or 0.2
					
                    self.ViewingRadiusThread = self:ForkThread(self.ViewingRadius, initRadius, finalRadius, step)

                    self.Trash:Add(self.ViewingRadiusThread)
                end
                
                self.RechargeThread = self:ForkThread( self.RechargeEmitter )
                
            end
        end,

        DisableVisibleEntity = function(self)

            if RemoteViewingDebug then        
                LOG("*AI DEBUG DisableVisibleEntity")
            end
            
            -- if visible entity already off
            if self.RemoteViewingData.DisableCounter > 1 then
				return
			end
			
            -- disable vision
            if not self:IsDead() and self.RemoteViewingData.Satellite then

                self.RemoteViewingData.Satellite:DisableIntel('Vision')

            end
			
            -- kill any thread that isn't used anymore
            if self.ViewtimeThread then
                KillThread(self.ViewtimeThread)
            end
			
            if self.ViewingRadiusThread then
                KillThread(self.ViewingRadiusThread)
            end
        end,
--[[
        OnIntelEnabled = function(self,intel)

            if RemoteViewingDebug then            
                LOG("*AI DEBUG OnIntelEnabled")
            end

            -- Make sure the button is only calculated once rather than once per possible intel type
            self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1

            self:CreateVisibleEntity()

            SuperClass.OnIntelEnabled(self,intel)
        end,

        OnIntelDisabled = function(self,intel)

            if RemoteViewingDebug then        
                LOG("*AI DEBUG OnIntelDisabled")
            end

            -- make sure button is only calculated once rather than once per possible intel type
            self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1

            self:DisableVisibleEntity()

            SuperClass.OnIntelDisabled(self,intel)
        end,
		
		-- a cooldown period. the vision marker cannot be changed during this period
        Cooldown = function(self, time)

            if time > 0 then
            
                --LOG("*AI DEBUG Cooldown for " .. time*10 )

                self.Sync.Abilities = self.RemoteViewingData.Abilities
                self.Sync.Abilities.TargetLocation.Active = false

                WaitTicks(time * 10)

                self.Sync.Abilities = self.RemoteViewingData.Abilities
                self.Sync.Abilities.TargetLocation.Active = true

            end
        end,
--]]
        -- this function recharges the emitter responsible for creating the viewing entity
        -- the first thing it does is remove the targeting button
        -- by turning this into an EconomyEvent, we no longer need to monitor resources
        -- as the unit will no longer be usable until the charge is complete
        -- at which point the targeting button will re-appear
        RechargeEmitter = function(self)

            self.Sync.Abilities = self.RemoteViewingData.Abilities
            self.Sync.Abilities.TargetLocation.Active = false

            self:RequestRefreshUI()
        
            local chargeEcost   = self.RemoteViewingData.Intel.RemoteViewingEnergyDrain * (self.EnergyMaintAdjMod or 1)
            local chargetime    = self.RemoteViewingData.Intel.ReactivateTime or 15

            local Cost = CreateEconomyEvent(self, chargeEcost, 0, chargetime, self.SetWorkProgress)

            if RemoteViewingDebug then
                LOG("*AI DEBUG RechargeEmitter for " .. chargetime * 10 )
            end
            
            WaitFor(Cost)

            self:SetWorkProgress(0.0)

            RemoveEconomyEvent(self, Cost)

            self.Sync.Abilities = self.RemoteViewingData.Abilities
            self.Sync.Abilities.TargetLocation.Active = true

            self:RequestRefreshUI()
            
            self.RechargeThread = false

            self.RemoteViewingData.DisableCounter = 0

            if RemoteViewingDebug then
                LOG("*AI DEBUG RechargeEmitter complete "..repr(self.Sync.Abilities) )
            end
        end,

        -- an auto disable feature. removes the view after a set period
        Viewtime = function(self, viewtime)

            if viewtime > 0 then

                --LOG("*AI DEBUG ViewTime for " .. viewtime*10 )

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
