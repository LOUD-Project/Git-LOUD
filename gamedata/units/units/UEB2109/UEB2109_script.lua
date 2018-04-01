local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local TANTorpedoLandWeapon = import('/lua/terranweapons.lua').TANTorpedoLandWeapon

UEB2109 = Class(TStructureUnit) {
    Weapons = {
        Turret01 = Class(TANTorpedoLandWeapon) {},
    },
}

TypeClass = UEB2109

