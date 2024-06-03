local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AIFBombGravitonWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UAA0103 = Class(AAirUnit) {
    Weapons = {
        Bomb = Class(AIFBombGravitonWeapon) {},
    },
}

TypeClass = UAA0103

