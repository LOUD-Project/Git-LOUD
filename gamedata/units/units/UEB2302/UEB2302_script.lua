local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

UEB2302 = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(TIFArtilleryWeapon) { FxMuzzleFlashScale = 3 }
    },
}

TypeClass = UEB2302