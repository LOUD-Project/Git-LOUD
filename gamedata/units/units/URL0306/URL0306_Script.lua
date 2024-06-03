local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CRadarJammerUnit = import('/lua/defaultunits.lua').RadarJammerUnit

URL0306 = Class(CLandUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionActive()
    end,
    
    IntelEffects = {
		{Bones = {'AttachPoint'},Offset = {0,0.1,0},Scale = 0.3,Type = 'Jammer01' },
    },
    
    OnIntelEnabled = function(self,intel)
	
        CRadarJammerUnit.OnIntelEnabled(self,intel)

    end,

    OnIntelDisabled = function(self,intel)
	
        CRadarJammerUnit.OnIntelDisabled(self,intel)
		
    end,    
    
}

TypeClass = URL0306