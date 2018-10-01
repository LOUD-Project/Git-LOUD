local TAirUnit = import('/lua/terranunits.lua').TAirUnit
local TAAGinsuRapidPulseWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UEA0303 = Class(TAirUnit) {
    Weapons = {
        --RightBeam = Class(TAAGinsuRapidPulseWeapon) {},
        LeftBeam = Class(TAAGinsuRapidPulseWeapon) {},
    },
}

TypeClass = UEA0303