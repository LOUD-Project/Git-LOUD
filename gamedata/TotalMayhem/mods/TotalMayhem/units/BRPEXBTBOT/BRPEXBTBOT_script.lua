
local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SAAOlarisCannonWeapon = SeraphimWeapons.SAAOlarisCannonWeapon
local SDFThauCannon = SeraphimWeapons.SDFThauCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local SAAOlarisCannonWeapon = import('/lua/seraphimweapons.lua').SAAOlarisCannonWeapon
local SDFChronotronCannonWeapon = SeraphimWeapons.SDFChronotronCannonWeapon

BRPEXBTBOT = Class( SWalkingLandUnit ) {
	Weapons = {
		AAGun = Class(SAAOlarisCannonWeapon) {},
		ArmWeapons = Class(SDFChronotronCannonWeapon) {},
	},

	OnStopBeingBuilt = function(self,builder,layer)
		SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		self:CreatTheEffects()
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['OthuyAmbientEmanation'] do
			CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.08)
			CreateAttachedEmitter(self, 'eff02', army, v):ScaleEmitter(0.08)
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			CreateAttachedEmitter(self, 'eff03', army, v):ScaleEmitter(0.28)
		end
	end,

	OnKilled = function(self, instigator, damagetype, overkillRatio)
		SWalkingLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
		self:CreatTheEffectsDeath()  
	end,

	CreatTheEffectsDeath = function(self)

		local army =  self:GetArmy()
	
		for k, v in EffectTemplate['SDFExperimentalPhasonProjHit01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'Object09', army, v):ScaleEmitter(2.3))
		end
	end,
}

TypeClass = BRPEXBTBOT