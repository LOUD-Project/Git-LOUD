
local CMassFabricationUnit = import('/lua/cybranunits.lua').CMassFabricationUnit

URB1303 = Class(CMassFabricationUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        CMassFabricationUnit.OnStopBeingBuilt(self,builder,layer)
        self.Rotator = CreateRotator(self, 'Spinner', 'z')
        self.Rotator:SetAccel(10)
        self.Rotator:SetTargetSpeed(30)
        self.Trash:Add(self.Rotator)
    end,

    OnProductionUnpaused = function(self)
        CMassFabricationUnit.OnProductionUnpaused(self)
        self.Rotator:SetTargetSpeed(30)
    end,

    OnProductionPaused = function(self)
        CMassFabricationUnit.OnProductionPaused(self)
        self.Rotator:SetTargetSpeed(0)
    end,
}

TypeClass = URB1303