local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SANUallCavitationTorpedo = import('/lua/seraphimweapons.lua').SANUallCavitationTorpedo

XSB2109 = Class(SStructureUnit) {
    Weapons = {
        Turret01 = Class(SANUallCavitationTorpedo) {},
    },     
}
TypeClass = XSB2109