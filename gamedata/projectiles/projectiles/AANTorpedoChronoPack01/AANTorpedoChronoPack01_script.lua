local ATorpedoShipProjectile = import('/lua/aeonprojectiles.lua').ATorpedoShipProjectile

local WaitSeconds = WaitSeconds
local VDist3 = VDist3

AANTorpedoChronoPack01 = Class(ATorpedoShipProjectile) {

    FxSplashScale = 1,
	
    NumberOfChildProjectiles = 4,
	
    KillWaitingThread = true,
    KillSplitUpThread = false,
	
    DistanceBeforeSplitRatio = 0.35,
	
    VelocityOnEnterWater = 3,
	
    SplitUpThread = function(self)
	
		local VDist3 = VDist3
		local LOUDPI = math.pi
		local LOUDCOS = math.cos
		local LOUDSIN = math.sin
		
        local TrackingTarget = self:GetTrackingTarget()
        local SplitWaitTime = 1.0

        if( TrackingTarget != nil ) then
            SplitWaitTime = (VDist3( self:GetPosition(), TrackingTarget:GetPosition() ) * self.DistanceBeforeSplitRatio) / self.VelocityOnEnterWater
        end

        WaitSeconds(SplitWaitTime)
        local Velx, Vely, Velz = self:GetVelocity()
        local angleRange = LOUDPI
        local angleInitial = -angleRange * 0.5
        local angleIncrement = angleRange / (self.NumberOfChildProjectiles - 1 )
        local angle, ca, sa, x, z, proj
        for i = 0, (self.NumberOfChildProjectiles - 1) do
            angle = angleInitial + (i*angleIncrement)
            ca = LOUDCOS(angle)
            sa = LOUDSIN(angle)
            x = Velx * ca - Velz * sa
            z = Velx * sa + Velz * ca
            proj = self:CreateChildProjectile('/projectiles/AANTorpedo01/AANTorpedo01_proj.bp')
            proj:SetVelocity( x * 2, Vely, z * 2 )
        end
        self:Destroy()
    end,
}

TypeClass = AANTorpedoChronoPack01
