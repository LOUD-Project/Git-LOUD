local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SIFZthuthaamArtilleryCannon = import('/lua/seraphimweapons.lua').SIFZthuthaamArtilleryCannon

SSB2103 = Class(SStructureUnit) {

    Weapons = {
        MainGun = Class(SIFZthuthaamArtilleryCannon) {},
    },
}

TypeClass = SSB2103
