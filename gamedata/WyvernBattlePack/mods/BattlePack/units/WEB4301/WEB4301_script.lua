local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local WeaponsFile = import('/lua/terranweapons.lua')
local TDFHiroPlasmaCannon = WeaponsFile.TDFHiroPlasmaCannon

WEB4301 = Class(TStructureUnit) {
    Weapons = {
        Turret01 = Class(TDFHiroPlasmaCannon) {},
    },
}

TypeClass = WEB4301