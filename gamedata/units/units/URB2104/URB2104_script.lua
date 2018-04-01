local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local CAAAutocannon = import('/lua/cybranweapons.lua').CAAAutocannon

URB2104 = Class(CStructureUnit) {

    Weapons = {
	
        AAGun = Class(CAAAutocannon) { FxMuzzleScale = 2.25 },
		
    },
	
}

TypeClass = URB2104
