local CIridiumRocketProjectile = import('/lua/cybranprojectiles.lua').CIridiumRocketProjectile

local Random = Random

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end

local CreateLightParticle = CreateLightParticle

CDFRocketIridium03 = Class(CIridiumRocketProjectile) {

    OnCreate = function(self)
        CIridiumRocketProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.8)
    end,

    OnImpact = function(self, targetType, targetEntity)
    
        CIridiumRocketProjectile.OnImpact(self, targetType, targetEntity)
        
        local army = self.Army
     
        CreateLightParticle( self, -1, army, 1.6, 1, 'glow_03', 'ramp_red_06' )
        
        CreateLightParticle( self, -1, army, 1, 2.1, 'glow_03', 'ramp_antimatter_02' )

        if targetType == 'Terrain' or targetType == 'Prop' then
        
            if Random(1,2) == 1 then
                CreateDecal( self:GetPosition(), GetRandomFloat(0,6.28), 'scorch_011_albedo', '', 'Albedo', 1.6, 1.6, 100, 42, army )
            end
        end
    end,

}

TypeClass = CDFRocketIridium03
