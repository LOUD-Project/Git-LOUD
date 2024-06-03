local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local AIFMortarWeapon = import('/lua/aeonweapons.lua').AIFMortarWeapon

UAL0103 = Class(ALandUnit) {

    Weapons = {
	
        MainGun = Class(AIFMortarWeapon) { FxMuzzleFlash = {'/effects/emitters/aeon_mortar_flash_01_emit.bp','/effects/emitters/aeon_mortar_flash_02_emit.bp'} }
    },
}

TypeClass = UAL0103