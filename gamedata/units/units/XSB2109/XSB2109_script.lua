local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local Torpedo = import('/lua/seraphimweapons.lua').SANAnaitTorpedo

XSB2109 = Class(SStructureUnit) {

    Weapons = {
        Turret01 = Class(Torpedo) {},
    },     

}

TypeClass = XSB2109