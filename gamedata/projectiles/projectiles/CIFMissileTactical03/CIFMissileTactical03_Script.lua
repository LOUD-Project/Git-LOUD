--
-- Cybran "Loa" Tactical Missile, structure unit and sub launched variant of this projectile,
-- with a higher arc and distance based adjusting trajectory. Splits into child projectile 
-- if it takes enough damage.
--
local CLOATacticalMissileProjectile = import('/lua/cybranprojectiles.lua').CLOATacticalMissileProjectile
local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local VDist2 = VDist2

CIFMissileTactical03 = Class(CLOATacticalMissileProjectile) {

    NumChildMissiles = 3,

    OnCreate = function(self)
        CLOATacticalMissileProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self.Split = false
        self.MovementTurnLevel = 1
        self:ForkThread( self.MovementThread )        
    end,
    
    PassDamageData = function(self, damageData)
    
        CLOATacticalMissileProjectile.PassDamageData(self,damageData)

    end,    
    
    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        CreateLightParticle( self, -1, army, 3, 7, 'glow_03', 'ramp_fire_11' ) 
        
        --if I collide with terrain dont split
        if targetType != 'Projectile' then
            self.Split = true
        end
        
        CLOATacticalMissileProjectile.OnImpact(self, targetType, targetEntity)
    end,   
    
    OnDamage = function(self, instigator, amount, vector, damageType)
    
        if not self.Split and (amount >= self:GetHealth()) then
		
			local LOUDCOS = math.cos
			local LOUDSIN = math.sin
			
            self.Split = true        
            local vx, vy, vz = self:GetVelocity()
            local velocity = 7
            
            local ChildProjectileBP = '/projectiles/CIFMissileTacticalSplit01/CIFMissileTacticalSplit01_proj.bp'
            
            local angle = 6.28 / self.NumChildMissiles
            
            local spreadMul = 0.5  -- Adjusts the width of the dispersal        
		
            local launcherbp = self:GetLauncher():GetBlueprint()  
		
            self.ChildDamageData = table.copy(self.DamageData)

            self.ChildDamageData.DamageAmount = launcherbp.SplitDamage.DamageAmount or 0
            self.ChildDamageData.DamageRadius = launcherbp.SplitDamage.DamageRadius or 1   

            for i = 0, (self.NumChildMissiles - 1) do
                local xVec = vx + LOUDSIN(i*angle) * spreadMul
                local yVec = vy + LOUDCOS(i*angle) * spreadMul
                local zVec = vz + LOUDCOS(i*angle) * spreadMul 
                
                local proj = self:CreateChildProjectile(ChildProjectileBP)
                
                proj:SetVelocity(xVec,yVec,zVec)
                proj:SetVelocity(velocity)
                
                proj:PassDamageData(self.ChildDamageData)                        
            end
        end
        
        CLOATacticalMissileProjectile.OnDamage(self, instigator, amount, vector, damageType)
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
TypeClass = CIFMissileTactical03

