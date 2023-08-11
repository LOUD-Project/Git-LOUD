local SLaanseTacticalMissile = import('/lua/seraphimprojectiles.lua').SLaanseTacticalMissile

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local VDist2 = VDist2

SIFLaanseTacticalMissile04 = Class(SLaanseTacticalMissile) {
    
    OnCreate = function(self)
        SLaanseTacticalMissile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self:ForkThread( self.MovementThread )
    end,

    MovementThread = function(self)        

        self.WaitTime = 0.1
        self:SetTurnRate(8)

        WaitSeconds(0.3)        

        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)

        local dist = self:GetDistanceToTarget()

        if dist > 50 then        

            WaitSeconds(2)
            self:SetTurnRate(20)

        elseif dist > 128 and dist <= 213 then

			self:SetTurnRate(30)
			WaitSeconds(1.5)
            self:SetTurnRate(30)

        elseif dist > 43 and dist <= 107 then

            WaitSeconds(0.3)
            self:SetTurnRate(50)

		elseif dist > 0 and dist <= 43 then

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
}
TypeClass = SIFLaanseTacticalMissile04

