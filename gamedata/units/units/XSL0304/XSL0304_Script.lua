local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SIFSuthanusArtilleryCannon = import('/lua/seraphimweapons.lua').SIFSuthanusMobileArtilleryCannon

XSL0304 = Class(SWalkingLandUnit) {
    Weapons = {
        MainGun = Class(SIFSuthanusArtilleryCannon) {}
    },
 
}

TypeClass = XSL0304