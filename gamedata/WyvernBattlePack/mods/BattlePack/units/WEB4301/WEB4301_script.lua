local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFHiroPlasmaCannon = WeaponsFile.TDFHiroPlasmaCannon

WEB4301 = Class(TStructureUnit) {
    Weapons = {
        AntiMissile = Class(TDFHiroPlasmaCannon) {},
    },
}

TypeClass = WEB4301