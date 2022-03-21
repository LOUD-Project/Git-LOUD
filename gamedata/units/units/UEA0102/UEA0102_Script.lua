local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TAirToAirLinkedRailgun = import('/lua/terranweapons.lua').TAirToAirLinkedRailgun

UEA0102 = Class(TAirUnit) {
    PlayDestructionEffects = true,
    DamageEffectPullback = 0.25,
    DestroySeconds = 7.5,

    Weapons = {
        LinkedRailGun = Class(TAirToAirLinkedRailgun) {
        },
    },
}

TypeClass = UEA0102