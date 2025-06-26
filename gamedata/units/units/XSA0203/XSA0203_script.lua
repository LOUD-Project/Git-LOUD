local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local AutoGun = import('/lua/seraphimweapons.lua').SDFPhasicAutoGunWeapon

XSA0203 = Class(SAirUnit) {

    Weapons = {
        TurretL = Class(AutoGun) {},
        TurretR = Class(AutoGun) {},
    },
	
}

TypeClass = XSA0203