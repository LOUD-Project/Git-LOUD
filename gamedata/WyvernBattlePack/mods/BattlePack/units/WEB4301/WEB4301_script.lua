local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local Beam = import('/lua/terranweapons.lua').TDFHiroPlasmaCannon

WEB4301 = Class(TStructureUnit) {

    Weapons = {
        TMDBeam = Class(Beam) {},
    },
}

TypeClass = WEB4301