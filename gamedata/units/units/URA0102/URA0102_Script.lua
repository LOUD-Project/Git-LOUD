local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CAAAutocannon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

URA0102 = Class(CAirUnit) {

    Weapons = {
        AutoCannon = Class(CAAAutocannon) {},
    },
}

TypeClass = URA0102
