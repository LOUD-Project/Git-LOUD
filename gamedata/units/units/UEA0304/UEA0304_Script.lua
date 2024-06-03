local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TIFSmallYieldNuclearBombWeapon = import('/lua/terranweapons.lua').TIFSmallYieldNuclearBombWeapon
local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun

UEA0304 = Class(TAirUnit) {
    Weapons = {
        Bomb = Class(TIFSmallYieldNuclearBombWeapon) {},
        LinkedRailGun1 = Class(TAALinkedRailgun) {},
    },
}

TypeClass = UEA0304
