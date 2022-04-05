local SLandFactoryUnit = import('/lua/seraphimunits.lua').SLandFactoryUnit

local LOUDATTACHEMITTER = CreateAttachedEmitter 

BSB2402 = Class(SLandFactoryUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
	
		SLandFactoryUnit.OnStopBeingBuilt(self,builder,layer)
		
		local army = self.Army
		local scale = 0.35

    	self.EffectsBag = {}

        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_01_emit.bp'):ScaleEmitter(scale)		-- glow
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_02_emit.bp'):ScaleEmitter(scale)		-- plasma pillar
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_03_emit.bp'):ScaleEmitter(scale)		-- darkening pillar
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_04_emit.bp'):ScaleEmitter(scale)		-- ring outward dust/motion
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_05_emit.bp'):ScaleEmitter(scale)		-- plasma pillar move
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_06_emit.bp'):ScaleEmitter(scale)		-- darkening pillar move
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_07_emit.bp'):ScaleEmitter(scale)		-- bright line at bottom / right side
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_08_emit.bp'):ScaleEmitter(scale)		-- bright line at bottom / left side
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_09_emit.bp'):ScaleEmitter(scale)		-- small flickery dots rising
        LOUDATTACHEMITTER(self,'Effect01',army, '/effects/emitters/seraphim_rift_arch_base_10_emit.bp'):ScaleEmitter(scale)		-- distortion
        LOUDATTACHEMITTER(self,'FX_07',army, '/effects/emitters/seraphim_rift_arch_top_01_emit.bp'):ScaleEmitter(scale)			-- top part glow
        LOUDATTACHEMITTER(self,'FX_07',army, '/effects/emitters/seraphim_rift_arch_top_02_emit.bp'):ScaleEmitter(scale)			-- top part plasma
        LOUDATTACHEMITTER(self,'FX_07',army, '/effects/emitters/seraphim_rift_arch_top_03_emit.bp'):ScaleEmitter(scale)			-- top part darkening
        LOUDATTACHEMITTER(self,'FX_01',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_02',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_03',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_04',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_05',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_06',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_01_emit.bp'):ScaleEmitter(scale)		-- glow
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_02_emit.bp'):ScaleEmitter(scale)		-- plasma pillar
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_03_emit.bp'):ScaleEmitter(scale)		-- darkening pillar
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_04_emit.bp'):ScaleEmitter(scale)		-- ring outward dust/motion
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_05_emit.bp'):ScaleEmitter(scale)		-- plasma pillar move
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_06_emit.bp'):ScaleEmitter(scale)		-- darkening pillar move
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_07_emit.bp'):ScaleEmitter(scale)		-- bright line at bottom / right side
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_08_emit.bp'):ScaleEmitter(scale)		-- bright line at bottom / left side
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_09_emit.bp'):ScaleEmitter(scale)		-- small flickery dots rising
        LOUDATTACHEMITTER(self,'Effect03',army, '/effects/emitters/seraphim_rift_arch_base_10_emit.bp'):ScaleEmitter(scale)		-- distortion
        LOUDATTACHEMITTER(self,'FX_14',army, '/effects/emitters/seraphim_rift_arch_top_01_emit.bp'):ScaleEmitter(scale)			-- top part glow
        LOUDATTACHEMITTER(self,'FX_14',army, '/effects/emitters/seraphim_rift_arch_top_02_emit.bp'):ScaleEmitter(scale)			-- top part plasma
        LOUDATTACHEMITTER(self,'FX_14',army, '/effects/emitters/seraphim_rift_arch_top_03_emit.bp'):ScaleEmitter(scale)			-- top part darkening
        LOUDATTACHEMITTER(self,'FX_08',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_09',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_10',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_11',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_12',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        LOUDATTACHEMITTER(self,'FX_13',army, '/effects/emitters/seraphim_rift_arch_edge_01_emit.bp'):ScaleEmitter(scale)		-- line wall
        

	end,          


	OnKilled = function(self, instigator, type, overkillRatio)
	
        SLandFactoryUnit.OnKilled(self, instigator, type, overkillRatio)        

    end,
}


TypeClass = BSB2402

