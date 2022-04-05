local TRadarJammerUnit = import('/lua/terranunits.lua').TRadarJammerUnit

UEB4203 = Class(TRadarJammerUnit) {

    IntelEffects = {
		{
			Bones = {'UEB4203'},
			Offset = { 0, 0, 3 },
			Type = 'Jammer01',
		},
    },
}

TypeClass = UEB4203