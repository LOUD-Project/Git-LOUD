local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

local AIFQuanticArtillery = import('/lua/aeonweapons.lua').AIFQuanticArtillery

XAB2307 = Class(AStructureUnit) {

    Weapons = {
        MainGun = Class(AIFQuanticArtillery) {},
    },
}
TypeClass = XAB2307