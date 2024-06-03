local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SDFAireauBolterWeapon = import('/lua/seraphimweapons.lua').SDFAireauBolterWeapon

XSL0202 = Class(SWalkingLandUnit) {
    Weapons = {
        MainGun = Class(SDFAireauBolterWeapon) {}
    },
}
TypeClass = XSL0202