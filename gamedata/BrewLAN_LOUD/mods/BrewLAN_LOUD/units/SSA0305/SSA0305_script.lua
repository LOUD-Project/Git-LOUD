local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SDFPhasicAutoGunWeapon = import('/lua/seraphimweapons.lua').SDFPhasicAutoGunWeapon
local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponAirUnit

SSA0305 = Class(SAirUnit) {
    Weapons = {
        AutoCannon1 = Class(SAALosaareAutoCannonWeapon) {},
        TurretLeft = Class(SDFPhasicAutoGunWeapon) {},
        TurretRight = Class(SDFPhasicAutoGunWeapon) {},
    },
}
TypeClass = SSA0305
