local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TAAFlakArtilleryCannon = import('/lua/terranweapons.lua').TAAFlakArtilleryCannon

UEB3304 = Class(TStructureUnit) {
    Weapons = {
        AAGun = Class(TAAFlakArtilleryCannon) {},
           
    },
}

TypeClass = UEB3304