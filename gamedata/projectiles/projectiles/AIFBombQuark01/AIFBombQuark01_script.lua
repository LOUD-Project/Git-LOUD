local AQuarkBombProjectile = import('/lua/aeonprojectiles.lua').AQuarkBombProjectile

AIFBombQuark01 = Class(AQuarkBombProjectile) {

    OnCreate = function(self)

        AQuarkBombProjectile.OnCreate(self)

        self:ForkThread( self.MovementThread )
    end,

    MovementThread = function(self)        

        self.WaitTime = 0
        self:SetTurnRate(200)

        WaitSeconds(0)        

        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)

        local dist = self:GetDistanceToTarget()

        if dist > 40 then        

            WaitSeconds(0)

            self:SetTurnRate(50)

		elseif dist > 0 and dist <= 15 then  

            self:SetTurnRate(0)   

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

TypeClass = AIFBombQuark01