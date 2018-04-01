
local GargEMPWarheadProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').GargEMPWarheadProjectile

GargEMPWarhead01 = Class(GargEMPWarheadProjectile) {
    FxSplashScale = 0.5,
    FxTrails = {},

    LaunchSound = 'Nuke_Launch',
    ExplodeSound = 'Nuke_Impact',
    AmbientSound = 'Nuke_Flight',
    InitialEffects = {'/effects/emitters/nuke_munition_launch_trail_02_emit.bp',},
    LaunchEffects = {'/effects/emitters/nuke_munition_launch_trail_03_emit.bp',},
    ThrustEffects = {'/effects/emitters/nuke_munition_launch_trail_04_emit.bp',},

    OnCreate = function(self)
        GargEMPWarheadProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
    end,

    CreateEffects = function( self, EffectTable, army, scale)
        for k, v in EffectTable do
            self.Trash:Add(CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(scale))
        end
    end,
    
    OnImpact = function(self, TargetType, TargetEntity)
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            # Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
    
            nukeProjectile = self:CreateProjectile('/mods/BlackOpsUnleashed/projectiles/GargEMPWarhead02/GargEMPWarhead02_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            local pos = self:GetPosition()
            pos[2] = pos[2] + 20
            Warp( nukeProjectile, pos)
            nukeProjectile:PassData(self.Data)
        end
        GargEMPWarheadProjectile.OnImpact(self, TargetType, TargetEntity)
    end,
    

}

TypeClass = GargEMPWarhead01
