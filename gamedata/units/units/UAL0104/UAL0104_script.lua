local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

UAL0104 = Class(ALandUnit) {

    Weapons = {
        AAGun = Class(AAASonicPulseBatteryWeapon) {},
    },
}

TypeClass = UAL0104