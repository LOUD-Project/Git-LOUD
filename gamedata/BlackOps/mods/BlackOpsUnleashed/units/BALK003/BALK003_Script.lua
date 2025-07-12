local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AA = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

BALK003 = Class(AWalkingLandUnit) {    
    Weapons = {
		AAMissile = Class(AA) {},
    },
}

TypeClass = BALK003