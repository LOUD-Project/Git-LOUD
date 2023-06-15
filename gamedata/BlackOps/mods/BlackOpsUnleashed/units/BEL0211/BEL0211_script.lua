local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon

BEL0211 = Class(TLandUnit) {
    Weapons = {
        Flamer = Class(TDFMachineGunWeapon) {},
    },
}

TypeClass = BEL0211