local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local StructureUnit = import('/lua/defaultunits.lua').RadarJammerUnit

local Flare     = import('/lua/cybranweapons.lua').CIFSmartCharge
local AntiTorp  = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon

local EffectUtil = import('/lua/EffectUtilities.lua')

XRS0205 = Class(CSeaUnit) {

    Weapons = {
        AntiTorp    = Class(AntiTorp) {},
        AntiFlare   = Class(Flare) {},
    },

    IntelEffects = {
		{ Bones = {'Radar_B01'}, Offset = {0,0.3,0 },Scale = 0.5,Type = 'Jammer01'},
    },

    OnIntelEnabled = function(self,intel)
	
        StructureUnit.OnIntelEnabled(self,intel)

        if not self.IntelFxOn then

			self.IntelEffectsBag = {}

			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle', 'Land', nil, 'IntelEffectsBag' )
            
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