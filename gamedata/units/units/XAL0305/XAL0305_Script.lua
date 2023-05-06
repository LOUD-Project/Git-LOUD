local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local ADFHeavyDisruptorCannonWeapon = import('/lua/aeonweapons.lua').ADFHeavyDisruptorCannonWeapon

XAL0305 = Class(AWalkingLandUnit) {
    Weapons = {
        MainGun = Class(ADFHeavyDisruptorCannonWeapon) {}
    },
}

TypeClass = XAL0305