local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SDFAireauBolterWeapon = import('/lua/seraphimweapons.lua').SDFAireauBolterWeapon02

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT2PD = Class(SStructureUnit) {

	Weapons = {
		MainGun = Class(SDFAireauBolterWeapon) { FxMuzzleFlashScale = 2.4 },
	},

	OnStopBeingBuilt = function(self,builder,layer)
	
		SStructureUnit.OnStopBeingBuilt(self,builder,layer)
		
		self.Trash:Add(CreateRotator(self, 'Pod01', 'y', nil, 150, 0, 0))
		self.Trash:Add(CreateRotator(self, 'Pod02', 'y', nil, 250, 0, 0))
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
		end
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.28))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff04', army, v):ScaleEmitter(0.12))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff05', army, v):ScaleEmitter(0.12))
			self.Trash:Add(CreateAttachedEmitter(self, 'Muzzle01', army, v):ScaleEmitter(0.10))
		end
	end,

	CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SZthuthaamArtilleryHit'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'BRPT1EXPD', army, v):ScaleEmitter(2.85))
		end
	end,
}

TypeClass = BRPT2PD