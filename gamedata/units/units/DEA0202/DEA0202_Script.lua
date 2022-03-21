local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TAirToAirLinkedRailgun = import('/lua/terranweapons.lua').TAirToAirLinkedRailgun
local TIFCarpetBombWeapon = import('/lua/terranweapons.lua').TIFCarpetBombWeapon

DEA0202 = Class(TAirUnit) {
    Weapons = {
	
        AAGun = Class(TAirToAirLinkedRailgun) {},
--[[		
        Bomb = Class(TIFCarpetBombWeapon) {

            IdleState = State (TIFCarpetBombWeapon.IdleState) {
			
                Main = function(self)
                    TIFCarpetBombWeapon.IdleState.Main(self)
                end,
                
                OnGotTarget = function(self)
				
                    self.unit:SetBreakOffTriggerMult(2.0)
                    self.unit:SetBreakOffDistanceMult(8.0)
                    self.unit:SetSpeedMult(0.67)
					
                    TIFCarpetBombWeapon.IdleState.OnGotTarget(self)
					
                    local speedMulti = 0.67 * self.unit:GetSpeedModifier()   # [168]
					
                    self.unit:SetSpeedMult(speedMulti)
					
                end,
				
                OnFire = function(self)
                    self.unit:RotateWings(self:GetCurrentTarget())
                    TIFCarpetBombWeapon.IdleState.OnFire(self)
                end,                
            },
            
            OnFire = function(self)
                self.unit:RotateWings(self:GetCurrentTarget())
                TIFCarpetBombWeapon.OnFire(self)
            end,

            OnGotTarget = function(self)
                self.unit:SetBreakOffTriggerMult(2.0)
                self.unit:SetBreakOffDistanceMult(8.0)
                self.unit:SetSpeedMult(0.67)
                TIFCarpetBombWeapon.OnGotTarget(self)
                local speedMulti = 0.67 * self.unit:GetSpeedModifier()   # [168]
                self.unit:SetSpeedMult(speedMulti)
            end,
        
            OnLostTarget = function(self)
                self.unit:SetBreakOffTriggerMult(1.0)
                self.unit:SetBreakOffDistanceMult(1.0)
                self.unit:SetSpeedMult(1.0)
                TIFCarpetBombWeapon.OnLostTarget(self)
                local speedMulti = self.unit:GetSpeedModifier()   # [168]
                self.unit:SetSpeedMult(speedMulti)
            end,        
        },
--]]
    },
--[[	
    GetSpeedModifier = function(self)
	
        # this returns 1 when the plane has fuel or 0.25 when it doesn't have fuel. The movement speed penalty for
        # running out of fuel is 75% so planes with no fuel fly at 25% of max speed. [168]
        if self:GetFuelRatio() == 0 then
            return 0.25
        end
        return 1
		
    end,    
    
    RotateWings = function(self, target)
	
        if not self.LWingRotator then
            self.LWingRotator = CreateRotator(self, 'Left_Wing', 'y')
            self.Trash:Add(self.LWingRotator)
        end
		
        if not self.RWingRotator then
            self.RWingRotator = CreateRotator(self, 'Right_Wing', 'y')
            self.Trash:Add(self.RWingRotator)
        end
		
        local fighterAngle = -105
        local bomberAngle = 0
        local wingSpeed = 45
		
        if target and EntityCategoryContains(categories.AIR, target) then
            if self.LWingRotator then
                self.LWingRotator:SetSpeed(wingSpeed)
                self.LWingRotator:SetGoal(-fighterAngle)
            end
            if self.RWingRotator then
                self.RWingRotator:SetSpeed(wingSpeed)
                self.RWingRotator:SetGoal(fighterAngle)
            end
        else
            if self.LWingRotator then
                self.LWingRotator:SetSpeed(wingSpeed)
                self.LWingRotator:SetGoal(-bomberAngle)
            end
            if self.RWingRotator then
                self.RWingRotator:SetSpeed(wingSpeed)
                self.RWingRotator:SetGoal(bomberAngle)
            end                
        end  
    end,
    
    OnCreate = function(self)
        TAirUnit.OnCreate(self)
        self:ForkThread(self.MonitorWings)
    end,
    
    MonitorWings = function(self)
        local airTargetRight
        local airTargetLeft
        while self and not self:IsDead() do
            WaitSeconds(1)
            local airTargetWeapon = self:GetWeaponByLabel('RightBeam')
            if airTargetWeapon then     
                airTargetRight = airTargetWeapon:GetCurrentTarget()
            end
            airTargetWeapon = self:GetWeaponByLabel('LeftBeam')
            if airTargetWeapon then
                airTargetLeft = airTargetWeapon:GetCurrentTarget()
            end
            
            if airTargetRight then
                self:RotateWings(airTargetRight)              
            elseif airTargetLeft then
                self:RotateWings(airTargetLeft)             
            else
                self:RotateWings(nil)
            end
        end
    end,
--]]
}

TypeClass = DEA0202