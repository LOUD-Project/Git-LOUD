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
	
        laserblue = Class(TMAnovacatbluelaserweapon) {},
        laserblue2 = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},
        laserblue3 = Class(TMAmizurabluelaserweapon) {},
		
        lasergreen = Class(TMAnovacatgreenlaserweapon) {},

        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
		
        robottalk = Class(AAAZealotMissileWeapon) { FxMuzzleFlashScale = 0 },
		
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
      
		if self:GetAIBrain().BrainType == 'Human' and IsUnit(self) then
			self:SetWeaponEnabledByLabel('robottalk', false)
		else
			self:SetWeaponEnabledByLabel('robottalk', true)
		end      
    end,
}
TypeClass = BROT3NCM