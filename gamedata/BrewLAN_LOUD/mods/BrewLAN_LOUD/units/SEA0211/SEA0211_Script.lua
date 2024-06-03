local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TIFSmallYieldNuclearBombWeapon = import('/lua/terranweapons.lua').TIFSmallYieldNuclearBombWeapon
local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun

SEA0211 = Class(TAirUnit) {
    Weapons = {
        Bomb = Class(TIFSmallYieldNuclearBombWeapon) {},
        LinkedRailGun = Class(TAALinkedRailgun) {},
    },
}

TypeClass = SEA0211
