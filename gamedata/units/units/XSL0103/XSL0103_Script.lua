local SHoverLandUnit = import('/lua/seraphimunits.lua').SHoverLandUnit

local SIFThunthoCannonWeapon = import('/lua/seraphimweapons.lua').SIFThunthoCannonWeapon

XSL0103 = Class(SHoverLandUnit) {
    Weapons = {
        MainGun = Class(SIFThunthoCannonWeapon) {}
    },
}

TypeClass = XSL0103