-----------------------------------------------------------------------------
--  File     : /projectiles/cybran/ctacticalmissile01/ctacticalmissile01_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Cybran (SHORT RANGE) Tactical Missile: CTacticalMissile01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
MultiPolyTrailProjectile = import('/lua/sim/DefaultProjectiles.lua').MultiPolyTrailProjectile
OTacticalMissile01 = Class(MultiPolyTrailProjectile) {

   FxTrail = '/mods/BattlePack/effects/emitters/w_c_rkt01_p_02_glow_emit.bp',
    FxTrailOffset = 0,

        PolyTrails = {
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_01_polytrail_emit.bp',
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_07_polytrail_emit.bp',
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_08_polytrail_emit.bp',
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_09_polytrail_emit.bp',
        },
    PolyTrailOffset = {0,0,0,0},

    OnCreate = function(self)
        MultiPolyTrailProjectile.OnCreate(self)
        self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)        
        self.WaitTime = 0.1
        self.Distance = self:GetDistanceToTarget()
        self:SetTurnRate(8)
        WaitSeconds(0.3)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > self.Distance then
        	self:SetTurnRate(75)
        	WaitSeconds(3)
        	self:SetTurnRate(8)
        	self.Distance = self:GetDistanceToTarget()
        end
        #Get the nuke as close to 90 deg as possible
        if dist > 50 then        
            #Freeze the turn rate as to prevent steep angles at long distance targets
            WaitSeconds(2)
            self:SetTurnRate(10)
        elseif dist > 30 and dist <= 50 then
						# Increase check intervals
						self:SetTurnRate(12)
						WaitSeconds(1.5)
            self:SetTurnRate(12)
        elseif dist > 10 and dist <= 25 then
						# Further increase check intervals
            WaitSeconds(0.3)
            self:SetTurnRate(50)
				elseif dist > 0 and dist <= 10 then
						# Further increase check intervals            
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
TypeClass = OTacticalMissile01