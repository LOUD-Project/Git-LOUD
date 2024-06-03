local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

BROT1MT = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(AAASonicPulseBatteryWeapon) {},
    },
}

TypeClass = BROT1MT