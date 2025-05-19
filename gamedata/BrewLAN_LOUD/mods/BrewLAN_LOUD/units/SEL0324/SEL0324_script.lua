local TLandUnit     = import('/lua/defaultunits.lua').MobileUnit

local TSAMLauncher  = import('/lua/terranweapons.lua').TSAMLauncher

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')

SEL0324 = Class(TLandUnit) {

    Weapons = {
        MissileRack01 = Class(TSAMLauncher) {},
    },

    OnCreate = function(self)
        TLandUnit.OnCreate(self)
    end,

    OnStopBeingBuilt = function(self, builder, layer)

        TLandUnit.OnStopBeingBuilt(self, builder, layer)

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

        self.mount      = CreateRotator(self, 'Satellite', 'x', 0, 15, 0)
        self.dish       = CreateRotator(self, 'Dish', 'z', 0, 30, 0)
        self.dish2      = CreateRotator(self, 'Dish', 'y', nil, 0, 15, 90)

        local rotate = 30

        while not self.Dead do

            if not self.Loaded then

                if self.Intel then

                    rotate = rotate * -1

                    self.mount:SetGoal(rotate - 20)
                    self.dish:SetGoal(rotate)
                    self.dish2:SetSpinDown(false)

                else

                    self.mount:SetGoal(-20)
                    self.dish:SetGoal(0)
                    self.dish2:SetSpinDown(true)

                end

                WaitFor(self.mount)

            end

            coroutine.yield(Random(3,16))
        end

    end,

    OnIntelEnabled = function(self,intel)

        TLandUnit.OnIntelEnabled(self,intel)

        self.Intel = true

    end,

    OnIntelDisabled = function(self,intel)

        TLandUnit.OnIntelDisabled(self,intel)

        self.Intel = false

    end,

    TransportAnimation = function(self, rate)

        TLandUnit.TransportAnimation(self, rate)

        -- loading
        if not self.Loaded then
        
            -- and intel is On
            if self.Intel then
            
                self.mount:SetGoal(-20)
                self.dish:SetGoal(0)
                self.dish2:SetSpinDown(true)
            
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

TypeClass = SEL0324
