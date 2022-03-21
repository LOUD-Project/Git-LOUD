local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFHiroPlasmaCannon = import('/lua/terranweapons.lua').TDFHiroPlasmaCannon

SEB2320 = Class(TStructureUnit) {
    Weapons = {
        HiroCannon = Class(TDFHiroPlasmaCannon) {},
    },
}
TypeClass = SEB2320
