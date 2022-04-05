local SAirUnit = import('/lua/defaultunits.lua').AirUnit

SAirUnit = import('/mods/4DC/lua/CustomAbilities/4D_ShieldDroneSuperClass/4D_ShieldDroneSuperClass.lua').AutoSelectShieldDrone( SAirUnit )

local LOUDINSERT = table.insert

XSA0201 = Class(SAirUnit) {

    OnStopBeingBuilt = function(self, builder, layer)
	
        SAirUnit.OnStopBeingBuilt(self, builder, layer)
		
        -- Hide unwanted bones
        self:HideBone('xsa0201', false)
		
        -- Initialize FX tables
        self.SphereFxBag = {}
		
        -- Animation effects
        self.Trash:Add(CreateRotator(self, 'orb', 'x', nil, 0, 15, 80 + Random(-20, 20)))
        self.Trash:Add(CreateRotator(self, 'orb', 'y', nil, 0, 15, 80 + Random(-20, 20)))
        self.Trash:Add(CreateRotator(self, 'orb', 'z', nil, 0, 15, 80 + Random(-20, 20)))
		
        -- Start FX
        self:InitializeFX()
		
    end, 
    
    InitializeFX = function(self)
	
     -- Sphere energy effects
        local FX1 = CreateAttachedEmitter(self, 'orb', self.Army, '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_02_emit.bp'):ScaleEmitter(0.5)-- Bright Blue Glow                      
        local FX2 = CreateAttachedEmitter(self, 'orb', self.Army, '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_03_emit.bp'):ScaleEmitter(0.4)-- Dark FX Aura                             
        local FX3 = CreateAttachedEmitter(self, 'orb', self.Army, '/effects/emitters/seraphim_experimental_phasonproj_fxtrails_06_emit.bp'):ScaleEmitter(0.25)-- Electricity Sphere Aura 
		
     -- Save FX into table for later use
        LOUDINSERT( self.SphereFxBag, FX1)
        LOUDINSERT( self.SphereFxBag, FX2)
        LOUDINSERT( self.SphereFxBag, FX3)
		
     -- Clean up       
        self.Trash:Add(FX1, FX2, FX3)
		
    end,
	
}

TypeClass = XSA0201