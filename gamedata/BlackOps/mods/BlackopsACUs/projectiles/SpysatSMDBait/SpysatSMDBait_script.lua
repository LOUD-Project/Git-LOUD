#****************************************************************************
#
#    File     :  /data/Projectiles/ADFReactonCannnon01/ADFReactonCannnon01_script.lua
#    Author(s): Jessica St.Croix, Gordon Duclos
#
#    Summary  : Aeon Reacton Cannon Area of Effect Projectile
#
#    Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local DummyArtemisCannonProjectile = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectUtil = import('/lua/EffectUtilities.lua') 

SpysatSMDBait = Class(DummyArtemisCannonProjectile) {

    OnImpact = function(self, TargetType, TargetEntity)
        DummyArtemisCannonProjectile.OnImpact(self, TargetType, TargetEntity)
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        DummyArtemisCannonProjectile.DoTakeDamage(self, instigator, amount, vector, damageType)
        if not self.Parent:IsDead() then
			self.Parent:Kill()
		end
    end,

    OnCreate = function(self)
        DummyArtemisCannonProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
		self.KillThread = self:ForkThread(self.Verification)
        self.KillThread = self:ForkThread(self.KillSelfThread)
    end,
    
    KillSelfThread = function(self)
        WaitSeconds(20)
        if not self.Parent:IsDead() then
            self.Parent:ProjSpawn()
        end
        self:Destroy()
    end,
	
    Parent = nil,
    SetParent = function(self, parent, projName)
        self.Parent = parent
        self.Proj = projName
    end,
   
    Verification = function(self)
        while not self:BeenDestroyed() and not self.Parent:IsDead() do
            local unitLoc = self.Parent:GetPosition('Turret_Barrel_Muzzle')
			local projmod = unitLoc[2] - 1
			local destination = {unitLoc[1], projmod, unitLoc[3]} 
            Warp(self, destination)
            WaitSeconds(1)
        end
    end,

    OnDestroyed = function(self)
        DummyArtemisCannonProjectile.OnDestroyed(self, instigator, type, overkillRatio)
    end,  

    OnLostTarget = function(self)

    end,

	
}
TypeClass = SpysatSMDBait