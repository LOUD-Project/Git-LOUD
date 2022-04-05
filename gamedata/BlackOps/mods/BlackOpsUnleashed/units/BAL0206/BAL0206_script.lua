--local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

--local ADFReactonCannon = import('/lua/aeonweapons.lua').ADFReactonCannon

BAL0206 = Class(import('/lua/defaultunits.lua').MobileUnit) {

    Weapons = {
        AAGun = Class(import('/lua/aeonweapons.lua').ADFReactonCannon) {},
    },
}

TypeClass = BAL0206