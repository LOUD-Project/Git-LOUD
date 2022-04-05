local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CAAMissileNaniteWeapon = import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon

VRB2302 = Class(CStructureUnit) {

    Weapons = {
	
        Missile01 = Class(CAAMissileNaniteWeapon) {},
		
    },
	
}

TypeClass = VRB2302