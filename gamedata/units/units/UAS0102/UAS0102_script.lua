
local ASeaUnit = import('/lua/aeonunits.lua').ASeaUnit
local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

UAS0102 = Class(ASeaUnit) {

    Weapons = {
        AAGun = Class(AAASonicPulseBatteryWeapon) {},
    },
    
}

TypeClass = UAS0102