local SLandFactoryUnit = import('/lua/seraphimunits.lua').SLandFactoryUnit

XSB0101 = Class(SLandFactoryUnit) {

    OnCreate = function(self)
	
        SLandFactoryUnit.OnCreate(self)
		
        self.Rotator1 = CreateRotator(self, 'Pod01', 'y', nil, 5, 0, 0)
		
        self.Trash:Add(self.Rotator1)
		
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        self.Rotator1:SetSpeed(0)
        SLandFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
		
    end,

}

TypeClass = XSB0101