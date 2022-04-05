local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CIFArtilleryWeapon = import('/lua/cybranweapons.lua').CIFArtilleryWeapon

LRB2320 = Class(CStructureUnit) {
    Weapons = {
        gun = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        }
    },
}

TypeClass = LRB2320