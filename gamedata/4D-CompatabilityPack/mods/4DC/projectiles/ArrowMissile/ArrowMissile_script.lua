#****************************************************************************
#**  File     :  /mods/4DC/projectiles/ArrowMissile/ArrowMissile_script.lua
#**
#**  Author(s):  EbolaSoup, Resin Smoker, Optimus Prime, Vissroid
#**
#**  Summary  :  Aeon Arrow Missile
#**
#**  Copyright © 2010 4DC  All rights reserved.
#****************************************************************************
local ArrowMissileProjectile = import('/mods/4DC/lua/4D_projectiles.lua').ArrowMissileProjectile

### defined constants
local waitTime = 0.1
local missileMaxSpeed = 40

ArrowMissile = Class(ArrowMissileProjectile) {

    OnCreate = function(self)
        ArrowMissileProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 0.5)
        self.HeartBeatThread = self:ForkThread(self.HeartBeatThread)
    end,

    HeartBeatThread = function(self) 
        self:SetAcceleration(5 + Random(1,5)) 
        while not self:BeenDestroyed() do
            local targetTrk = self:GetTrackingTarget()
            if targetTrk then 
                self:SetTurnRateByDist()
                self:SetMissileSpeed()    		
            end
            targetTrk = nil
            WaitSeconds(waitTime)
        end
    end,

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()     
        if dist > 40 and dist <= 50 then        
            self:SetTurnRate(80)
            self:ChangeMaxZigZag(20)
            self:ChangeZigZagFrequency(20)
        elseif dist > 30 and dist <= 40 then
            self:SetTurnRate(100)
            self:ChangeMaxZigZag(40)
            self:ChangeZigZagFrequency(40)
        elseif dist > 20 and dist <= 30 then
            self:SetTurnRate(120)
            self:ChangeMaxZigZag(60)
            self:ChangeZigZagFrequency(60)
        elseif dist > 10 and dist <= 20 then         
            self:SetTurnRate(140) 
            self:ChangeMaxZigZag(80) 
            self:ChangeZigZagFrequency(80) 
        elseif dist > 0 and dist <= 10 then         
            self:SetTurnRate(160) 
            self:ChangeMaxZigZag(100) 
            self:ChangeZigZagFrequency(100) 
            KillThread(self.HeartBeatThread)         
        end
    end,  

    SetMissileSpeed = function(self)
        if not self:BeenDestroyed() and self:GetTrackingTarget() then
            local myTarget = self:GetTrackingTarget():GetBlueprint().Air.MaxAirspeed
            local distMult = self:GetDistanceToTarget() * 0.01
            local speedComparison = (myTarget / missileMaxSpeed) + distMult
            self:SetVelocity(speedComparison * missileMaxSpeed)
        end
    end, 
}

TypeClass = ArrowMissile