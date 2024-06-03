local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

SEL0324 = Class(TLandUnit) {
    Weapons = {
        MissileRack01 = Class(TSAMLauncher) {},
    },

    OnCreate = function(self)
        TLandUnit.OnCreate(self)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        TLandUnit.OnStopBeingBuilt(self, builder, layer)
        self:ForkThread(self.RadarAnimation)
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_IntelToggle', true)
        self:RequestRefreshUI()
        self.RadarEnabled = false
    end,

    OnIntelEnabled = function(self,intel)

        TLandUnit.OnIntelEnabled(self,intel)

        self.RadarEnabled = true
        self:CreateIdleEffects()
    end,

    OnIntelDisabled = function(self,intel)

        TLandUnit.OnIntelDisabled(self,intel)

        self.RadarEnabled = false
        self:DestroyIdleEffects()
    end,

    RadarAnimation = function(self)

        local manipulator = CreateRotator(self, 'Satellite', 'x')

        manipulator:SetSpeed(10)
        manipulator:SetGoal(30)

        while IsUnit(self) do
            if self.RadarEnabled then
                WaitFor(manipulator)
                manipulator:SetGoal(-45)
                WaitFor(manipulator)
                manipulator:SetGoal(30)
                WaitFor(manipulator)
            else
                WaitTicks(10)
                self:DestroyIdleEffects()
            end
        end
    end,
}

TypeClass = SEL0324
