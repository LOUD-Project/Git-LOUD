local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TDFIonizedPlasmaCannon = import('/lua/terranweapons.lua').TDFIonizedPlasmaCannon

XEL0305 = Class(TWalkingLandUnit) {

    Weapons = {
        PlasmaCannon01 = Class(TDFIonizedPlasmaCannon) {},
    },

}

TypeClass = XEL0305