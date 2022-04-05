local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFIonizedPlasmaCannon = import('/lua/terranweapons.lua').TDFIonizedPlasmaCannon

UEB2306 = Class(TStructureUnit) {
    Weapons = {
        Gauss01 = Class(TDFIonizedPlasmaCannon) {},    
    },
}

TypeClass = UEB2306