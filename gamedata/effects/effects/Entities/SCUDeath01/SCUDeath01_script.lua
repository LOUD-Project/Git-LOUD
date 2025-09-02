local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell

local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

SCUDeath01 = Class(NullShell) {

    OnCreate = function(self)

        NullShell.OnCreate(self)

        local myBlueprint = self:GetBlueprint()

        if myBlueprint.Audio.NukeExplosion then
            self:PlaySound(myBlueprint.Audio.NukeExplosion)
        end

        self:ForkThread(self.EffectThread)
    end,
     
    PassDamageData = function(self, damageData)

        NullShell.PassDamageData(self, damageData)

        local instigator = self:GetLauncher()

        if instigator == nil then
            instigator = self
        end

        self:DoDamage( instigator, self.DamageData, nil )  
    end,
    
    OnImpact = function(self, targetType, targetEntity)
        self:Destroy()
    end,

    EffectThread = function(self)

        local army = self:GetArmy()
        local position = self:GetPosition()

        self:ForkThread(self.CreateOuterRingWaveSmokeRing)

        CreateLightParticle(self, -1, army, 10, 4, 'glow_02', 'ramp_red_02')
        WaitSeconds( 0.25 )
        CreateLightParticle(self, -1, army, 10, 20, 'glow_03', 'ramp_fire_06')
        WaitSeconds( 0.55 )
        
        CreateLightParticle(self, -1, army, 20, 250, 'glow_03', 'ramp_nuke_04')
        
        local orientation = RandomFloat( 0, 2 * math.pi )

        CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', 20, 20, 800, 300, army)
        CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', 20, 20, 800, 300, army)       
        CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', 20, 20, 130, 180, army)    

        DamageRing(self, position, 0.1, 15, 1, 'Force', true)

        WaitSeconds(0.1)

        DamageRing(self, position, 0.1, 15, 1, 'Force', true)
    end,
    
    CreateOuterRingWaveSmokeRing = function(self)

        local sides = 10
        local angle = 6.28 / sides
        local velocity = 2
        local OffsetMod = 4
        local projectiles = {}

        for i = 0, (sides-1) do
            local X = math.sin(i*angle)
            local Z = math.cos(i*angle)
            local proj =  self:CreateProjectile('/effects/entities/SCUDeathShockwave01/SCUDeathShockwave01_proj.bp', X * OffsetMod , 2, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity)
            table.insert( projectiles, proj )
        end  
        
        WaitSeconds( 3 )

        # Slow projectiles down to normal speed
        for k, v in projectiles do
            v:SetAcceleration(-0.45)
        end         
    end,    
}

TypeClass = SCUDeath01

