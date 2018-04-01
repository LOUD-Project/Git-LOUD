local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SAAShleoCannonWeapon = import('/lua/seraphimweapons.lua').SAAShleoCannonWeapon

XSB2104 = Class(SStructureUnit) {

    Weapons = {
	
        AAGun = Class(SAAShleoCannonWeapon) { FxMuzzleScale = 1.5 },
		
    },
	
}

TypeClass = XSB2104
