local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CIFMissileLoaWeapon = import('/lua/cybranweapons.lua').CIFMissileLoaWeapon

URL0111 = Class(CLandUnit) {

    Weapons = {
        MissileRack = Class(CIFMissileLoaWeapon) {},
    },
	
}

TypeClass = URL0111
