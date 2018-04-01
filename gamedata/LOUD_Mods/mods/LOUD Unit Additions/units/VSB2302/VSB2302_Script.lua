local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

VSB2302 = Class(SStructureUnit) {

    Weapons = {
	
        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
		
    },
	
}

TypeClass = VSB2302