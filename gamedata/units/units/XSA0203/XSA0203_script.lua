local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit

local SDFPhasicAutoGunWeapon = import('/lua/seraphimweapons.lua').SDFPhasicAutoGunWeapon

XSA0203 = Class(SAirUnit) {

    Weapons = {
	
        Turret = Class(SDFPhasicAutoGunWeapon) {},
		
    },
	
}

TypeClass = XSA0203