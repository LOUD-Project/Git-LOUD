local CArtilleryProtonProjectile = import('/lua/cybranprojectiles.lua').CArtilleryProtonProjectile

local DamageArea = DamageArea
local CreateLightParticle = CreateLightParticle

CIFArtilleryProton01 = Class(CArtilleryProtonProjectile) {

    OnImpact = function(self, targetType, targetEntity)
        CArtilleryProtonProjectile.OnImpact(self, targetType, targetEntity)
		
        local army = self:GetArmy()
		
        CreateLightParticle( self, -1, army, 4, 2, 'glow_03', 'ramp_red_06' )
        CreateLightParticle( self, -1, army, 1, 4, 'glow_03', 'ramp_antimatter_02' )
    end,

    ForceThread = function(self, pos)
		
        DamageArea(self, pos, 7, 1, 'Force', true)
        WaitTicks(2)
        DamageArea(self, pos, 7, 1, 'Force', true)
        DamageRing(self, pos, 3, 7, 1, 'Fire', true)
    end,
}
TypeClass = CIFArtilleryProton01