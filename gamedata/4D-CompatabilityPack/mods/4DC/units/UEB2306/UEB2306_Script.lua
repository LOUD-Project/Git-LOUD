
local TerranWeaponFile = import('/lua/terranweapons.lua')
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TDFIonizedPlasmaCannon = TerranWeaponFile.TDFIonizedPlasmaCannon

UEB2306 = Class(TStructureUnit) {
    Weapons = {
        Gauss01 = Class(TDFIonizedPlasmaCannon) {},    
    },
}

TypeClass = UEB2306