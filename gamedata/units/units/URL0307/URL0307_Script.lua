local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local EffectUtil = import('/lua/EffectUtilities.lua')

local Buff = import('/lua/sim/Buff.lua')

local BuffField = import('/lua/cybranweapons.lua').CybranBuffField

URL0307 = Class(CLandUnit) {

	BuffFields = {
		OpticalInterferenceField = Class(BuffField){},
	},
	
    OnStopBeingBuilt = function(self,builder,layer)
	
        CLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionActive()
		
    end,
    
    IntelEffects = {
        -- the buff field adds another instance of this kind of effect, so we keep this one a bit smaller
		{Bones = {'AttachPoint'}, Offset = {0,0,0},Scale = 0.1,Type = 'Jammer01' }
    },
    
    OnIntelEnabled = function(self,intel)
	
        CLandUnit.OnIntelEnabled(self,intel)
		
        if self.IntelEffects and not self.IntelFxOn then 
		
			self.IntelEffectsBag = {}
			
			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle', 'Land', nil, self.IntelEffectsBag )
			
			self.IntelFxOn = true
		end
		
		self:GetBuffFieldByName('CybranOpticalDisruptionBuffField'):Enable()
    end,

    OnIntelDisabled = function(self,intel)
	
        CLandUnit.OnIntelDisabled(self,intel)
		
        EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
		
		self.IntelFxOn = false
		
		self:GetBuffFieldByName('CybranOpticalDisruptionBuffField'):Disable()
    end,    
    
}

TypeClass = URL0307