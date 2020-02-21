-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cartillery01/cartillery01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Artillery: CArtillery01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local CIFMolecularResonanceShell = import('/lua/cybranprojectiles.lua').CIFMolecularResonanceShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

CArtillery03 = Class(CIFMolecularResonanceShell) {

	FxTrails = { 
			'/mods/BattlePack/effects/emitters/w_c_art02_p_03_glow_emit.bp',
			'/mods/BattlePack/effects/emitters/w_c_art02_p_04_glow_emit.bp',
			'/mods/BattlePack/effects/emitters/w_c_art02_p_05_glow_emit.bp',
			},

    FxTrailScale = 0.25,
	OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        CreateLightParticle( self, -1, army, 24, 5, 'glow_03', 'ramp_red_10' )
        CreateLightParticle( self, -1, army, 8, 16, 'glow_03', 'ramp_antimatter_02' )   
		CIFMolecularResonanceShell.OnImpact(self, targetType, targetEntity)  
	end,
	
    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
        for k, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
    FxNoneHitScale = 0.25,
    FxUnderWaterHitScale = 0.25,
    FxWaterHitScale = 0.25,
    FxLandHitScale = 0.25,
    FxUnitHitScale = 0.25,
}
TypeClass = CArtillery03