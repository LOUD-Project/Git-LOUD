#****************************************************************************
#**
#**  File     :  /data/lua/modules/EffectTemplates.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  Generic templates for commonly used effects
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

TableCat = import('/lua/utilities.lua').TableCat
EmtBpPath = '/effects/emitters/'
EmtBpPath2 = '/mods/BlackOpsACUs/effects/emitters/'
EmitterTempEmtBpPath = '/effects/emitters/temp/'

EMETNukeRings01 = {
	EmtBpPath .. 'nuke_concussion_ring_01_emit.bp',
	EmtBpPath .. 'nuke_concussion_ring_02_emit.bp',
}
EMETNukeFlavorPlume01 = { EmtBpPath .. 'nuke_smoke_trail01_emit.bp', }
EMETNukeGroundConvectionEffects01 = { EmtBpPath .. 'nuke_mist_01_emit.bp', }
XEMETNukeBaseEffects01 = { EmtBpPath .. 'nuke_base03_emit.bp', }
EMETNukeBaseEffects02 = { EmtBpPath .. 'nuke_base05_emit.bp', }
EMETNukeHeadEffects01 = { EmtBpPath .. 'nuke_plume_01_emit.bp', }
EMETNukeHeadEffects02 = { 
	EmtBpPath .. 'nuke_head_smoke_03_emit.bp',
	EmtBpPath .. 'nuke_head_smoke_04_emit.bp',
		
}
EMETNukeHeadEffects03 = { EmtBpPath .. 'nuke_head_fire_01_emit.bp', }
PDLaserEffect = { EmtBpPath2 .. 'quantum_generator_beam_02_emit.bp', }