local SLandUnit = import('/lua/seraphimunits.lua').SLandUnit

local SDFOhCannon = import('/lua/seraphimweapons.lua').SDFOhCannon

XSL0201 = Class(SLandUnit) {
    Weapons = {
        MainGun = Class(SDFOhCannon) {}
    },
}
TypeClass = XSL0201
