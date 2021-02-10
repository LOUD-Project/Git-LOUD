local CRadarJammerUnit = import('/lua/cybranunits.lua').CRadarJammerUnit

URB4304 = Class(CRadarJammerUnit) {

    IntelEffects = {
		{
			Bones = {'URB4203'},
			Offset = { 0, 0, 4 },
			Type = 'Jammer01',
		},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        CRadarJammerUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
		
        self:DisableUnitIntel('CloakField')	-- this unit doesn't actually do cloaking --

    end,

}

TypeClass = URB4304
