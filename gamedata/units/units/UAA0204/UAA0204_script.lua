local AAirUnit = import('/lua/aeonunits.lua').AAirUnit
local AANDepthChargeBombWeapon = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

UAA0204 = Class(AAirUnit) {

    Weapons = {
	
        Bomb = Class(AANDepthChargeBombWeapon) {},
		
    },
}

TypeClass = UAA0204