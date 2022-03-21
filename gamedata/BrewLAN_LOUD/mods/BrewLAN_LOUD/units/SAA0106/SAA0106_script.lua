local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local AANDepthChargeBombWeapon = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

SAA0106 = Class(AAirUnit) {
    Weapons = {
        Bomb = Class(AANDepthChargeBombWeapon) {},
    },
}

TypeClass = SAA0106
