local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AIFBombQuarkWeapon = import('/lua/aeonweapons.lua').AIFBombQuarkWeapon

SAA0211 = Class(AAirUnit) {
    Weapons = {
        Bomb = Class(AIFBombQuarkWeapon) {},
    },
}

TypeClass = SAA0211
