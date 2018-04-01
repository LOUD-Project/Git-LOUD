
local CLOATacticalMissileProjectile = import('/lua/cybranprojectiles.lua').CLOATacticalMissileProjectile
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

MGQAIRocket01 = Class(CLOATacticalMissileProjectile) {
    OnCreate = function(self)
        CLOATacticalMissileProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)
        self:ForkThread(self.UpdateThread)
        #self:ForkThread(self.Takeoff)
    end,

	UpdateThread = function(self)
        self:SetMaxSpeed(1)
        WaitSeconds(0.1)
        local Velx, Vely, Velz = self:GetVelocity()
        local NumberOfChildProjectiles = 2        
        local ChildProjectileBP = '/mods/BlackOpsUnleashed/projectiles/MGQAIRocketChild01/MGQAIRocketChild01_proj.bp'  
        local angleRange = math.pi * 0.25
        local angleInitial = -angleRange / 2
        local angleIncrement = angleRange / NumberOfChildProjectiles
        local angleVariation = angleIncrement * 0.4
        local angle, ca, sa, x, z, proj, mul
        for i = 0, NumberOfChildProjectiles  do
            angle = angleInitial + (i*angleIncrement) + RandomFloat(-angleVariation, angleVariation)
            ca = math.cos(angle)
            sa = math.sin(angle)
            x = Velx * ca - Velz * sa
            z = Velx * sa + Velz * ca
            proj = self:CreateChildProjectile(ChildProjectileBP)
            proj:PassDamageData(self.DamageData)
            mul = RandomFloat(1,3)
            #proj:SetVelocity( x * mul, Vely * mul, z * mul )
        end   
        self:Destroy()
    end,
	
    Takeoff = function(self) 
    
    WaitSeconds(1)

        local Velx, Vely, Velz = self:GetVelocity()
        local NumberOfChildProjectiles = 1        
        local ChildProjectileBP = '/mods/BlackOpsUnleashed/projectiles/MGQAIRocketChild01/MGQAIRocketChild01_proj.bp'  
        local angleRange = math.pi * 0.25
        local angleInitial = -angleRange / 2
        local angleIncrement = angleRange / NumberOfChildProjectiles
        local angleVariation = angleIncrement * 0.4
        local angle, ca, sa, x, z, proj, mul
        
        self:StayUnderwater(true)
        for i = 0, NumberOfChildProjectiles  do
            angle = angleInitial + (i*angleIncrement) + RandomFloat(-angleVariation, angleVariation)
            ca = math.cos(angle)
            sa = math.sin(angle)
            x = Velx * ca - Velz * sa
            z = Velx * sa + Velz * ca
            proj = self:CreateChildProjectile(ChildProjectileBP)
            proj:PassDamageData(self.DamageData)
            mul = RandomFloat(1,3)
            #proj:SetVelocity( x * mul, Vely * mul, z * mul )
        end            
        
        local pos = self:GetPosition()
        local spec = {
            X = pos[1],
            Z = pos[3],
            Radius = 30,
            LifeTime = 10,
            Omni = false,
            Vision = false,
            Army = self:GetArmy(),
        }
        local vizEntity = VizMarker(spec)
        CLOATacticalMissileProjectile.Takeoff(self)
        self:Destroy()
    end,
	
}

TypeClass = MGQAIRocket01