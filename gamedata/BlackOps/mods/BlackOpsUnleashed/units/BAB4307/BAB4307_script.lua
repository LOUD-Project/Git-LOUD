local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

local AAATemporalFizzWeapon = import('/lua/aeonweapons.lua').AAATemporalFizzWeapon

BAB2304 = Class(AStructureUnit) {
    Weapons = {
        AntiMissile = Class(AAATemporalFizzWeapon) {},
    },
}

TypeClass = BAB2304