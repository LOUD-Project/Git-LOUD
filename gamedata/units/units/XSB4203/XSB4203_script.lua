local SRadarJammerUnit = import('/lua/seraphimunits.lua').SRadarJammerUnit

XSB4203 = Class(SRadarJammerUnit) {
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
}

TypeClass = XSB4203