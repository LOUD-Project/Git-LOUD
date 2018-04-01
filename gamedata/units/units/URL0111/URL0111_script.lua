local CLandUnit = import('/lua/cybranunits.lua').CLandUnit

local CIFMissileLoaWeapon = import('/lua/cybranweapons.lua').CIFMissileLoaWeapon

URL0111 = Class(CLandUnit) {

    Weapons = {
        MissileRack = Class(CIFMissileLoaWeapon) {},
    },
	
}

TypeClass = URL0111
