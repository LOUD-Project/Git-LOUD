local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/seraphimweapons.lua')

local SDFThauCannon     = WeaponsFile.SDFThauCannon
local SDFAireauBolter   = WeaponsFile.SDFAireauBolterWeapon
local SANAnaitTorpedo   = WeaponsFile.SANAnaitTorpedo

WeaponsFile = nil

XSL0303 = Class(SLandUnit) {

    Weapons = {
	
        Turret = Class(SDFThauCannon) {},

        LeftTurret = Class(SDFAireauBolter) {},
        RightTurret = Class(SDFAireauBolter) {},
		
        Torpedo = Class(SANAnaitTorpedo) {},		
    },
}

TypeClass = XSL0303