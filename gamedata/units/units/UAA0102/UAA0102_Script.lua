local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

UAA0102 = Class(AAirUnit) {

    Weapons = {
        SonicPulseBattery = Class(AAASonicPulseBatteryWeapon) {	FxMuzzleFlash = {'/effects/emitters/sonic_pulse_muzzle_flash_02_emit.bp' } },
    }, 
}

TypeClass = UAA0102