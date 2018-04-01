local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

UAB2301 = Class(AStructureUnit) {

    Weapons = {
        MainGun = Class(import('/lua/aeonweapons.lua').ADFCannonOblivionWeapon) {
			FxMuzzleFlash = {
				'/effects/emitters/oblivion_cannon_flash_04_emit.bp',
				'/effects/emitters/oblivion_cannon_flash_05_emit.bp',				
				'/effects/emitters/oblivion_cannon_flash_06_emit.bp',
			},        
        }
    },
}

TypeClass = UAB2301