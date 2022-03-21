local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TIFCarpetBombWeapon = import('/lua/terranweapons.lua').TIFCarpetBombWeapon

UEA0103 = Class(TAirUnit) {
    Weapons = {
        Bomb = Class(TIFCarpetBombWeapon) {},
        },
    DamageEffectPullback = 0.5,
}

TypeClass = UEA0103

