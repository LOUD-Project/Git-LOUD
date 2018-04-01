local SLandUnit = import('/lua/seraphimunits.lua').SLandUnit

local WeaponsFile = import('/lua/seraphimweapons.lua')

local SDFThauCannon = WeaponsFile.SDFThauCannon
local SDFAireauBolter = WeaponsFile.SDFAireauBolterWeapon
local SANUallCavitationTorpedo = WeaponsFile.SANUallCavitationTorpedo
local EffectUtil = import('/lua/EffectUtilities.lua')

XSL0303 = Class(SLandUnit) {

    Weapons = {
	
        Turret = Class(SDFThauCannon) {},

        LeftTurret = Class(SDFAireauBolter) {},
        RightTurret = Class(SDFAireauBolter) {},
		
        Torpedo = Class(SANUallCavitationTorpedo) {},		
    },
}

TypeClass = XSL0303