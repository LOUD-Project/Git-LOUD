------------------------------------------------------------------------------
--  File     :  /mods/4DC/lua/4D-EffectTemplates.lua
--
--  Author(s):  EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--
--  Summary  :  Definition of 4th-D special effects
--
--  Copyright © 2010 4DC  All rights reserved.
------------------------------------------------------------------------------

TableCat = import('/lua/utilities.lua').TableCat
EmtBpPath = '/effects/emitters/'
ModPath = '/mods/4DC/effects/Emitters/'

-------------------------------------------------------------------------
-- Emitter for Aeon UAL0204 concussion ring
-------------------------------------------------------------------------
ConcussionRing = {
	ModPath .. 'ground_effect_concussion_ring_sml_emit.bp',
}

-------------------------------------------------------------------------
-- Emitter for Arc Beam for the Aeon BFG cannon
-------------------------------------------------------------------------
ArcBeam = {
	ModPath .. 'bfg_arc_beam_emit.bp',
}

-------------------------------------------------------------------------
-- Emitter for Seraphim XSL031A lightning weapon 
-------------------------------------------------------------------------
LightingStrikeBeam = {
	ModPath .. 'xsl031a_lightning_beam_emit.bp',
}

-------------------------------------------------------------------------
--  TERRAN MAGMA CANNON EMITTERS:  Hacked by Ebola Soup for Magma Cannon from Ionized Plasma Gatling Cannon
-------------------------------------------------------------------------
TMagmaCannonHit01 = { 
    EmtBpPath .. 'napalm_hvy_thick_smoke_emit.bp',
    EmtBpPath .. 'napalm_hvy_01_emit.bp',
    ModPath .. 'balrog_proton_bomb_hit_01_emit.bp',
    ModPath .. 'balrog_antimatter_hit_01_emit.bp',		
    EmtBpPath .. 'antimatter_hit_02_emit.bp',	    	     
    ModPath .. 'balrog_antimatter_hit_06_emit.bp',	
    EmtBpPath .. 'antimatter_hit_07_emit.bp',	    
    EmtBpPath .. 'antimatter_hit_09_emit.bp',	     
    EmtBpPath .. 'antimatter_hit_11_emit.bp',	    
	EmtBpPath .. 'antimatter_ring_04_emit.bp',	    	
}
TMagmaCannonHit02 = { 
    EmtBpPath .. 'antimatter_hit_09_emit.bp',	   
}

TMagmaCannonHit03 = { 
    EmtBpPath .. 'antimatter_hit_03_emit.bp', 	
    EmtBpPath .. 'explosion_fire_sparks_01_emit.bp',
    EmtBpPath .. 'flash_01_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
}

TMagmaCannonUnitHit = TableCat( TMagmaCannonHit01, TMagmaCannonHit03 )

TMagmaCannonHit = TableCat( TMagmaCannonHit01, TMagmaCannonHit02 )

TMagmaCannonMuzzleFlash = {
    ModPath .. 'balrog_magma_cannon_muzzle_flash_01_emit.bp',
    ModPath .. 'balrog_magma_cannon_muzzle_flash_02_emit.bp',
}
TMagmaCannonFxTrails = {
    ModPath .. 'balrog_magma_projectile_fxtrail_01_emit.bp', 
}

TMagmaCannonPolyTrails = {
    ModPath .. 'balrog_missile_smoke_polytrail_01_emit.bp', 
    ModPath .. 'balrog_missile_smoke_polytrail_02_emit.bp', 
}