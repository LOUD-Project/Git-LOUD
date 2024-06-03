local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SANHeavyCavitationTorpedo = import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo

SSA0106 = Class(SAirUnit) {

    Weapons = {
        Torpedo = Class(SANHeavyCavitationTorpedo) {},
    },
}

TypeClass = SSA0106
