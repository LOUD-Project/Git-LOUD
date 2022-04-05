local SHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SIFThunthoCannonWeapon = import('/lua/seraphimweapons.lua').SIFThunthoCannonWeapon

XSL0103 = Class(SHoverLandUnit) {
    Weapons = {
        MainGun = Class(SIFThunthoCannonWeapon) {}
    },
}

TypeClass = XSL0103