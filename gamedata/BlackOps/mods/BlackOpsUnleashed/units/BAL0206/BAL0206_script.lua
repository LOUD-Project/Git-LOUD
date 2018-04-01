local AHoverLandUnit = import('/lua/aeonunits.lua').AHoverLandUnit

local ADFReactonCannon = import('/lua/aeonweapons.lua').ADFReactonCannon

BAL0206 = Class(AHoverLandUnit) {

    Weapons = {
        AAGun = Class(ADFReactonCannon) {},
    },
}

TypeClass = BAL0206