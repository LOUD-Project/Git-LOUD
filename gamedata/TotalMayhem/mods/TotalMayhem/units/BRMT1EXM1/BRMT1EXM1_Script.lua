local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CCannonMolecularWeapon = import('/lua/cybranweapons.lua').CCannonMolecularWeapon

BRMT1EXM1 = Class(CWalkingLandUnit) {

    Weapons = {
        HeavyBolter = Class(CCannonMolecularWeapon) {
            FxMuzzleFlashScale = 0.25,
		},
    },
}

TypeClass = BRMT1EXM1