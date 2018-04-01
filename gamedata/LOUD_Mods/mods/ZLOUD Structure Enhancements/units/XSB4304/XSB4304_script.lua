local SRadarJammerUnit = import('/lua/seraphimunits.lua').SRadarJammerUnit

XSB4304 = Class(SRadarJammerUnit) {

    IntelEffects = {
		{
			Bones = {
				'XSB4203',
			},
			Offset = {
				0,
				3.5,
				0,
			},
			Type = 'Jammer01',
		},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        SRadarJammerUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
		
        self:DisableUnitIntel('CloakField')	-- this unit doesn't actually do cloaking --

    end,

}

TypeClass = XSB4304
