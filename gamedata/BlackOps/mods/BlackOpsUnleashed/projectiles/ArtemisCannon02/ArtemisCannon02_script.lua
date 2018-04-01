
local DummyArtemisCannonProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').DummyArtemisCannonProjectile

ADFReactonCannon01 = Class(DummyArtemisCannonProjectile) {

    OnImpact = function(self, TargetType, TargetEntity)
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            # Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
           
			nukeProjectile = self:CreateProjectile('/mods/BlackOpsUnleashed/projectiles/ArtemisWarhead03/ArtemisWarhead03_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile:PassData(self.Data)
        end
        DummyArtemisCannonProjectile.OnImpact(self, TargetType, TargetEntity)
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        if self.ProjectileDamaged then
            # Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
           
			nukeProjectile = self:CreateProjectile('/mods/BlackOpsUnleashed/projectiles/ArtemisWarhead03/ArtemisWarhead03_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile:PassData(self.Data)
        end
        DummyArtemisCannonProjectile.DoTakeDamage(self, instigator, amount, vector, damageType)
    end,

    OnCreate = function(self)
        DummyArtemisCannonProjectile.OnCreate(self)
        local launcher = self:GetLauncher()
        if launcher and not launcher:IsDead() and launcher.EventCallbacks.ProjectileDamaged then
            self.ProjectileDamaged = {}
            for k,v in launcher.EventCallbacks.ProjectileDamaged do
                table.insert( self.ProjectileDamaged, v )
            end
        end
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self.KillThread = self:ForkThread(self.KillSelfThread)
    end,
    
    KillSelfThread = function(self)
        WaitSeconds(2)
        self:Destroy()
    end,
}
TypeClass = ADFReactonCannon01