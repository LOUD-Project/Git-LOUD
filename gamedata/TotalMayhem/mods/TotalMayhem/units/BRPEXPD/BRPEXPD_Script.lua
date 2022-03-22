local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SDFUltraChromaticBeamGenerator = import('/lua/seraphimweapons.lua').SDFUltraChromaticBeamGenerator02

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPEXPD = Class(SStructureUnit) {
	Weapons = {
		MainWeapon = Class(SDFUltraChromaticBeamGenerator) { FxMuzzleFlashScale = 2.4 },
	},

	OnStopBeingBuilt = function(self,builder,layer)
	
		SStructureUnit.OnStopBeingBuilt(self,builder,layer)
		
		self.Trash:Add(CreateRotator(self, 'Object06', 'y', nil, 45, 0, 0))
		
		self:CreatTheEffects()   
	end,

	OnKilled = function(self, instigator, damagetype, overkillRatio)
	
		SStructureUnit.OnKilled(self, instigator, damagetype, overkillRatio)
		
		self:CreatTheEffectsDeath()  
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['OthuyAmbientEmanation'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff02', army, v):ScaleEmitter(0.08))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff03', army, v):ScaleEmitter(0.08))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff04', army, v):ScaleEmitter(0.08))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff05', army, v):ScaleEmitter(0.08))
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.3))
			self.Trash:Add(CreateAttachedEmitter(self, 'Muzzle01', army, v):ScaleEmitter(0.15))
			self.Trash:Add(CreateAttachedEmitter(self, 'Muzzle02', army, v):ScaleEmitter(0.08))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff06', army, v):ScaleEmitter(0.15))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff07', army, v):ScaleEmitter(0.15))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff08', army, v):ScaleEmitter(0.15))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff09', army, v):ScaleEmitter(0.15))
		end
	end,

	CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SLaanseMissleHit'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'BRPT2EXPD', army, v):ScaleEmitter(3.85))
		end
	end,
}

TypeClass = BRPEXPD