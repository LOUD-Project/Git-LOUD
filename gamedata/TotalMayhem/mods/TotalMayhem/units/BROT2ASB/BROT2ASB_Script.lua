local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TMAmizurabluelaserweapon = import('/mods/TotalMayhem/lua/TMAeonWeapons.lua').TMAmizurabluelaserweapon

BROT2ASB = Class(CWalkingLandUnit) {

    Weapons = {
        laser = Class(TMAmizurabluelaserweapon) { FxMuzzleFlashScale = 0.1 },  
    },
}

TypeClass = BROT2ASB