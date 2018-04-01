local CLandUnit = import('/lua/cybranunits.lua').CLandUnit
local EffectUtil = import('/lua/EffectUtilities.lua')

local Buff = import('/lua/sim/Buff.lua')
local CybranBuffField = import('/lua/cybranweapons.lua').CybranBuffField

URL0307 = Class(CLandUnit) {

	BuffFields = {
	
		OpticalInterferenceField = Class(CybranBuffField){
		
			OnCreate = function(self)
				CybranBuffField.OnCreate(self)
			end,
		},
	},
	
    OnStopBeingBuilt = function(self,builder,layer)
        CLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionActive()
    end,
    
    IntelEffects = {
		{
			Bones = { 'AttachPoint'	},
			Offset = { 0, 0.25, 0 },
			Scale = 0.05,
			Type = 'Jammer01',
		},
    },
    
    OnIntelEnabled = function(self)
        CLandUnit.OnIntelEnabled(self)
		
        if self.IntelEffects then
			self.IntelEffectsBag = {}
			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		end
		
		self:GetBuffFieldByName('CybranOpticalDisruptionBuffField'):Enable()
    end,

    OnIntelDisabled = function(self)
        CLandUnit.OnIntelDisabled(self)
		
        EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
		
		self:GetBuffFieldByName('CybranOpticalDisruptionBuffField'):Disable()
    end,    
    
}

TypeClass = URL0307