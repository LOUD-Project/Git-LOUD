local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

LEB2320 = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TIFArtilleryWeapon) {},
        MainGun1 = Class(TIFArtilleryWeapon) {},
        MainGun2 = Class(TIFArtilleryWeapon) {},
    },
}

TypeClass = LEB2320