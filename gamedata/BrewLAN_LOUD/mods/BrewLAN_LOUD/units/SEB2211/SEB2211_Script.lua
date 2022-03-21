local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFShipGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

SEB2211 = Class(TStructureUnit) {
    Weapons = {
        Turret = Class(TDFShipGaussCannonWeapon) {},
    },
}

TypeClass = SEB2211
