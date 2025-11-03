local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SANHeavyCavitationTorpedo = import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo

SSA0307 = Class(SAirUnit) {

    Weapons = {
        Torpedo = Class(SANHeavyCavitationTorpedo) {},
    },

}

TypeClass = SSA0307
