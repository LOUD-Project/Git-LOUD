local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit
local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

UAB2104 = Class(AStructureUnit) {

    Weapons = {
	
        AAGun = Class(AAASonicPulseBatteryWeapon) {
		
            FxMuzzleScale = 2.25,
			
        },
		
    },
	
}

TypeClass = UAB2104
