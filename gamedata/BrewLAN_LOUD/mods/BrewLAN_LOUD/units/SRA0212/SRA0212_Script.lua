local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CAAAutocannon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

SRA0102 = Class(CAirUnit) {
    Weapons = {
        AutoCannon = Class(CAAAutocannon) {},
    },
}

TypeClass = SRA0102
