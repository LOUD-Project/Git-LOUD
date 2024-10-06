local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SIFZthuthaamArtilleryCannon = import('/lua/seraphimweapons.lua').SIFZthuthaamArtilleryCannon

LSB2320 = Class(SStructureUnit) {

    Weapons = {
        MainGun     = Class(SIFZthuthaamArtilleryCannon) {},
        MainGun1    = Class(SIFZthuthaamArtilleryCannon) {},
        MainGun2    = Class(SIFZthuthaamArtilleryCannon) {},
    },
}

TypeClass = LSB2320