local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SDFAireauBolterWeapon = import('/lua/seraphimweapons.lua').SDFAireauBolterWeapon

BRPT2BTBOT = Class(SWalkingLandUnit) {

	Weapons = {
		MainGun = Class(SDFAireauBolterWeapon) {},
		MainGun2 = Class(SDFAireauBolterWeapon) {},
	},

}
TypeClass = BRPT2BTBOT