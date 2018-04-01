
local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local TMWeaponsFile = import('/mods/TotalMayhem/lua/TMAeonWeapons.lua')
local TMAmizurabluelaserweapon = TMWeaponsFile.TMAmizurabluelaserweapon
--local TMAnovacatgreenlaserweapon = TMWeaponsFile.TMAnovacatgreenlaserweapon

BROT2ASB = Class(CWalkingLandUnit) {

    Weapons = {
        laser = Class(TMAmizurabluelaserweapon) {
            FxMuzzleFlashScale = 0.3,
        },  
    },
}

TypeClass = BROT2ASB