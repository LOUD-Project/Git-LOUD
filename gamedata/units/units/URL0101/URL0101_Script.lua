local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit
local Entity = import('/lua/sim/Entity.lua').Entity

URL0101 = Class(CWalkingLandUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        -- entity used for radar
        local bp = self:GetBlueprint()
		
        self.RadarEnt = Entity {}
        self.Trash:Add(self.RadarEnt)
		
        self.RadarEnt:InitIntel(self:GetArmy(), 'Radar', bp.Intel.RadarRadius)
        self.RadarEnt:EnableIntel('Radar')
        self.RadarEnt:AttachBoneTo(-1, self, 0)
		
        --antena spinner
        CreateRotator(self, 'Spinner', 'y', nil, 90, 5, 90)
		
        -- disable the cloak at first
        self:SetMaintenanceConsumptionInactive()
		
        self:SetScriptBit('RULEUTC_CloakToggle', true)
		
        self:RequestRefreshUI()
		
    end,
    
}	

TypeClass = URL0101