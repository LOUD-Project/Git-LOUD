local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun

UEA0102 = Class(TAirUnit) {
    PlayDestructionEffects = true,
    DamageEffectPullback = 0.25,
    DestroySeconds = 7.5,

    Weapons = {
        LinkedRailGun = Class(TAALinkedRailgun) {
        },
    },
}

TypeClass = UEA0102