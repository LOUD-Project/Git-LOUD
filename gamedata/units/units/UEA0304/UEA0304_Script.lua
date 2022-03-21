local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TIFSmallYieldNuclearBombWeapon = import('/lua/terranweapons.lua').TIFSmallYieldNuclearBombWeapon
local TAirToAirLinkedRailgun = import('/lua/terranweapons.lua').TAirToAirLinkedRailgun

UEA0304 = Class(TAirUnit) {
    Weapons = {
        Bomb = Class(TIFSmallYieldNuclearBombWeapon) {},
        LinkedRailGun1 = Class(TAirToAirLinkedRailgun) {},
        --LinkedRailGun2 = Class(TAirToAirLinkedRailgun) {},
    },
}

TypeClass = UEA0304
