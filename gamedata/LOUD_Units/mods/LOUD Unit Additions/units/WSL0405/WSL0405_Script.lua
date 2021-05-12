local SHoverLandUnit = import('/lua/seraphimunits.lua').SHoverLandUnit

local WeaponsFile = import('/lua/seraphimweapons.lua')
local SDFThauCannon = WeaponsFile.SDFThauCannon
local SDFAireauBolter = WeaponsFile.SDFAireauBolterWeapon
local SAAShleoCannonWeapon = import('/lua/seraphimweapons.lua').SAAShleoCannonWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')

WSL0405 = Class(SHoverLandUnit) {
    Weapons = {
	
        MainTurret = Class(SDFThauCannon) {},
		
        LeftTurret = Class(SDFAireauBolter) {},
        RightTurret = Class(SDFAireauBolter) {},
        RearLeftTurret = Class(SDFAireauBolter) {},
        RearRightTurret = Class(SDFAireauBolter) {},
		
        AAGun = Class(SAAShleoCannonWeapon) { FxMuzzleScale = 2 },
    },
}

TypeClass = WSL0405