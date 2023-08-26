local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TMWeaponsFile = import('/mods/TotalMayhem/lua/TMAeonWeapons.lua')
local TMAmizurabluelaserweapon = TMWeaponsFile.TMAmizurabluelaserweapon

BROT2ASB = Class(CWalkingLandUnit) {

    Weapons = {
        laser = Class(TMAmizurabluelaserweapon) { FxMuzzleFlashScale = 0.1 },  
    },
}

TypeClass = BROT2ASB