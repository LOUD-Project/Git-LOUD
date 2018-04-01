local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SANHeavyCavitationTorpedo = SeraphimWeapons.SANHeavyCavitationTorpedo

XSA0204 = Class(SAirUnit) {

    Weapons = {
	
        Bomb = Class(SANHeavyCavitationTorpedo) {},
		
    },
	
}

TypeClass = XSA0204