local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TANTorpedoLandWeapon = import('/lua/terranweapons.lua').TANTorpedoLandWeapon

UEB2109 = Class(TStructureUnit) {
    Weapons = {
        Turret01 = Class(TANTorpedoLandWeapon) {},
    },
}

TypeClass = UEB2109

