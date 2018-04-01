

local AAirUnit = import('/lua/aeonunits.lua').AAirUnit
local AIFBombQuarkWeapon = import('/lua/aeonweapons.lua').AIFBombQuarkWeapon


UAA0304 = Class(AAirUnit) {
    Weapons = {
        Bomb = Class(AIFBombQuarkWeapon) {},
    },
}

TypeClass = UAA0304