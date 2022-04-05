local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun

UEL0104 = Class(TLandUnit) {
    Weapons = {
        AAGun = Class(TAALinkedRailgun) {
            FxMuzzleFlashScale = 0.25,
        },
    },

}

TypeClass = UEL0104