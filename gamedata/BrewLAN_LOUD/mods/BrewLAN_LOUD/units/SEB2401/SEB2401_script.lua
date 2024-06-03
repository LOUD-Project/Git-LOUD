local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFShipGaussCannonWeapon = import('/lua/terranweapons.lua').TDFShipGaussCannonWeapon

SEB2401 = Class(TStructureUnit) {
    Weapons = {
        MainGun = Class(TDFShipGaussCannonWeapon){
            FxMuzzleFlash = {},
        },
    },
}
TypeClass = SEB2401
