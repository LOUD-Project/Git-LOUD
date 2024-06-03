local CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile02

--import('/lua/utilities.lua')

local ForkThread = ForkThread
local KillThread = KillThread
local WaitSeconds = WaitSeconds

local CreateEmitterOnEntity = CreateEmitterOnEntity

CAANanoDart04 = Class(CAANanoDartProjectile) {

   OnCreate = function(self)
        CAANanoDartProjectile.OnCreate(self)
        
        -- Set the orientation of this thing to facing the target from the beginning.
        local ourPos= self:GetPosition()
        local targetPos= self:GetCurrentTargetPosition()
        local orientation= {targetPos[1]-ourPos[1],targetPos[2]-ourPos[2],targetPos[3]-ourPos[3]}         #Aim for the target.
        local velocity
        
        -- Determine and set the initial velocity of the projectile.
        velocity= {(orientation[1]*1.5),(orientation[2]*1.5)-40,(orientation[3]*1.5)}
        self:SetVelocity(orientation[1],orientation[2]-40,orientation[3])
        
        self:ForkThread(self.UpdateThread)
   end,


    UpdateThread = function(self)
	
		local WaitSeconds = WaitSeconds
		
        self:SetMaxSpeed(50)
        WaitSeconds(0.25)                   #Wait for a small amount of time
        
        self:SetBallisticAcceleration(-0.5) #Accelerate the projectile forward (negative is forward for this one).
		
        if self.FxTrails then
        
            local army = self:GetArmy()
        
            local CreateEmitterOnEntity = CreateEmitterOnEntity

            -- Place fx-emitter trails coming from this projectile for its exhaust trail.
            for i in self.FxTrails do
                CreateEmitterOnEntity(self,army,self.FxTrails[i])
            end
            
        end
        
        -- Set the mesh for the unfolded-fins missile now.
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')
        self:SetAcceleration(8 + Random() * 5)

        WaitSeconds(0.3)
        self:SetTurnRate(360)

    end,
}

TypeClass = CAANanoDart04
