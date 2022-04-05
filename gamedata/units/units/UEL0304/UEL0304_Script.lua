local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

UEL0304 = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(TIFArtilleryWeapon) {
        }
    },
}

TypeClass = UEL0304