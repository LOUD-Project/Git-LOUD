--****************************************************************************
--**
--**  File     :  /cdimage/units/UAB0301/UAB0301_script.lua
--**  Author(s):  David Tomandl
--**
--**  Summary  :  Aeon Land Factory Tier 3 Script
--**
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local URL0303OLD = URL0303


URL0303 = Class(URL0303OLD) {

    OnStopBeingBuilt = function(self,builder,layer)
        URL0303OLD.OnStopBeingBuilt(self,builder,layer)
        self:DisableShield()
    end,

    SetVeteranLevel = function(self, level)
        CWalkingLandUnit.SetVeteranLevel(self, level)
        if level > 3 then
            if not self.priorLevel or self.priorLevel < 4 then
                self:EnableShield()
                self:AddToggleCap('RULEUTC_ShieldToggle')
                self:SetScriptBit('RULEUTC_ShieldToggle',true)
                self:SetMaintenanceConsumptionActive()
            end
        end
        self.priorLevel = level 
    end,
}

TypeClass = URL0303