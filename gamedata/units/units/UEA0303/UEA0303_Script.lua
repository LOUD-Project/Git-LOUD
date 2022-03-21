local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TAAGinsuRapidPulseWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UEA0303 = Class(TAirUnit) {
    Weapons = {
        --RightBeam = Class(TAAGinsuRapidPulseWeapon) {},
        LeftBeam = Class(TAAGinsuRapidPulseWeapon) {},
    },
}

TypeClass = UEA0303