local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SLaanseMissileWeapon  = import('/lua/seraphimweapons.lua').SLaanseMissileWeapon
local SDFThauCannon         = import('/lua/seraphimweapons.lua').SDFThauCannon

BSA0310 = Class(SAirUnit) {

    Weapons = {
    	Missile     = Class(SLaanseMissileWeapon) {},
        GunTurret   = Class(SDFThauCannon) {},
    },
}
TypeClass = BSA0310