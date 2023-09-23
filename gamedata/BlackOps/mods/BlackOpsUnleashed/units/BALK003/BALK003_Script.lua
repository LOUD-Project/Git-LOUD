local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

BALK003 = Class(AWalkingLandUnit) {    
    Weapons = {
		AAMissile = Class(AAAZealotMissileWeapon) {},
    },
}

TypeClass = BALK003