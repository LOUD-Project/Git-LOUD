local StructureUnit = import('/lua/defaultunits.lua').StructureUnit

local Buff = import('/lua/sim/Buff.lua')
local BuffField = import('/lua/sim/BuffField.lua').BuffField

BSB4205 = Class(StructureUnit) {
	
	BuffFields = {
	
		RegenField = Class(BuffField){},
	},

    OnStopBeingBuilt = function(self)
 
        StructureUnit.OnStopBeingBuilt(self)

		-- we're not really cloaking so turn this off
		-- we just use the CloakField radius to show the area of effect
		self:DisableUnitIntel('CloakField')
		
		-- turn on the regen field to start with
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
TypeClass = BSB4205