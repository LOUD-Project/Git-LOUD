local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SAAShleoCannonWeapon = import('/lua/seraphimweapons.lua').SAAShleoCannonWeapon

XSL0104 = Class(SWalkingLandUnit) {

    Weapons = {
	
        AAGun = Class(SAAShleoCannonWeapon) {},
		
    },
	
}

TypeClass = XSL0104