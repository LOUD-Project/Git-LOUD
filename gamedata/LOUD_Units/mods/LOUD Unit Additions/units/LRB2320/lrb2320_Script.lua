local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CIFArtilleryWeapon = import('/lua/cybranweapons.lua').CIFArtilleryWeapon

LRB2320 = Class(CStructureUnit) {
   
    Weapons = {
        gun     = Class(CIFArtilleryWeapon) { FxMuzzleFlashScale = 0.2 },
        gun1    = Class(CIFArtilleryWeapon) { FxMuzzleFlashScale = 0.2 },
        gun2    = Class(CIFArtilleryWeapon) { FxMuzzleFlashScale = 0.2 },
    },
}

TypeClass = LRB2320