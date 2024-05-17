local MIRVChild01Projectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').MIRVChild01Projectile

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

MIRVChild01 = Class(MIRVChild01Projectile) {

    OnCreate = function(self)
        MIRVChild01Projectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)
    end,
    
	OnImpact = function(self, TargetType, targetEntity)
        local rotation = RandomFloat(0,6.28)
        
        CreateDecal(self:GetPosition(), rotation, 'scorch_004_albedo', '', 'Albedo', 8, 8, 280, 20, self:GetArmy())
 
        MIRVChild01Projectile.OnImpact( self, TargetType, targetEntity )
    end,	
}

TypeClass = MIRVChild01