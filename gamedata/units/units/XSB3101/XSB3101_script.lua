local SRadarUnit = import('/lua/seraphimunits.lua').SRadarUnit

XSB3101 = Class(SRadarUnit) {

    OnIntelDisabled = function(self)

        SRadarUnit.OnIntelDisabled(self)
        
        self.Rotator1:SetSpinDown(true)
    end,

    OnIntelEnabled = function(self)

        SRadarUnit.OnIntelEnabled(self)
        
        if(not self.Rotator1) then
            self.Rotator1 = CreateRotator(self, 'Array', 'y')
            self.Trash:Add(self.Rotator1)
        end

        self.Rotator1:SetSpinDown(false)
        self.Rotator1:SetTargetSpeed(30)
        self.Rotator1:SetAccel(20)
    end,
}

TypeClass = XSB3101