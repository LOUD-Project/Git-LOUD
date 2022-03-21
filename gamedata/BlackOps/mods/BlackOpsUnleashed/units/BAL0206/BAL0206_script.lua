local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFReactonCannon = import('/lua/aeonweapons.lua').ADFReactonCannon

BAL0206 = Class(AHoverLandUnit) {

    Weapons = {
        AAGun = Class(ADFReactonCannon) {},
    },
}

TypeClass = BAL0206