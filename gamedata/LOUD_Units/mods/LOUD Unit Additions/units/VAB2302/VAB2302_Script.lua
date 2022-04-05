local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

VAB2302 = Class(AStructureUnit) {

    Weapons = {
	
        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
		
    }
	
}

TypeClass = VAB2302