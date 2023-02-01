--
-- Terran Land-Based Cruise Missile
--
local TMissileCruiseProjectile = import('/lua/terranprojectiles.lua').TMissileCruiseProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
local SingleBeamProjectile = import('/lua/sim/defaultprojectiles.lua').SingleBeamProjectile
local ForkThread = ForkThread
local KillThread = KillThread
local WaitSeconds = WaitSeconds
local VDist2 = VDist2

TIFMissileCruise05 = Class(TMissileCruiseProjectile) {

    FxTrails = EffectTemplate.TMissileExhaust01,
    FxTrailOffset = -0.85,
    
    FxAirUnitHitScale = 0.65,
    FxLandHitScale = 0.65,
    FxNoneHitScale = 0.65,
    FxPropHitScale = 0.65,
    FxProjectileHitScale = 0.65,
    FxProjectileUnderWaterHitScale = 0.65,
    FxShieldHitScale = 0.65,
    FxUnderWaterHitScale = 0.65,
    FxUnitHitScale = 0.65,
    FxWaterHitScale = 0.65,
    FxOnKilledScale = 0.65,
    
    OnCreate = function(self)

        TMissileCruiseProjectile.OnCreate(self)

        self:SetCollisionShape('Sphere', 0, 0, 0, 2)

        self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)        

        self.WaitTime = 0.1

        self.Distance = self:GetDistanceToTarget()

        self:SetTurnRate(10)

        WaitSeconds(0.3)        

        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)

        local dist = self:GetDistanceToTarget()

        if dist >= self.Distance then

        	self:SetTurnRate(35)
            
            local var = math.random(2,15)
            WaitTicks(var)

        	WaitSeconds(1)

        	self:SetTurnRate(8)

        	self.Distance = self:GetDistanceToTarget()
        end

        if dist > 64 then        

            WaitSeconds(1.2)
            self:SetTurnRate(10)

        elseif dist > 32 and dist <= 64 then

			self:SetTurnRate(20)
			WaitSeconds(0.8)

        elseif dist > 12 and dist <= 32 then

            self:SetTurnRate(35)
            WaitSeconds(0.1)

		elseif dist > 0 and dist <= 12 then         

            self:SetTurnRate(100)   
            KillThread(self.MoveThread)         
        end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
    
    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,
}
TypeClass = TIFMissileCruise05

