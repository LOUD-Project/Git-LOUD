--------------------------------------------------------------------------------
-- Summary  :  Cybran Cloakable Mobile Radar Stealth Script
--------------------------------------------------------------------------------
local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local EffectUtil = import('/lua/EffectUtilities.lua')

SRL0316 = Class(CLandUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionActive()

        --These start enabled, so before going to InvisState, disabled them.. they'll be reenabled shortly
        self:DisableUnitIntel('RadarStealth')
		self:DisableUnitIntel('SonarStealth')
		self:DisableUnitIntel('Cloak')
		
		self.Cloaked = false
		
        ChangeState( self, self.InvisState ) -- If spawned in we want the unit to be invis, normally the unit will immediately start moving
		
        self:EnableUnitIntel('RadarStealth')
		self:EnableUnitIntel('SonarStealth')
		
    end,

    IntelEffects = {
		{ Bones = {'AttachPoint'}, Scale = 0.4, Type = 'Jammer01'	},
    },

    OnIntelEnabled = function(self,intel)
	
        CLandUnit.OnIntelEnabled(self,intel)

        if intel == 'RadarStealthField' and self.IntelEffects and not self.IntelFxOn then
		
			self.IntelEffectsBag = {}

			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle', 'Land', nil, self.IntelEffectsBag )
			
			self.IntelFxOn = true

		end

    end,

    OnIntelDisabled = function(self,intel)
	
        CLandUnit.OnIntelDisabled(self,intel)
        
        if intel == 'RadarStealthField' then

            -- this will purge the IntelEffectsBag
            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            
            self.IntelEffectsBag = nil
		
            self.IntelFxOn = false
            
        end
		
    end,
	
    
    InvisState = State() {
    
        Main = function(self)
        
            self.Cloaked = false
            
            local bp = self:GetBlueprint()
            
            if bp.Intel.StealthWaitTime then
                WaitSeconds( bp.Intel.StealthWaitTime )
            end

			self:EnableUnitIntel('Cloak')
			self.Cloaked = true
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
        
            if new != 'Stopped' then
                ChangeState( self, self.VisibleState )
            end
            
            CLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
    
    VisibleState = State() {
    
        Main = function(self)
        
            if self.Cloaked then
			    self:DisableUnitIntel('Cloak')
			end
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
        
            if new == 'Stopped' then
                ChangeState( self, self.InvisState )
            end
            
            CLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },	
}

TypeClass = SRL0316
