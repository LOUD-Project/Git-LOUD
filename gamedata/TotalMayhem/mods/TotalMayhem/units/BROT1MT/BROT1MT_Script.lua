local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local aWeapons = import('/lua/aeonweapons.lua')
local AAASonicPulseBatteryWeapon = aWeapons.AAASonicPulseBatteryWeapon

BROT1MT = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(AAASonicPulseBatteryWeapon) {
			FxMuzzleFlash = {'/effects/emitters/sonic_pulse_muzzle_flash_02_emit.bp',},
        },
    },
}

TypeClass = BROT1MT