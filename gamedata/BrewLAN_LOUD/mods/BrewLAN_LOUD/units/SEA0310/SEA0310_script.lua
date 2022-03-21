--------------------------------------------------------------------------------
--  Summary  :  UEF Decoy Plane Script
--------------------------------------------------------------------------------
local TAirUnit = import('/lua/defaultunits.lua').AirUnit

SEA0310 = Class(TAirUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        TAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionActive()
    end,
}

TypeClass = SEA0310
