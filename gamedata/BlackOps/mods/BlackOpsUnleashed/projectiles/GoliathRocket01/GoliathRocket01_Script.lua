local MiniRocket04PRojectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').MiniRocket04PRojectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
local SingleBeamProjectile = import('/lua/sim/defaultprojectiles.lua').SingleBeamProjectile

AWMissileCruise01 = Class(MiniRocket04PRojectile) {
	InitialEffects = {'/effects/emitters/nuke_munition_launch_trail_02_emit.bp',},
    LaunchEffects = {
        '/effects/emitters/nuke_munition_launch_trail_03_emit.bp',
        '/effects/emitters/nuke_munition_launch_trail_05_emit.bp',
        '/effects/emitters/nuke_munition_launch_trail_07_emit.bp',
    },
    ThrustEffects = {'/effects/emitters/nuke_munition_launch_trail_04_emit.bp',
                     '/effects/emitters/nuke_munition_launch_trail_06_emit.bp',
    },
	
    FxTrails = EffectTemplate.TMissileExhaust01,
    FxImpactUnit = EffectTemplate.TAntiMatterShellHit01,
    FxImpactLand = EffectTemplate.TAntiMatterShellHit01,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit01,
	FxImpactShield = EffectTemplate.TAntiMatterShellHit01,
    FxAirUnitHitScale = 0.6,
    FxLandHitScale = 0.6,
    FxNoneHitScale = 0.6,
    FxPropHitScale = 0.6,
    FxProjectileHitScale = 0.6,
    FxProjectileUnderWaterHitScale = 0.6,
    FxShieldHitScale = 0.6,
    FxUnderWaterHitScale = 0.6,
    FxUnitHitScale = 0.6,
    FxWaterHitScale = 0.6,
    FxOnKilledScale = 0.6,
    
    OnCreate = function(self)
        MiniRocket04PRojectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)        
        self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)        
        self.WaitTime = 0.1
        self:SetTurnRate(8)
        WaitSeconds(0.1)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,
	CreateEffects = function( self, EffectTable, army, scale)
        for k, v in EffectTable do
            self.Trash:Add(CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(scale))
        end
    end,

    SetTurnRateByDist = function(self)
        --local dist = self:GetDistanceToTarget()
		local army = self:GetArmy()
		local dist = VDist3(self:GetPosition(), self:GetCurrentTargetPosition())
		--LOG('Distance : ', dist)
        if dist > 50 then        
            #Freeze the turn rate as to prevent steep angles at long distance targets
			self:SetTurnRate(15)
            WaitSeconds(1)
            --self:SetTurnRate(90)
			self:SetTurnRate(50)
        elseif dist > 35 and dist <= 50 then
			# Increase check intervals
			self:SetTurnRate(15)
			WaitSeconds(0.1)
            self:SetTurnRate(90)
        elseif dist > 25 and dist <= 35 then
			self:SetTurnRate(50)
			WaitSeconds(0.1)
            self:SetTurnRate(90)
			--speed boost!! and effects
			self.CreateEffects( self, self.InitialEffects, army, 1 )
			self.CreateEffects( self, self.LaunchEffects, army, 1 )
			self.CreateEffects( self, self.ThrustEffects, army, 3 )
			self:SetMaxSpeed(70)
			self:SetAcceleration(50)
			self:SetTurnRate(150)
        elseif dist > 8 and dist <= 25 then
			self:SetTurnRate(180)
            WaitSeconds(0.1)
            self:SetTurnRate(360)
		elseif dist > 0 and dist <= 8 then
			# Further increase check intervals            
            self:SetTurnRate(720)   
		end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
    
    OnEnterWater = function(self)
        MiniRocket04PRojectile.OnEnterWater(self)
        self:SetDestroyOnWater(true)
    end,
}
TypeClass = AWMissileCruise01