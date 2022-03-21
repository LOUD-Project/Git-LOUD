local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CAANanoDartWeapon = CybranWeaponsFile.CAANanoDartWeapon

WRL0309 = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CAANanoDartWeapon) {},
    },
}

TypeClass = WRL0309