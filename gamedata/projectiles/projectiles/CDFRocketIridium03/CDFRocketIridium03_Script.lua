local CIridiumRocketProjectile = import('/lua/cybranprojectiles.lua').CIridiumRocketProjectile

CDFRocketIridium03 = Class(CIridiumRocketProjectile) {

    OnCreate = function(self)
        CIridiumRocketProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
    end,

    OnImpact = function(self, targetType, targetEntity)
    
        CIridiumRocketProjectile.OnImpact(self, targetType, targetEntity)
        
        local army = self.Army
        
        CreateLightParticle( self, -1, army, 1.85, 1, 'glow_03', 'ramp_red_06' )
        CreateLightParticle( self, -1, army, 1, 2.6, 'glow_03', 'ramp_antimatter_02' )
        
        if targetType == 'Terrain' or targetType == 'Prop' then
            CreateDecal( self:GetPosition(), import('/lua/utilities.lua').GetRandomFloat(0.0,6.28), 'scorch_011_albedo', '', 'Albedo', 1.5, 1.5, 160, 120, army )
        end
    end,
}

TypeClass = CDFRocketIridium03
