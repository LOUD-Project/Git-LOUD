local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local CAAMissileNaniteWeapon = import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon

VRB2302 = Class(CStructureUnit) {

    Weapons = {
	
        Missile01 = Class(CAAMissileNaniteWeapon) {},
		
    },
	
}

TypeClass = VRB2302