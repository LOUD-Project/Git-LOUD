local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

UEL0108 = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {}
    },
}
TypeClass = UEL0108