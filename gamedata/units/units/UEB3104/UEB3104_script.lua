local TRadarUnit = import('/lua/defaultunits.lua').RadarUnit

UEB3104 = Class(TRadarUnit) {

    OnIntelDisabled = function(self)
        TRadarUnit.OnIntelDisabled(self)
        self.UpperRotator:SetTargetSpeed(0)
        self.LowerRotator:SetTargetSpeed(0)
    end,


    OnIntelEnabled = function(self)
        TRadarUnit.OnIntelEnabled(self)
        if not self.UpperRotator then
            self.UpperRotator = CreateRotator(self, 'Upper_Array', 'z')
            self.Trash:Add(self.UpperRotator)
            self.UpperRotator:SetAccel(5)
        end
        self.UpperRotator:SetTargetSpeed(10)
        
        if not self.LowerRotator then
            self.LowerRotator = CreateRotator(self, 'Lower_Array_Detail', 'z')
            self.Trash:Add(self.LowerRotator)
            self.LowerRotator:SetAccel(5)
        end
        self.LowerRotator:SetTargetSpeed(-10)
    end,
}

TypeClass = UEB3104