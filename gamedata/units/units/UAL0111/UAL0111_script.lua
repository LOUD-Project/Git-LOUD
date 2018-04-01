
local ALandUnit = import('/lua/aeonunits.lua').ALandUnit
local AIFMissileTacticalSerpentineWeapon = import('/lua/aeonweapons.lua').AIFMissileTacticalSerpentineWeapon

UAL0111 = Class(ALandUnit) {
    Weapons = {
        MissileRack = Class(AIFMissileTacticalSerpentineWeapon) {},
    },
}

TypeClass = UAL0111