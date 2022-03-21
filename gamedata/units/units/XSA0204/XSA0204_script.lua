local SAirUnit = import('/lua/defaultunits.lua').AirUnit
local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SANHeavyCavitationTorpedo = SeraphimWeapons.SANHeavyCavitationTorpedo

XSA0204 = Class(SAirUnit) {

    Weapons = {
	
        Bomb = Class(SANHeavyCavitationTorpedo) {},
		
    },
	
}

TypeClass = XSA0204