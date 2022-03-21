local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFShipGaussCannonWeapon = import('/lua/terranweapons.lua').TDFShipGaussCannonWeapon

SEB2311 = Class(TStructureUnit) {
    Weapons = {
        FrontTurret02 = Class(TDFShipGaussCannonWeapon) {},
    },
}

TypeClass = SEB2311
