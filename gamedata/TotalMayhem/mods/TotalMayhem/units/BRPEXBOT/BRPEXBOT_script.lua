local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SIFSuthanusArtilleryCannon    = SeraphimWeapons.SIFSuthanusMobileArtilleryCannon
local SDFOhCannon                   = SeraphimWeapons.SDFOhCannon

SeraphimWeapons = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPEXBOT = Class( SWalkingLandUnit ) {

	Weapons = {
		MainGun         = Class(SIFSuthanusArtilleryCannon) {FxMuzzleFlashScale = 3.6},
		SecondaryGun    = Class(SDFOhCannon) {FxMuzzleFlashScale = 1.8},
	},

	OnStopBeingBuilt = function(self,builder,layer)
		SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		self:CreatTheEffects()   
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.2))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff02', army, v):ScaleEmitter(0.2))
		end

		for k, v in EffectTemplate['OthuyAmbientEmanation'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'eff03', army, v):ScaleEmitter(0.1))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff04', army, v):ScaleEmitter(0.1))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff05', army, v):ScaleEmitter(0.1))
			self.Trash:Add(CreateAttachedEmitter(self, 'eff06', army, v):ScaleEmitter(0.1))
		end

	end,

	OnKilled = function(self, instigator, damagetype, overkillRatio)
		SWalkingLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
		self:CreatTheEffectsDeath()  
    end,

	CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFExperimentalPhasonProjHit01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'Turret', army, v):ScaleEmitter(2.2))
		end
	end,
}

TypeClass = BRPEXBOT