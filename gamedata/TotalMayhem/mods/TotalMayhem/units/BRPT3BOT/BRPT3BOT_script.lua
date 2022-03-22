local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SAAOlarisCannonWeapon = SeraphimWeapons.SAAOlarisCannonWeapon
local SDFThauCannon = SeraphimWeapons.SDFThauCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT3BOT = Class( SWalkingLandUnit ) {

	Weapons = {

		RightGun = Class(SAAOlarisCannonWeapon) {
		},
		MainTurret = Class(SDFThauCannon) {
		},
	},


	OnKilled = function(self, instigator, damagetype, overkillRatio)
		SWalkingLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
		self:CreatTheEffectsDeath()  
	end,

	CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SDFExperimentalPhasonProjHit01'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'BRPT1EXPBOT', army, v):ScaleEmitter(2.3))
		end
	end,
}

TypeClass = BRPT3BOT