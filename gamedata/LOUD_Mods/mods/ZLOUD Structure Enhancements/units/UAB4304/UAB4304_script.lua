local ARadarJammerUnit = import('/lua/aeonunits.lua').ARadarJammerUnit

UAB4304 = Class(ARadarJammerUnit) {

	AntiTeleportEffects = {
        '/effects/emitters/aeon_gate_02_emit.bp',
        '/effects/emitters/aeon_gate_03_emit.bp',
    },
	
    IntelEffects = {
		{
			Bones = {
				'UAB4203',
			},
			Offset = {
				0,
				3.5,
				0,
			},
			Type = 'Jammer01',
		},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        ARadarJammerUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
		
        self:DisableUnitIntel('CloakField')	-- this unit doesn't actually do cloaking --
		
        self.AmbientEffectsBag = {}


    end,

    OnScriptBitSet = function(self, bit)
	
        ARadarJammerUnit.OnScriptBitSet(self, bit)

        if bit == 0 then
		
        	self:ForkThread(self.AntiteleportEffects)
			
        	self:SetMaintenanceConsumptionActive()
			
		end
		
	end,
	
	OnScriptBitClear = function(self, bit)
	
        ARadarJammerUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then
		
        	self:SetMaintenanceConsumptionInactive()
			
			if self.AmbientEffectsBag then
			
            	for k, v in self.AmbientEffectsBag do
                	v:Destroy()
            	end
				
		    	self.AmbientEffectsBag = {}
				
			end
			
		end
		
	end,
	
	AntiteleportEffects = function(self)
	
        if self.AmbientEffectsBag then
		
            for k, v in self.AmbientEffectsBag do
                v:Destroy()
            end
			
		    self.AmbientEffectsBag = {}
			
		end
		
        for k, v in self.AntiTeleportEffects do
		
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'UAB4304', self:GetArmy(), v ):ScaleEmitter(0.4) )
			
        end
		
    end,	
	
}

TypeClass = UAB4304