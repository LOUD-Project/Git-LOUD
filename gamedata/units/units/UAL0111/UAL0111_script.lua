local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local AIFMissileTacticalSerpentineWeapon = import('/lua/aeonweapons.lua').AIFMissileTacticalSerpentineWeapon

UAL0111 = Class(ALandUnit) {
    Weapons = {
        MissileRack = Class(AIFMissileTacticalSerpentineWeapon) {},
    },
}

TypeClass = UAL0111