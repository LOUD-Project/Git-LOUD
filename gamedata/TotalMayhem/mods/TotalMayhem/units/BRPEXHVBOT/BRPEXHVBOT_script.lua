local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFUltraChromaticBeamGenerator    = SeraphimWeapons.SDFUltraChromaticBeamGenerator02
local SDFChronotronCannonWeapon         = SeraphimWeapons.SDFChronotronCannonWeapon
local SDFAireauBolterWeapon             = SeraphimWeapons.SDFAireauBolterWeapon

SeraphimWeapons = nil

local SeraLambdaFieldDestroyer = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldDestroyer

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT2HVBOT = Class( SWalkingLandUnit ) {

	Weapons = {
	
		Beam            = Class(SDFUltraChromaticBeamGenerator) { FxMuzzleFlashScale = 2 },

		ChronoCannon    = Class(SDFChronotronCannonWeapon) {},

		Bolter          = Class(SDFAireauBolterWeapon) { FxMuzzleFlashScale = 0.9 },
	},

	OnStopBeingBuilt = function(self,builder,layer)

		SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

        local bp = self:GetBlueprint().Defense.LambdaDestroy01

        self.Lambda1 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }

        self.Trash:Add(self.Lambda1)   

        self.Lambda1:Enable()        

		self:CreatTheEffects()   
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
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
			self.Trash:Add(CreateAttachedEmitter(self, 'BRPT2HVBOT', army, v):ScaleEmitter(2.1))
		end
	end,
}
TypeClass = BRPT2HVBOT