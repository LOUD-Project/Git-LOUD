local SExperimentalStrategicMissile = import('/lua/seraphimprojectiles.lua').SExperimentalStrategicMissile

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local CreateAttachedEmitter = CreateAttachedEmitter
local VDist2 = VDist2

SIFExperimentalStrategicMissile01 = Class(SExperimentalStrategicMissile) {
    FxSplashScale = 0.5,

    LaunchSound = 'Nuke_Launch',
    ExplodeSound = 'Nuke_Impact',
    AmbientSound = 'Nuke_Flight',

	InitialEffects = {
		'/effects/emitters/seraphim_expnuke_fxtrails_01_emit.bp',
		'/effects/emitters/seraphim_expnuke_fxtrails_02_emit.bp',
	},    
    ThrustEffects = {
		'/effects/emitters/seraphim_expnuke_fxtrails_01_emit.bp',
		'/effects/emitters/seraphim_expnuke_fxtrails_02_emit.bp',
	},
    LaunchEffects = {
		'/effects/emitters/seraphim_expnuke_fxtrails_01_emit.bp',
		'/effects/emitters/seraphim_expnuke_fxtrails_02_emit.bp',
	},

    
    OnCreate = function(self)

        SExperimentalStrategicMissile.OnCreate(self)

        local launcher = self:GetLauncher()

        if launcher and not launcher:IsDead() and launcher.EventCallbacks.ProjectileDamaged then

            self.ProjectileDamaged = {}

            for k,v in launcher.EventCallbacks.ProjectileDamaged do
                table.insert( self.ProjectileDamaged, v )
            end
        end 

        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self.MovementTurnLevel = 1
        self:ForkThread( self.MovementThread )
    end,    

    OnImpact = function(self, TargetType, TargetEntity)

        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then

            local myBlueprint = self:GetBlueprint()

            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
    
            nukeProjectile = self:CreateProjectile('/effects/entities/SeraphimNukeEffectController01/SeraphimNukeEffectController01_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)

            local pos = self:GetPosition()

            pos[2] = pos[2] + 20
            Warp( nukeProjectile, pos)
            nukeProjectile:PassDamageData(self.DamageData)
            nukeProjectile:PassData(self.Data)
        end

        SExperimentalStrategicMissile.OnImpact(self, TargetType, TargetEntity)
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)

        if self.ProjectileDamaged then
            for k,v in self.ProjectileDamaged do
                v(self)
            end
        end

        SExperimentalStrategicMissile.DoTakeDamage(self, instigator, amount, vector, damageType)
    end,

    CreateEffects = function( self, EffectTable, army, scale)
		
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        for k, v in EffectTable do
            self.Trash:Add(CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(scale))
        end
    end,

    MovementThread = function(self)
	
		local WaitSeconds = WaitSeconds
		
        local army = self:GetArmy()
        local launcher = self:GetLauncher()
		
        self.CreateEffects( self, self.InitialEffects, army, 3 )

        self:TrackTarget(false)

        WaitSeconds(2.5)

        self:SetCollision(true)

        WaitSeconds(5)

        self:TrackTarget(true) # Turn ~90 degrees towards target
        self:SetDestroyOnWater(true)
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

TypeClass = SIFExperimentalStrategicMissile01
