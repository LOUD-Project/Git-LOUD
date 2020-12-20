--
-- UEF Small Yield Nuclear Bomb
--
local TIFSmallYieldNuclearBombProjectile = import('/lua/terranprojectiles.lua').TArtilleryAntiMatterProjectile

TIFSmallYieldNuclearBomb01 = Class(TIFSmallYieldNuclearBombProjectile) {

	PolyTrail = '/effects/emitters/default_polytrail_04_emit.bp',
	FxLandHitScale = 0.5,
    FxUnitHitScale = 0.5,
	
    OnCreate = function(self)
        TIFSmallYieldNuclearBombProjectile.OnCreate(self)
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
				elseif dist > 0 and dist <= 22 then  
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

TypeClass = TIFSmallYieldNuclearBomb01