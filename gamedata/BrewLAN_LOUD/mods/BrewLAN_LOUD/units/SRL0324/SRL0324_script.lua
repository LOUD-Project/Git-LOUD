--  Summary:  Cybran Mobile Radar script
--   Author:  Sean 'Balthazar' Wheeldon

local CLandUnit = import('/lua/defaultunits.lua').MobileUnit
local CRadarUnit = import('/lua/defaultunits.lua').RadarUnit

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')

SRL0324 = Class(CLandUnit) {

    OnCreate = function(self)

        CLandUnit.OnCreate(self)

        self.AnimManip = CreateAnimator(self)
        
        self.Trash:Add(self.AnimManip)

        self.Bits = {}

        self.Consumption = 0
    end,

    OnStopBeingBuilt = function(self, ...)

        CLandUnit.OnStopBeingBuilt(self, unpack(arg) )

        self:SetMaintenanceConsumptionInactive()

        if RadarRestricted then

            self:RemoveToggleCap('RULEUTC_IntelToggle')

        else

            self:SetScriptBit('RULEUTC_IntelToggle', false) -- on
            self:SetScriptBit('RULEUTC_CloakToggle', false) -- on

            self.Bits[3] = true
            self.Bits[8] = true
            
            self.Intel = true
            self.Cloaked = true
            
            self.Consumption = 475

            self:SetEnergyMaintenanceConsumptionOverride( self.Consumption )		
            
            self:ForkThread(self.RadarThread)
        end

        -- store the normal intel radii
        self.RadarRadius = self:GetIntelRadius('Radar')
        self.OmniRadius = self:GetIntelRadius('Omni')
   
        self:RequestRefreshUI()	
        
        -- turn on consumption
        self:SetMaintenanceConsumptionActive()

        --ChangeState( self, self.InvisState )
    end,

    RadarThread = function(self)

        self.sensor     = CreateRotator(self, 'Sensor_D001', 'z', 0, 10, 4, 10)   
        self.sensor2    = CreateRotator(self, 'Sensor_D002', 'z', 0, 10, 4, 10)   
        self.sensor3    = CreateRotator(self, 'Sensor_D003', 'z', 0, 10, 4, 10)
        self.tower      = CreateRotator(self, 'Sensor_A', 'z', nil, 0, 18, 36)
        
        self.Trash:Add(self.sensor)
        self.Trash:Add(self.sensor2)
        self.Trash:Add(self.sensor3)

        -- elevate the tower --
        self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationOpen)

        while not self.Dead do
		
            if not self.Loaded then
			
                if self.Intel then

                    WaitFor(self.sensor)
                    self.sensor:SetGoal(math.random(0,45) )
                    
                    WaitFor(self.sensor2)
                    self.sensor2:SetGoal(math.random(0,45) )

                    WaitFor(self.sensor3)
                    self.sensor3:SetGoal(math.random(0,45) )
                    
                    self.tower:SetSpinDown(false)
					
                else
                
                    self.tower:SetSpinDown(true)
                    
                end

            else
            
                self.tower:SetSpinDown(true)
                
            end
			
            WaitTicks(math.random(4,9))
			
        end
		
    end,

    -- turn OFF ability
    OnScriptBitSet = function(self, bit)
    
        if bit == 3 then

            self.Bits[3] = true
 
            self:DisableUnitIntel('Omni')
            self:DisableUnitIntel('Radar')
            
            self.Intel = false
        end
        
        if bit == 8 then

            self.Bits[8] = true            

            self:DisableUnitIntel('Cloak')
            
            self.Cloaked = false
        end

    end,

    -- turn ON ability
    OnScriptBitClear = function(self, bit)
    
        if bit == 3 then
	
            self.Bits[3] = false
            self.Intel = true     

            self:EnableUnitIntel('Omni')
            self:EnableUnitIntel('Radar')

        end
        
        if bit == 8 then

            self.Bits[8] = false
            self.Cloaked = true

            self:EnableUnitIntel('Cloak')

        end

    end,

    OnIntelDisabled = function(self,intel)
        
        if intel == 'Radar' or intel == 'Omni' then

            CRadarUnit.OnIntelDisabled(self,intel)
            
            if intel == 'Radar' then
        
                local bp = self:GetBlueprint()
                self.AnimManip:SetRate(-2)
                self:SetCollisionShape('Box', bp.CollisionOffsetX or 0, bp.CollisionOffsetY or 0, bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 0.5, bp.SizeZ * 0.5 )

                self.Consumption = math.max( 0, self.Consumption - 400 )
                self:SetEnergyMaintenanceConsumptionOverride( self.Consumption )		

                self:SetMaintenanceConsumptionActive()   
            end

            self:SetIntelRadius('Radar', 0)
            self:SetIntelRadius('Omni', 0)
  
        end
        
        if intel == 'Cloak' then

            self.Consumption = math.max( 0, self.Consumption - 75 )
            self:SetEnergyMaintenanceConsumptionOverride( self.Consumption )	

            self:SetMaintenanceConsumptionActive()   
        
        end

    end,

    OnIntelEnabled = function(self,intel)
        
        if (intel == 'Radar' or intel == 'Omni') and self.Intel then

            CRadarUnit.OnIntelEnabled(self,intel)
        
            if intel == 'Radar' then

                local bp = self:GetBlueprint()
                self.AnimManip:SetRate(2)
                self:SetCollisionShape('Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY or 0) * 3, bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 1.5, bp.SizeZ * 0.5 )
            
                self.Consumption = self.Consumption + 400
                self:SetEnergyMaintenanceConsumptionOverride( self.Consumption )	
                self:SetMaintenanceConsumptionActive()
                
            end

            self:SetIntelRadius('Radar', self.RadarRadius)
            self:SetIntelRadius('Omni', self.OmniRadius)
   
        end
        
        if intel == 'Cloak' and self.Cloaked then

            CRadarUnit.OnIntelEnabled(self,intel)

            self.Consumption = math.max( 0, self.Consumption + 75 )
            self:SetEnergyMaintenanceConsumptionOverride( self.Consumption )	
            self:SetMaintenanceConsumptionActive()   
        
        end
		
    end,

    TransportAnimation = function(self, rate)

        CLandUnit.TransportAnimation(self, rate)

        -- loading
        if not self.Loaded then
        
            -- and intel switch is On reduce range to 0
            -- we do this in order to maintain the intel switch status
            if self.Intel then
                
                self:SetIntelRadius('Radar', 0)
                self:SetIntelRadius('Omni', 0)

                -- retract the tower
                local bp = self:GetBlueprint()

                self.AnimManip:SetRate(-2)
                self:SetCollisionShape('Box', bp.CollisionOffsetX or 0, bp.CollisionOffsetY or 0, bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 0.5, bp.SizeZ * 0.5 )

                -- turn off consumption
                self.Consumption = math.max( 0, self.Consumption - 400 )
                self:SetEnergyMaintenanceConsumptionOverride( self.Consumption )		
                self:SetMaintenanceConsumptionActive()   
                
            end
            
            self.Loaded = true
            
        else
        
            -- unloading
            
            -- if the intel switch was On restore the intel range
            if self.Intel then

                local bp = self:GetBlueprint()

                -- restore consumption
                self.Consumption = self.Consumption + 400
                self:SetEnergyMaintenanceConsumptionOverride( self.Consumption )	
                self:SetMaintenanceConsumptionActive()

                -- extend the tower
                self.AnimManip:SetRate(2)
                self:SetCollisionShape('Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY or 0) * 3, bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 1.5, bp.SizeZ * 0.5 )

                self:SetIntelRadius('Radar', self.RadarRadius)
                self:SetIntelRadius('Omni', self.OmniRadius)
          
            end
            
            self.Loaded = nil
        
        end

    end,

    OnMotionHorzEventChange = function(self, new, old)
        
        if new != 'Stopped' then

            self:DisableUnitIntel('Omni')
            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('Cloak')
        
        else
        
            if self.Intel then
            
                self:EnableUnitIntel('Radar')
                self:EnableUnitIntel('Omni')
                
            end
            
            if self.Cloaked then
            
                self:EnableUnitIntel('Cloak')
                
            end
            
        end

        CLandUnit.OnMotionHorzEventChange(self, new, old)
    end,
	
}

TypeClass = SRL0324
