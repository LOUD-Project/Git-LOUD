local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local StructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CIFSmartCharge = import('/lua/cybranweapons.lua').CIFSmartCharge

local AIFQuasarAntiTorpedoWeapon = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon

local EffectUtil = import('/lua/EffectUtilities.lua')

XRS0205 = Class(CSeaUnit) {

    Weapons = {

        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
        
        AntiFlare = Class(CIFSmartCharge) {},
    },

    IntelEffects = {
		{ Bones = {'Radar_B01'}, Offset = {0,0.3,0 },Scale = 0.5,Type = 'Jammer01'},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionActive()
    end,
   
    OnIntelEnabled = function(self,intel)
	
        StructureUnit.OnIntelEnabled(self,intel)

        if self.IntelEffects and not self.IntelFxOn then

			self.IntelEffectsBag = {}

			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle', 'Land', nil, self.IntelEffectsBag )
            
			self.IntelFxOn = true

		end

    end,

    OnIntelDisabled = function(self,intel)

        if self.IntelEffectsBag then

            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')

            self.IntelEffectsBag = nil

            self.IntelFxOn = nil
            
        end
	
        StructureUnit.OnIntelDisabled(self,intel)
		
    end,
    
    OnKilled = function( self, instigator, type, overkillRatio )

        -- turn off jammer --
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel()

        CSeaUnit.OnKilled( self, instigator, type, overkillRatio )
	
    end,
	
    
}

TypeClass = XRS0205