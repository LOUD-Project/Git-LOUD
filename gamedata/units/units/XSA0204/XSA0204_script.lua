local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SANHeavyCavitationTorpedo = import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo

XSA0204 = Class(SAirUnit) {

    Weapons = {
        Torpedo = Class(SANHeavyCavitationTorpedo) {},
    },
	
}

TypeClass = XSA0204