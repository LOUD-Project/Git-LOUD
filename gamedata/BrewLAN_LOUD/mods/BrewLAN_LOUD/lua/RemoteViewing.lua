--------------------------------------------------------------------------------
-- Seraphim Optics Tracking Facility script.
-- Spererate from the units actual script for reasons.
--------------------------------------------------------------------------------
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

function RemoteViewing(SuperClass)
    return Class(SuperClass) {

        OnCreate = function(self)
            SuperClass.OnCreate(self)
            self.RemoteViewingData = {}
            --self.RemoteViewingData.RemoteViewingFunctions = {}
            self.RemoteViewingData.DisableCounter = 0
            self.RemoteViewingData.IntelButton = true
			
            -- makes sure all scrying buttons are visible. sometimes they don't become visible by themselves.
            self.Sync.Abilities = self:GetBlueprint().Abilities --# dont use self:EnableRemoteViewingButtons()
            self.Sync.Abilities.TargetLocation.Active = true
            
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

            local aiBrain = self:GetAIBrain()
            local drain = self:GetBlueprint().Economy.InitialRemoteViewingEnergyDrain
            
			if not ( aiBrain:GetEconomyStored('ENERGY') > drain ) then
				FloatingEntityText( self.Sync.id, "Insufficient Energy Storage")
				return
			end
            
			-- Drain economy here
			aiBrain:TakeResource( 'ENERGY', drain )
            
            if self:AntiTeleportCheck( aiBrain, location) then
                return
            end

            --LOG("*AI DEBUG BEFORE creation data is "..repr(self.RemoteViewingData))

            -- find a target unit 
            local targettable = aiBrain:GetUnitsAroundPoint(categories.SELECTABLE, location, 10)
            local targetunit = targettable[1]

            if table.getn(targettable) > 1 then

                local dist = 100

                for i, target in targettable do    

                    if IsUnit(target) then

                        local cdist = VDist2Sq(target:GetPosition()[1], target:GetPosition()[3], location[1], location[3])

                        if cdist < dist then
                            dist = cdist
                            targetunit = target
                        end
                    end
                end   
            end

            if targetunit and IsUnit(targetunit) then
                
                self.RemoteViewingData.VisibleLocation = location
                self.RemoteViewingData.TargetUnit = targetunit
                
                self:CreateVisibleEntity()
            end
        end,

        CreateVisibleEntity = function(self)

            local bp = self:GetBlueprint()
            local aiBrain = self:GetAIBrain()
            
            if not self.RemoteViewingData.Satellite then
                self:SetMaintenanceConsumptionInactive()
            end

            if not self.RemoteViewingData.TargetUnit then
                return
            end
            
            if self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton then

                if not self.RemoteViewingData.Satellite or self.RemoteViewingData.Satellite:BeenDestroyed() then  

                    self:SetMaintenanceConsumptionActive()

                    local spec = {
                        X = self.RemoteViewingData.VisibleLocation[1],
                        Z = self.RemoteViewingData.VisibleLocation[3],
                        Radius = bp.Intel.RemoteViewingRadius or 26,
                        LifeTime = bp.Intel.RemoteViewingLifetime or 90,
                        Omni = false,
                        Radar = false,
                        Vision = true,
                        Army = self:GetAIBrain():GetArmyIndex(),
                    }

                    self.RemoteViewingData.Satellite = VizMarker(spec)   
                    self.RemoteViewingData.Satellite:AttachTo(self.RemoteViewingData.TargetUnit, -1)

                    self.Trash:Add(self.RemoteViewingData.Satellite)

                else

                    self:SetMaintenanceConsumptionActive()

                    Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )

                    self.RemoteViewingData.Satellite:DetachFrom()
                    self.RemoteViewingData.Satellite:AttachTo(self.RemoteViewingData.TargetUnit, -1)
                    self.RemoteViewingData.Satellite:EnableIntel('Vision')
                end

                -- monitor resources
                if self.RemoteViewingData.ResourceThread then
                    self.RemoteViewingData.ResourceThread:Destroy()
                end

                self.RemoteViewingData.ResourceThread = self:ForkThread(self.DisableResourceMonitor)
				
                -- start the cooldown period before allowing target to be moved again
				if bp.Intel.Cooldown and bp.Intel.Cooldown > 0 then
                    self.CooldownThread = self:ForkThread(self.Cooldown, bp.Intel.Cooldown)
                    self.Trash:Add(self.CooldownThread)
                end

                LOG("*AI DEBUG After creation data is "..repr(self.RemoteViewingData))

            else
                LOG("*AI DEBUG Cannot create visible entity - counter "..repr(self.RemoteViewingData))
            end
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
	
        DisableVisibleEntity = function(self)

            -- visible entity already off
            if self.RemoteViewingData.DisableCounter > 1 then return end

            -- disable vis entity and monitor resources
            if not self.Dead and self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:DisableIntel('Vision')
            end
        end,

        OnIntelEnabled = function(self, intel)

            -- Make sure the button is only calculated once rather than once per possible intel type
            if not self.RemoteViewingData.IntelButton then

                self.Sync.Abilities = self:GetBlueprint().Abilities
                self.Sync.Abilities.TargetLocation.Active = true
                self.RemoteViewingData.IntelButton = true

                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1

            end

            SuperClass.OnIntelEnabled(self,intel)
            
            if not self.RemoteViewingData.Satellite then
                self:SetMaintenanceConsumptionInactive()
            end

        end,

        OnIntelDisabled = function(self, intel)

            if self.RemoteViewingData.Satellite and not self.RemoteViewingData.Satellite:BeenDestroyed() then
                
                self.RemoteViewingData.Satellite:Destroy()
                self.RemoteViewingData.Satellite = nil   
                self.RemoteViewingData.TargetUnit = nil
                self.RemoteViewingData.VisibleLocation = nil
            end
            
            if self.RemoteViewingData.ResourceThread then
                KillThread(self.RemoteViewingData.ResourceThread)
                self.RemoteViewingData.ResourceThread = nil
            end

            -- make sure button is only calculated once rather than once per possible intel type
            if self.RemoteViewingData.IntelButton then

                self.Sync.Abilities = self:GetBlueprint().Abilities
                self.Sync.Abilities.TargetLocation.Active = false
                self.RemoteViewingData.IntelButton = false

                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1

            end

            SuperClass.OnIntelDisabled(self, intel)

        end,

        DisableResourceMonitor = function(self)

            local aiBrain = self:GetAIBrain()

            WaitSeconds(0.5)

            local fraction = self:GetResourceConsumed()

            while fraction == 1 and (not self.RemoteViewingData.Satellite:BeenDestroyed())  do

                if self:AntiTeleportCheck( aiBrain, self.RemoteViewingData.Satellite:GetPosition() ) then
                    break
                end

                WaitSeconds(0.5)

                fraction = self:GetResourceConsumed()
            end
            
            if self.RemoteViewingData.Satellite and not self.RemoteViewingData.Satellite:BeenDestroyed() then

                self.RemoteViewingData.Satellite:Destroy()
                self.RemoteViewingData.Satellite = nil
                self.RemoteViewingData.TargetUnit = nil
                self.RemoteViewingData.VisibleLocation = nil
                
                LOG("*AI DEBUG Satellite Dies "..repr(self.RemoteViewingData))
            end

            self:SetMaintenanceConsumptionInactive()

            if self.RemoteViewingData.IntelButton then
            
                if self.RemoteViewingData.ResourceThread then
                    KillThread(self.RemoteViewingData.ResourceThread)
                    self.RemoteViewingData.ResourceThread = nil
                end

            end
            

            
        end,

    }    
end
