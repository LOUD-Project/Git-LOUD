local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/cybranweapons.lua')
local WeaponsFile2 = import('/lua/terranweapons.lua')

local CDFElectronBolterWeapon = WeaponsFile.CDFElectronBolterWeapon
local CCannonMolecularWeapon = WeaponsFile.CCannonMolecularWeapon

local TDFGaussCannonWeapon = WeaponsFile2.TDFLandGaussCannonWeapon

BRMT3VUL = Class(CWalkingLandUnit) {

    Weapons = {
        HeavyBolter = Class(CDFElectronBolterWeapon) {},

        lefthandweapon = Class(CCannonMolecularWeapon) { FxMuzzleFlashScale = 1.3 },
        righthandweapon = Class(CCannonMolecularWeapon) { FxMuzzleFlashScale = 1.3 },
		
        rocket1 = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.5 },
    },
}

TypeClass = BRMT3VUL