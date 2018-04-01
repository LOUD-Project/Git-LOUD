
local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SDFAireauBolterWeapon = import('/lua/seraphimweapons.lua').SDFAireauBolterWeapon02

BRPT2BTBOT = Class(SWalkingLandUnit) {

	Weapons = {
		MainGun = Class(SDFAireauBolterWeapon) {},
		MainGun2 = Class(SDFAireauBolterWeapon) {},
	},

}
TypeClass = BRPT2BTBOT