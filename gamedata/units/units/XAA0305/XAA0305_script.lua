local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local ADFLaserLightWeapon = import('/lua/aeonweapons.lua').ADFLaserLightWeapon
local AAAZealot02MissileWeapon = import('/lua/aeonweapons.lua').AAAZealot02MissileWeapon

XAA0305 = Class(AAirUnit) {

    Weapons = {
        Turret = Class(ADFLaserLightWeapon) {},
        AAGun = Class(AAAZealot02MissileWeapon) {},
    },
	
}

TypeClass = XAA0305