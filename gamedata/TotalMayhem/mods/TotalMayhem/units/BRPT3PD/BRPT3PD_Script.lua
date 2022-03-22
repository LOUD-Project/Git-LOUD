local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SDFAireauBolterWeapon = import('/lua/seraphimweapons.lua').SDFAireauBolterWeapon02

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT3PD = Class(SStructureUnit) {
	Weapons = {
		MainGun = Class(SDFAireauBolterWeapon) {
			FxMuzzleFlashScale = 2.4, 
		},
	},

	OnStopBeingBuilt = function(self,builder,layer)
	
		SStructureUnit.OnStopBeingBuilt(self,builder,layer)
		
		self.Trash:Add(CreateRotator(self, 'spinner02', 'y', nil, 120, 0, 0))
		self.Trash:Add(CreateRotator(self, 'spinner', 'y', nil, -80, 0, 0))
		self:CreatTheEffects()   
	end,

	OnKilled = function(self, instigator, damagetype, overkillRatio)
	
		self:CreatTheEffectsDeath()
		
		SStructureUnit.OnKilled(self, instigator, damagetype, overkillRatio)
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff02', army, v):ScaleEmitter(0.16))
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.16))
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff03', army, v):ScaleEmitter(0.16))
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff04', army, v):ScaleEmitter(0.16))
		end
	end,

	CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SZthuthaamArtilleryHit'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'BRPT3PD', army, v):ScaleEmitter(2))
		end
	end,
}

TypeClass = BRPT3PD