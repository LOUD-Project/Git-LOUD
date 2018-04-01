local SSeaFactoryUnit = import('/lua/seraphimunits.lua').SSeaFactoryUnit

XSB0203 = Class(SSeaFactoryUnit) {
    OnCreate = function(self)
        SSeaFactoryUnit.OnCreate(self)
        local bp = self:GetBlueprint()
        self.Rotator1 = CreateRotator(self, 'Pod01', 'y', nil, 3, 0, 0)
        self.Trash:Add(self.Rotator1)

        self.Rotator2 = CreateRotator(self, 'Pod02', 'y', nil, 6, 0, 0)
        self.Trash:Add(self.Rotator2)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self.Rotator1:SetSpeed(0)
        self.Rotator2:SetSpeed(0)
        SSeaFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XSB0203

