local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CAAMissileNaniteWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

VRB2302 = Class(CStructureUnit) {

    Weapons = {
	
        Missile01 = Class(CAAMissileNaniteWeapon) {},
		
    },
	
}

TypeClass = VRB2302