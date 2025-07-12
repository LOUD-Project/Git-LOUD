local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local Missile  = import('/lua/seraphimweapons.lua').SLaanseMissileWeapon
local Cannon   = import('/lua/seraphimweapons.lua').SDFThauCannon

BSA0310 = Class(SAirUnit) {

    Weapons = {
    	Missile     = Class(Missile) {},
        GunTurret   = Class(Cannon) {},
    },
}
TypeClass = BSA0310