local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

UAB2104 = Class(AStructureUnit) {

    Weapons = {
        AAGun = Class(AAASonicPulseBatteryWeapon) { FxMuzzleScale = 2.25 },
    },
	
}

TypeClass = UAB2104
