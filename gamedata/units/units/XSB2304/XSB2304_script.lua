local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeapon

XSB2304 = Class(SStructureUnit) {
    Weapons = {
        AutoCannon = Class(SAALosaareAutoCannonWeapon) {},
    },
}

TypeClass = XSB2304