local AAirUnit = import('/lua/aeonunits.lua').AAirUnit

local ADFQuadLaserLightWeapon = import('/lua/aeonweapons.lua').ADFQuadLaserLightWeapon
local AAAZealot02MissileWeapon = import('/lua/aeonweapons.lua').AAAZealot02MissileWeapon

XAA0305 = Class(AAirUnit) {

    Weapons = {
        Turret = Class(ADFQuadLaserLightWeapon) {},
        AAGun = Class(AAAZealot02MissileWeapon) {},
    },
	
}

TypeClass = XAA0305