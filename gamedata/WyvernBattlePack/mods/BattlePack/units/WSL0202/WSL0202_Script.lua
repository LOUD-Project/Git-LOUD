local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon

WSL0202 = Class(SLandUnit) {
    Weapons = {
        MainTurret = Class(SDFThauCannon) {},
    },
}

TypeClass = WSL0202