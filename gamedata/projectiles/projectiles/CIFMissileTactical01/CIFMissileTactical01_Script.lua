--
-- Cybran "Loa" Tactical Missile, mobile unit launcher variant of this missile,
-- lower and straighter trajectory. Splits into child projectile if it takes enough
-- damage.
--

local CLOATacticalMissileProjectile = import('/lua/cybranprojectiles.lua').CLOATacticalMissileProjectile
local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

CIFMissileTactical01 = Class(CLOATacticalMissileProjectile) {

    NumChildMissiles = 3,

    OnCreate = function(self)
	
        CLOATacticalMissileProjectile.OnCreate(self)
		
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)
        self.Split = false
		
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
        if dist > 50 then        
            #Freeze the turn rate as to prevent steep angles at long distance targets
            WaitSeconds(2)
            self:SetTurnRate(10)
        elseif dist > 30 and dist <= 50 then
						self:SetTurnRate(12)
						WaitSeconds(1.5)
            self:SetTurnRate(12)
        elseif dist > 10 and dist <= 25 then
            WaitSeconds(0.3)
            self:SetTurnRate(50)
				elseif dist > 0 and dist <= 10 then       
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
		
			local LOUDPI = math.pi
			local LOUDCOS = math.cos
			local LOUDSIN = math.sin
			
            self.Split = true
            
            local vx, vy, vz = self:GetVelocity()
            local velocity = 10
            
            local ChildProjectileBP = '/projectiles/CIFMissileTacticalSplit01/CIFMissileTacticalSplit01_proj.bp'
            
            local angle = (2*LOUDPI) / self.NumChildMissiles
            local spreadMul = 1  # Adjusts the width of the dispersal        

            local launcher = self:GetLauncher() or false
            local launcherbp
            
            if launcher then 
                launcherbp = __blueprints[launcher.BlueprintID]
            end

            self.ChildDamageData = table.copy(self.DamageData)
            
            self.ChildDamageData.DamageAmount = launcherbp.SplitDamage.DamageAmount or self.ChildDamageData.DamageAmount/self.NumChildMissiles
            self.ChildDamageData.DamageRadius = launcherbp.SplitDamage.DamageRadius or 0.5
           
            -- Launch projectiles at semi-random angles away from split location
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
}
TypeClass = CIFMissileTactical01

