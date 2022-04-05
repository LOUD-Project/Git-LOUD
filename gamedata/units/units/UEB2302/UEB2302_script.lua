local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

UEB2302 = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TIFArtilleryWeapon) { FxMuzzleFlashScale = 3 }
    },
}

TypeClass = UEB2302