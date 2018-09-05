local CLandUnit = import('/lua/cybranunits.lua').CLandUnit
local EffectUtil = import('/lua/EffectUtilities.lua')

URL0306 = Class(CLandUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionActive()
    end,
    
    IntelEffects = {
	
		{ Bones = { 'AttachPoint' }, Offset = { 0, 0.3, 0 }, Scale = 0.2, Type = 'Jammer01' },

    },
    
    OnIntelEnabled = function(self)
	
        CLandUnit.OnIntelEnabled(self)
		
        if self.IntelEffects and not self.IntelFxOn then
		
			self.IntelEffectsBag = {}
			
			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
			
			self.IntelFxOn = true
			
		end
    end,

    OnIntelDisabled = function(self)
	
        CLandUnit.OnIntelDisabled(self)
		
        EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
		
		self.IntelFxOn = false
		
    end,    
    
}

TypeClass = URL0306