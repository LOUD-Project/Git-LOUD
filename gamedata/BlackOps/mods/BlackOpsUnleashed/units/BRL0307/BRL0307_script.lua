local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CIFMissileLoaTacticalWeapon = import('/lua/cybranweapons.lua').CIFMissileLoaTacticalWeapon

BRL0307 = Class(CWalkingLandUnit) {
    Weapons = {
        MissileRack = Class(CIFMissileLoaTacticalWeapon) {},
    },
}

TypeClass = BRL0307
