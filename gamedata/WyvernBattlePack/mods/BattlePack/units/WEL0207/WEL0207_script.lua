local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local WeaponsFile = import('/lua/terranweapons.lua')
local TDFHiroPlasmaCannon = WeaponsFile.TDFHiroPlasmaCannon

WEL0207 = Class(TLandUnit) {
    Weapons = {
        TMD = Class(TDFHiroPlasmaCannon) {},
    },
}
TypeClass = WEL0207