local AMissileSerpentineProjectile = import('/lua/aeonprojectiles.lua').AMissileSerpentineProjectile

local ForkThread = ForkThread
local KillThread = KillThread
local WaitSeconds = WaitSeconds
local WaitTicks = WaitTicks

local FxScale = 3

APM_Helix_AGM = Class(AMissileSerpentineProjectile) {

	FxAirUnitHitScale = FxScale,
    FxLandHitScale = FxScale,
    FxNoneHitScale = FxScale,
    FxPropHitScale = FxScale,
    FxProjectileHitScale = FxScale,
    FxProjectileUnderWaterHitScale = FxScale,
    FxShieldHitScale = FxScale,
    FxUnderWaterHitScale = FxScale,
    FxUnitHitScale = FxScale,
    FxWaterHitScale = FxScale,
    FxOnKilledScale = FxScale,

    OnCreate = function(self)
        AMissileSerpentineProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self:ForkThread( self.MovementThread )
    end,

    MovementThread = function(self)
		
        WaitTicks(15)
        
        while not self:BeenDestroyed() do
		
            self:SetTurnRateByDist()
			
            WaitTicks(3)
			
        end
		
    end,

    SetTurnRateByDist = function(self)
	
		local function GetDistanceToTarget()
		
			local tpos = self:GetCurrentTargetPosition()
			local mpos = self:GetPosition()
			
			return VDist2(mpos[1], mpos[3], tpos[1], tpos[3])		
		
		end
	
        local dist = GetDistanceToTarget()
		
        --Get the nuke as close to 90 deg as possible
        if dist > 100 then
		
            --Freeze the turn rate as to prevent steep angles at long distance targets
            self:SetTurnRate(30)
			
        elseif dist > 64 and dist <= 107 then
		
			-- Increase check intervals
			self:SetTurnRate(60)
			
        elseif dist > 21 and dist <= 53 then
		
			-- Further increase check intervals
            self:SetTurnRate(90)
			
		elseif dist > 0 and dist <= 21 then
		
			-- final step --
            self:SetTurnRate(180)
			
            KillThread(self.MoveThread)
			
        end
		
    end,

}
TypeClass = APM_Helix_AGM
