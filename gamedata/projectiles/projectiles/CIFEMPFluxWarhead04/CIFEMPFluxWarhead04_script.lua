local CEMPFluxWarheadProjectile = import('/lua/cybranprojectiles.lua').CEMPFluxWarheadProjectile

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local VDist2 = VDist2

CIFEMPFluxWarhead04 = Class(CEMPFluxWarheadProjectile) {

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_06_emit.bp',
    FxSplashScale = 0.5,
    FxTrails = {},

    LaunchSound = 'Nuke_Launch',
    ExplodeSound = 'Nuke_Impact',
    AmbientSound = 'Nuke_Flight',

    InitialEffects = {'/effects/emitters/nuke_munition_launch_trail_02_emit.bp',},
    LaunchEffects = {'/effects/emitters/nuke_munition_launch_trail_03_emit.bp',},
    ThrustEffects = {'/effects/emitters/nuke_munition_launch_trail_04_emit.bp',},

    OnImpact = function(self, TargetType, TargetEntity)

        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then

            local myBlueprint = self:GetBlueprint()

            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end

            nukeProjectile = self:CreateProjectile('/projectiles/CIFEMPFluxWarhead02/CIFEMPFluxWarhead02_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile:PassDamageData(self.DamageData)
            nukeProjectile:PassData(self.Data)
        end

        CEMPFluxWarheadProjectile.OnImpact(self, TargetType, TargetEntity)
    end,

    OnCreate = function(self)

        CEMPFluxWarheadProjectile.OnCreate(self)

        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self.MovementTurnLevel = 1
        self:ForkThread( self.MovementThread )
    end,

    CreateEffects = function( self, EffectTable, army, scale)
        for k, v in EffectTable do
            self.Trash:Add(CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(scale))
        end
    end,

    MovementThread = function(self)
        local army = self:GetArmy()
        local launcher = self:GetLauncher()

        self.CreateEffects( self, self.InitialEffects, army, 1 )
        self:TrackTarget(false)

        WaitSeconds(2.5)		# Height

        self:SetCollision(true)
        self:SetDestroyOnWater(true)

        self.CreateEffects( self, self.LaunchEffects, army, 1 )

        WaitSeconds(2.5)

        self.CreateEffects( self, self.ThrustEffects, army, 3 )

        WaitSeconds(2.5)

        self:TrackTarget(true) # Turn ~90 degrees towards target
        self:SetTurnRate(47.36)

        WaitSeconds(2) 					# Now set turn rate to zero so nuke flies straight

        self:SetTurnRate(0)
        self:SetAcceleration(0.001)

        self.WaitTime = 0.5

        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)

        local dist = self:GetDistanceToTarget()

        if dist > 150 then        
            self:SetTurnRate(0)

        elseif dist > 75 and dist <= 150 then
            self.WaitTime = 0.3

        elseif dist > 32 and dist <= 75 then
            self.WaitTime = 0.1

        elseif dist < 32 then
            self:SetTurnRate(50)
        end
    end,

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
}

TypeClass = CIFEMPFluxWarhead04
