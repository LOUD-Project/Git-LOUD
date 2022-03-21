local SSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local SWeapon = import('/lua/seraphimweapons.lua')

XSS0103 = Class(SSeaUnit) {

    Weapons = {
	
        MainGun = Class(SWeapon.SDFShriekerCannon){},
        AntiAir = Class(SWeapon.SAAShleoCannonWeapon){},
		
    },
}

TypeClass = XSS0103
