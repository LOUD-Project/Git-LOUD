local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFQuanticArtillery = import('/lua/aeonweapons.lua').AIFQuanticArtillery

XAB2307 = Class(AStructureUnit) {

    Weapons = {
        MainGun = Class(AIFQuanticArtillery) {},
    },
}
TypeClass = XAB2307