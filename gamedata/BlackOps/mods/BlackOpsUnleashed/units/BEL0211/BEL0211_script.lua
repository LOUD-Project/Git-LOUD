local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local Gun = import('/lua/terranweapons.lua').TDFMachineGunWeapon

BEL0211 = Class(TLandUnit) {
    Weapons = {
        Flamer = Class(Gun) {},
    },
}

TypeClass = BEL0211