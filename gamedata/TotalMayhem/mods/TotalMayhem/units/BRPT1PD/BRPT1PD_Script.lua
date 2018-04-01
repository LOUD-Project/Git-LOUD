local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SDFAireauBolterWeapon = import('/lua/seraphimweapons.lua').SDFAireauBolterWeapon02
local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT1PD = Class(SStructureUnit) {
	Weapons = {
		MainGun = Class(SDFAireauBolterWeapon) {
			FxMuzzleFlashScale = 2.4, 
		},
	},

	OnStopBeingBuilt = function(self,builder,layer)
	
		SStructureUnit.OnStopBeingBuilt(self,builder,layer)
		
		self.Trash:Add(CreateRotator(self, 'Object107', 'y', nil, -650, 0, 0))
		self.Trash:Add(CreateRotator(self, 'Object105', 'y', nil, 450, 0, 0))
		self.Trash:Add(CreateRotator(self, 'Object42', 'y', nil, -250, 0, 0))
		self:CreatTheEffects()   
	end,

	OnKilled = function(self, instigator, damagetype, overkillRatio)
		SStructureUnit.OnKilled(self, instigator, damagetype, overkillRatio)
		self:CreatTheEffectsDeath()  
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.28))
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff02', army, v):ScaleEmitter(0.23))
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff03', army, v):ScaleEmitter(0.18))
		end
	end,

	CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SZthuthaamArtilleryHit'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'BRPT1PD', army, v):ScaleEmitter(1.65))
		end
	end,
}

TypeClass = BRPT1PD