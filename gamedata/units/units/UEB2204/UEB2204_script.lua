local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TAAFlakArtilleryCannon = import('/lua/terranweapons.lua').TAAFlakArtilleryCannon

UEB2204 = Class(TStructureUnit) {
    Weapons = {
        AAGun = Class(TAAFlakArtilleryCannon) {},
    },
}

TypeClass = UEB2204