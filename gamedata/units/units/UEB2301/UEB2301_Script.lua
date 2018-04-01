local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

UEB2301 = Class(TStructureUnit) {
    Weapons = {
        Gauss01 = Class(TDFGaussCannonWeapon) {},      
    },
}

TypeClass = UEB2301