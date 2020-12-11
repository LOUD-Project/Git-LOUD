--
-- Aeon Serpentine Missile
--

local MiasmaMissileProjectile = import('/lua/aeonprojectiles.lua').AMissileSerpentineProjectile
local utilities = import('/lua/utilities.lua')

Miasma_Missile = Class(MiasmaMissileProjectile) {
    OnCreate = function(self)
        MiasmaMissileProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1)
        self.Spread = false
        self.WaitTime = 1        
        self.StartDist = {}
        self.OldDistance = {}        
        self.MyTurnRate = self:GetBlueprint().Physics.TurnRate
        self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self) 
        -- Remember the location the missile was fired from      
        self.StartDist[1] = self:GetDistToTarg()
        WaitTicks(1)        
        while not self:BeenDestroyed() do
            self.OldDistance[1] = self:GetDistToTarg()   
            WaitTicks(self.WaitTime)                                       
            self:SetTurnRateByDist()                    
        end
    end,

    SetTurnRateByDist = function(self)
        if self:GetDistToTarg() > self.OldDistance[1] then     
            while self:GetDistToTarg() > self.OldDistance[1] do
                -- If the missile is moving away from the target increase turn rates to turn it back towards the target          
                self.MyTurnRate = self.MyTurnRate + 1
                self:SetTurnRate(self.MyTurnRate)
        	    WaitTicks(1)       
            end             
        elseif self:GetDistToTarg() <= self.StartDist[1] and self:GetDistToTarg() > (self.StartDist[1] * 0.8) then
            self:SetTurnRate(64)
            self.WaitTime = 3            
        elseif self:GetDistToTarg() <= (self.StartDist[1] * 0.8) and self:GetDistToTarg() > (self.StartDist[1] * 0.4) then                   
            self:SetTurnRate(96)
            self.WaitTime = 2 
        elseif self:GetDistToTarg() <= (self.StartDist[1] * 0.4) and self:GetDistToTarg() > (self.StartDist[1] * 0.2) then
            self:SetTurnRate(128)
            self.WaitTime = 1                           
        end
    end, 
    
    GetDistToTarg = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
    
    OnImpact = function(self, TargetType, TargetEntity)       
        -- Sounds for all other impacts, ie: Impact<TargetTypeName>
        local bp = self:GetBlueprint().Audio
        local snd = bp['Impact'.. TargetType]
        if snd then
            self:PlaySound(snd)
            -- Generic Impact Sound
        elseif bp.Impact then
            self:PlaySound(bp.Impact)
        end        
		self:CreateImpactEffects( self:GetArmy(), self.FxImpactNone, self.FxNoneHitScale )
		local x,y,z = self:GetVelocity()
		local speed = utilities.GetVectorLength(Vector(x*10,y*10,z*10))		
		-- One initial projectile following same directional path as the original
        self:CreateChildProjectile('/projectiles/AIFMiasmaShell02/AIFMiasmaShell02_proj.bp' ):SetVelocity(x,y,z):SetVelocity(speed):PassDamageData(self.DamageData)               
        self:Destroy()
    end,    
}
TypeClass = Miasma_Missile