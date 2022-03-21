local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponAirUnit
local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPAT3GUNSHIP = Class(SAirUnit) {

	Weapons = {
		AAGun = Class(SAALosaareAutoCannonWeapon) {},
		MainTurret = Class(SDFThauCannon) {},
	},

	OnStopBeingBuilt = function(self,builder,layer)

		SAirUnit.OnStopBeingBuilt(self,builder,layer)
		self:SetScriptBit('RULEUTC_StealthToggle', true)	-- insure person stealth turned off
	
		self:CreatTheEffects()
	end,

	CreatTheEffects = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SJammerCrystalAmbient'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'AttachPoint', army, v):ScaleEmitter(0.75))
		end
		for k, v in EffectTemplate['OthuyAmbientEmanation'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'Effect02', army, v):ScaleEmitter(0.09))
		end
		for k, v in EffectTemplate['OthuyAmbientEmanation'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'Contrail_Right', army, v):ScaleEmitter(0.09))
		end
		for k, v in EffectTemplate['OthuyAmbientEmanation'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'Effect04', army, v):ScaleEmitter(0.09))
		end
	end,

}

TypeClass = BRPAT3GUNSHIP