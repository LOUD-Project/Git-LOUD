local CIFProtonBombProjectile = import('/lua/cybranprojectiles.lua').CIFProtonBombProjectile

CIFProtonBomb01 = Class(CIFProtonBombProjectile) {

    OnCreate = function(self)
        CIFProtonBombProjectile.OnCreate(self)
        self:ForkThread( self.MovementThread )
    end,

    MovementThread = function(self)        
        self.WaitTime = 0
        self:SetTurnRate(30)
        WaitSeconds(0)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()

        if dist > 50 then        
            WaitSeconds(0)
            self:SetTurnRate(30)
		elseif dist > 0 and dist <= 24 then  # 15 for aeon
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

TypeClass = CIFProtonBomb01