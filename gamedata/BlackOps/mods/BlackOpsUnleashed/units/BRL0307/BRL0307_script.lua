local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Tactical = import('/lua/cybranweapons.lua').CIFMissileLoaTacticalWeapon

BRL0307 = Class(CWalkingLandUnit) {
    Weapons = {
        MissileRack = Class(Tactical) {},
    },
}

TypeClass = BRL0307
