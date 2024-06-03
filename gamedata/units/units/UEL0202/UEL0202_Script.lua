local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

UEL0202 = Class(TLandUnit) {
    Weapons = {
        FrontTurret01 = Class(TDFGaussCannonWeapon) {}
    },
}

TypeClass = UEL0202