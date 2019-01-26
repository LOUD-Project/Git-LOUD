local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit

local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponAirUnit
local SLaanseMissileWeapon = import('/lua/seraphimweapons.lua').SLaanseMissileWeapon
local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon

BSA0310 = Class(SAirUnit) {
    Weapons = {
	
    	Missile = Class(SLaanseMissileWeapon) {},
		
        GunTurret = Class(SDFThauCannon) {},

        AATurret = Class(SAALosaareAutoCannonWeapon) {},
    },
}
TypeClass = BSA0310