local SRadarUnit = import('/lua/defaultunits.lua').StructureUnit

local SHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')

SSL0324 = Class(SHoverLandUnit) {

    OnCreate = function(self)

        self.Rotator = CreateRotator(self, 'Array', 'y')
        self.Trash:Add(self.Rotator)

        SHoverLandUnit.OnCreate(self)
    end,

    OnStopBeingBuilt = function(self,builder,layer)

        SHoverLandUnit.OnStopBeingBuilt(self,builder,layer)

        self:SetMaintenanceConsumptionInactive()

        self:SetScriptBit('RULEUTC_IntelToggle', true)

        if RadarRestricted then
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        else
            self:SetScriptBit('RULEUTC_IntelToggle', false)
        end

        self:RequestRefreshUI()
        
    end,

    OnIntelDisabled = function(self,intel)
    
        SRadarUnit.OnIntelDisabled(self,intel)

        self.Rotator:SetTargetSpeed(0)
        self.Rotator:SetAccel(30)
    
    end,

    OnIntelEnabled = function(self,intel)

        SRadarUnit.OnIntelEnabled(self,intel)

        self.Rotator:SetTargetSpeed(60)
        self.Rotator:SetAccel(30)

    end,

}

TypeClass = SSL0324
