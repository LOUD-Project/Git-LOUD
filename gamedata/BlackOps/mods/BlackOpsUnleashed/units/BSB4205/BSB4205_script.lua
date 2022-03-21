local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local Buff = import('/lua/sim/Buff.lua')

local SeraphimBuffField = import('/lua/seraphimweapons.lua').SeraphimBuffField


BSB4205 = Class(SStructureUnit) {
	
	BuffFields = {
	
		RegenField = Class(SeraphimBuffField){
		
			OnCreate = function(self)
				SeraphimBuffField.OnCreate(self)
			end,
		},
	},

    OnStopBeingBuilt = function(self)
 
        SStructureUnit.OnStopBeingBuilt(self)

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