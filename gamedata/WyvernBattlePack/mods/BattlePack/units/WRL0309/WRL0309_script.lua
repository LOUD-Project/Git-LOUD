local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local AA = import('/lua/cybranweapons.lua').CAANanoDartWeapon

WRL0309 = Class(CLandUnit) {
    Weapons = {
        AAMissiles = Class(AA) {},
    },
}

TypeClass = WRL0309