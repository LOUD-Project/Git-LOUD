
local AAirUnit = import('/lua/aeonunits.lua').AAirUnit
local AIFBombGravitonWeapon = import('/lua/aeonweapons.lua').AIFBombGravitonWeapon

UAA0103 = Class(AAirUnit) {
    Weapons = {
        Bomb = Class(AIFBombGravitonWeapon) {},
    },
}

TypeClass = UAA0103

