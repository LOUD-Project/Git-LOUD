
local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFUltraChromaticBeamGenerator = SeraphimWeapons.SDFUltraChromaticBeamGenerator02
local SDFChronotronCannonWeapon = SeraphimWeapons.SDFChronotronCannonWeapon
local SDFAireauBolterWeapon = SeraphimWeapons.SDFAireauBolterWeapon02

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT2HVBOT = Class( SWalkingLandUnit ) {

	Weapons = {
	
		Beam = Class(SDFUltraChromaticBeamGenerator) { FxMuzzleFlashScale = 2.4 },
	
		ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
		
		Bolter = Class(SDFAireauBolterWeapon) { FxMuzzleFlashScale = 1.2 },
	},

	OnStopBeingBuilt = function(self,builder,layer)
		SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		self:CreatTheEffects()   
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'aa01', army, v):ScaleEmitter(0.1))
			self.Trash:Add(CreateAttachedEmitter(self, 'aa02', army, v):ScaleEmitter(0.1))
			self.Trash:Add(CreateAttachedEmitter(self, 'aa03', army, v):ScaleEmitter(0.1))
			self.Trash:Add(CreateAttachedEmitter(self, 'aa04', army, v):ScaleEmitter(0.1))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.3))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff02', army, v):ScaleEmitter(0.3))
		end
	end,

	OnKilled = function(self, instigator, damagetype, overkillRatio)
		SWalkingLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
		self:CreatTheEffectsDeath()  
	end,

	CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFExperimentalPhasonProjHit01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'BRPT2HVBOT', army, v):ScaleEmitter(2.3))
		end
	end,
}
TypeClass = BRPT2HVBOT