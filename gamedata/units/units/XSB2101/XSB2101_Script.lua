local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SDFOhCannon = import('/lua/seraphimweapons.lua').SDFOhCannon

XSB2101 = Class(SStructureUnit) {
    Weapons = {
        MainGun = Class(SDFOhCannon) {},
    },
}
TypeClass = XSB2101