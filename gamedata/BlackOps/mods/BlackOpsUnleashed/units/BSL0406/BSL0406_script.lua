local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SeraphimBuffField = import('/lua/seraphimweapons.lua').SeraphimBuffField

local Buff = import('/lua/sim/Buff.lua')

local SAAShleoCannonWeapon = import('/lua/seraphimweapons.lua').SAAShleoCannonWeapon

BSL0406 = Class(SWalkingLandUnit) {

	BuffFields = {
	
		RegenField1 = Class(SeraphimBuffField){
		
			OnCreate = function(self)
				SeraphimBuffField.OnCreate(self)
			end,
		},

	},
	
    Weapons = {
        LaserTurret = Class(SAAShleoCannonWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
	
		SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
		-- we're not really cloaking so turn this off
		-- we just use the CloakField radius to show the area of effect
		self:DisableUnitIntel('CloakField')
		
		-- turn it on to start
		self:SetScriptBit('RULEUTC_ShieldToggle',true)		
	end,
	
	OnScriptBitSet = function(self, bit)
	
		if bit == 0 then
			self:GetBuffFieldByName('SeraphimRegenBuffField'):Enable()
		end
	
	end,
	
	OnScriptBitClear = function(self, bit)
	
		if bit == 0 then
			self:GetBuffFieldByName('SeraphimRegenBuffField'):Disable()
		end
	
	end,	
	

}
TypeClass = BSL0406