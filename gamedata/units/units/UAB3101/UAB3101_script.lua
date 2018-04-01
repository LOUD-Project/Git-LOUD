
local ARadarUnit = import('/lua/aeonunits.lua').ARadarUnit

UAB3101 = Class(ARadarUnit) {    
    OnIntelDisabled = function(self)
        ARadarUnit.OnIntelDisabled(self)
        self.Rotator1:SetSpinDown(true)
    end,

    OnIntelEnabled = function(self)
        ARadarUnit.OnIntelEnabled(self)
        if not self.Rotator1 then
            self.Rotator1 = CreateRotator(self, 'B01', 'y')
            self.Trash:Add(self.Rotator1)
        end
        self.Rotator1:SetSpinDown(false)
        self.Rotator1:SetTargetSpeed(30)
        self.Rotator1:SetAccel(20)
    end,
}

TypeClass = UAB3101