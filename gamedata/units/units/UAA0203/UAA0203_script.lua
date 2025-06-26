local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local Laser = import('/lua/aeonweapons.lua').ADFLaserLightWeapon

UAA0203 = Class(AAirUnit) {

    Weapons = {
	
        Turret = Class(Laser) {},
    },
}

TypeClass = UAA0203