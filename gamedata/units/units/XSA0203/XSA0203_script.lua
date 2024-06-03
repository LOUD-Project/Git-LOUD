local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SDFPhasicAutoGunWeapon = import('/lua/seraphimweapons.lua').SDFPhasicAutoGunWeapon

XSA0203 = Class(SAirUnit) {

    Weapons = {
        Turret = Class(SDFPhasicAutoGunWeapon) {},
    },
	
}

TypeClass = XSA0203