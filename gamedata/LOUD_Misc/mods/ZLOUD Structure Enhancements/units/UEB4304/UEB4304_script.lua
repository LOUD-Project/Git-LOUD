local TRadarJammerUnit = import('/lua/terranunits.lua').TRadarJammerUnit

UEB4304 = Class(TRadarJammerUnit) {

    IntelEffects = {
		{
			Bones = {'UEB4203'},
			Offset = {0,0,3},
			Type = 'Jammer01',
		},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TRadarJammerUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
		
        self:DisableUnitIntel('CloakField')	-- this unit doesn't actually do cloaking --

    end,
	
}

TypeClass = UEB4304
