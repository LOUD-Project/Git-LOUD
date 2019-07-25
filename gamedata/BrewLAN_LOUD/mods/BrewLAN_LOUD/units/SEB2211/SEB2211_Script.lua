local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TDFShipGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

SEB2211 = Class(TStructureUnit) {
    Weapons = {
        Turret = Class(TDFShipGaussCannonWeapon) {},
    },
}

TypeClass = SEB2211
