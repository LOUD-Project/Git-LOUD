local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFHiroPlasmaCannon = import('/lua/terranweapons.lua').TDFHiroPlasmaCannon

WEL0207 = Class(TLandUnit) {

    Weapons = {
        TMD = Class(TDFHiroPlasmaCannon) {},
    },

}
TypeClass = WEL0207