local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

BALK003 = Class(AWalkingLandUnit) {    
    Weapons = {
		Missile = Class(AAAZealotMissileWeapon) {},
    },
}

TypeClass = BALK003