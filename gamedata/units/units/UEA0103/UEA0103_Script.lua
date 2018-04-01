local TAirUnit = import('/lua/terranunits.lua').TAirUnit
local TIFCarpetBombWeapon = import('/lua/terranweapons.lua').TIFCarpetBombWeapon

UEA0103 = Class(TAirUnit) {
    Weapons = {
        Bomb = Class(TIFCarpetBombWeapon) {
            },
        },
    DamageEffectPullback = 0.5,
}

TypeClass = UEA0103

