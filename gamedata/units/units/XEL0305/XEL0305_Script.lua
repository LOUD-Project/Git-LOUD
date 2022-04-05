local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TerranWeaponFile = import('/lua/terranweapons.lua')

local TDFIonizedPlasmaCannon = TerranWeaponFile.TDFIonizedPlasmaCannon

XEL0305 = Class(TWalkingLandUnit) {

    Weapons = {
        PlasmaCannon01 = Class(TDFIonizedPlasmaCannon) {},
    },

}

TypeClass = XEL0305