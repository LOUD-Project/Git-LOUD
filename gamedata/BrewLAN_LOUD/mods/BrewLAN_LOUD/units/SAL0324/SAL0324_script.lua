local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')

SAL0324 = Class(ALandUnit) {

    OnStopBeingBuilt = function(self, builder, layer)

        ALandUnit.OnStopBeingBuilt(self, builder, layer)

        self:SetMaintenanceConsumptionInactive()

        self:SetScriptBit('RULEUTC_IntelToggle', true)

        if RadarRestricted then
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        else

            self:SetScriptBit('RULEUTC_IntelToggle', false)

            self:ForkThread(self.RadarThread)
        end

        self.RadarRadius = self:GetIntelRadius('Radar')
        self.OmniRadius = self:GetIntelRadius('Omni')
   
        self:RequestRefreshUI()
    end,

    RadarThread = function(self)

        self.dish      = CreateRotator(self, 'Dish', 'y', 0, 16.5, 0)
        
        local rotate = 65

        while not self.Dead do
        
            if not self.Loaded then

                if self:IsIntelEnabled('Omni') then
                
                    rotate = rotate * -1

                    self.dish:SetGoal( rotate )

                else

                    self.dish:SetGoal(0)

                end

                WaitFor(self.dish)
                
            end

            coroutine.yield(Random(11, 31))
        end
    end,

    OnIntelEnabled = function(self,intel)

        ALandUnit.OnIntelEnabled(self,intel)
        
        self.Intel = true

    end,

    OnIntelDisabled = function(self,intel)

        ALandUnit.OnIntelDisabled(self,intel)

        self.Intel = false
    end,

    TransportAnimation = function(self, rate)

        ALandUnit.TransportAnimation(self, rate)

        -- loading
        if not self.Loaded then
        
            -- and intel is On
            if self.Intel then
            
                self.dish:SetGoal(0)
            
                self:SetIntelRadius('Radar', 0)
                self:SetIntelRadius('Omni', 0)
            
            end
            
            self.Loaded = true
            
        else
        
            -- unloading

            self:SetIntelRadius('Radar', self.RadarRadius)
            self:SetIntelRadius('Omni', self.OmniRadius)
            
            self.Loaded = nil
        
        end

    end,

}

TypeClass = SAL0324
