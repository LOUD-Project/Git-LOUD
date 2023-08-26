local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')
local AWeapons = import('/lua/aeonweapons.lua')
local TMWeaponsFile = import('/mods/TotalMayhem/lua/TMAeonWeapons.lua')

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CDFHeavyMicrowaveLaserGeneratorCom = CybranWeaponsFile.CDFHeavyMicrowaveLaserGeneratorCom

local TMAmizurabluelaserweapon = TMWeaponsFile.TMAmizurabluelaserweapon
local TMAnovacatbluelaserweapon = TMWeaponsFile.TMAnovacatbluelaserweapon
local TMAnovacatgreenlaserweapon = TMWeaponsFile.TMAnovacatgreenlaserweapon

local TIFCommanderDeathWeapon = WeaponsFile.TIFCommanderDeathWeapon

local AAAZealotMissileWeapon = AWeapons.AAAZealotMissileWeapon

local CreateAttachedEmitter = CreateAttachedEmitter

BROT3NCM = Class(AWalkingLandUnit) {

    Weapons = {

        MainLaser = Class(TMAnovacatgreenlaserweapon) {FxMuzzleFlashScale = 0.5},	

        laserblu = Class(TMAnovacatbluelaserweapon) {FxMuzzleFlashScale = 0},
        laserred = Class(CDFHeavyMicrowaveLaserGeneratorCom) {FxMuzzleFlashScale = 0},
        lasermix = Class(TMAmizurabluelaserweapon) {FxMuzzleFlashScale = 0},

        AAMissiles = Class(AAAZealotMissileWeapon) {},
		
        robottalk = Class(AAAZealotMissileWeapon) { FxMuzzleFlashScale = 0 },
		
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    },

}
TypeClass = BROT3NCM