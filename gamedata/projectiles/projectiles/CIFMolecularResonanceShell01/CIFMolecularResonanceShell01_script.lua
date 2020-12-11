--
-- Cybran Artillery Projectile
--

local CIFMolecularResonanceShell = import('/lua/cybranprojectiles.lua').CIFMolecularResonanceShell
local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateLightParticle = CreateLightParticle

CIFMolecularResonanceShell01 = Class(CIFMolecularResonanceShell) {
	
	OnImpact = function(self, targetType, targetEntity)
	
        local army = self:GetArmy()
		local CreateLightParticle = CreateLightParticle
		
        CreateLightParticle( self, -1, army, 24, 5, 'glow_03', 'ramp_red_10' )
        CreateLightParticle( self, -1, army, 8, 16, 'glow_03', 'ramp_antimatter_02' )   
		CIFMolecularResonanceShell.OnImpact(self, targetType, targetEntity)  
	end,
	
    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
        for k, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}

TypeClass = CIFMolecularResonanceShell01