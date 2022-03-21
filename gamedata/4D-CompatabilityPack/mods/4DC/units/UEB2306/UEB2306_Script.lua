local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TerranWeaponFile = import('/lua/terranweapons.lua')
local TDFIonizedPlasmaCannon = TerranWeaponFile.TDFIonizedPlasmaCannon

UEB2306 = Class(TStructureUnit) {
    Weapons = {
        Gauss01 = Class(TDFIonizedPlasmaCannon) {},    
    },
}

TypeClass = UEB2306