local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

BALK003 = Class(AWalkingLandUnit) {    
    Weapons = {
		Missile = Class(AAAZealotMissileWeapon) {},
    },
}

TypeClass = BALK003