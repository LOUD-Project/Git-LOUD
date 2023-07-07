local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AANDepthChargeBombWeapon = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

UAA0204 = Class(AAirUnit) {

    Weapons = {
	
        DepthCharge = Class(AANDepthChargeBombWeapon) {},
		
    },
}

TypeClass = UAA0204