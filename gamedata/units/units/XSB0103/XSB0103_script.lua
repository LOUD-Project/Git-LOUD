local SSeaFactoryUnit = import('/lua/seraphimunits.lua').SSeaFactoryUnit

XSB0103 = Class(SSeaFactoryUnit) {
    OnCreate = function(self)
        SSeaFactoryUnit.OnCreate(self)
        self.Rotator1 = CreateRotator(self, 'Pod01', 'y', nil, 3, 0, 0)
        self.Trash:Add(self.Rotator1)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self.Rotator1:SetSpeed(0)
        SSeaFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

}

TypeClass = XSB0103
