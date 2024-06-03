local SAirUnit = import('/lua/defaultunits.lua').AirUnit
local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SAAShleoCannonWeapon = SeraphimWeapons.SAAShleoCannonWeapon
local SDFBombOtheWeapon = SeraphimWeapons.SDFBombOtheWeapon

SeraphimWeapons = nil

XSA0202 = Class(SAirUnit) {
    Weapons = {
        ShleoAAGun01 = Class(SAAShleoCannonWeapon){},
        ShleoAAGun02 = Class(SAAShleoCannonWeapon){},
        Bomb = Class(SDFBombOtheWeapon) {

            IdleState = State (SDFBombOtheWeapon.IdleState) {
                Main = function(self)
                    SDFBombOtheWeapon.IdleState.Main(self)
                end,
   
                OnGotTarget = function(self)
                    self.unit:SetBreakOffTriggerMult(2.0)
                    self.unit:SetBreakOffDistanceMult(8.0)
                    self.unit:SetSpeedMult(0.67)
                    SDFBombOtheWeapon.OnGotTarget(self)
                    local speedMulti = 0.67 * self.unit:GetSpeedModifier()   # [168]
                    self.unit:SetSpeedMult(speedMulti)
                end,                
            },
        
            OnGotTarget = function(self)
                self.unit:SetBreakOffTriggerMult(2.0)
                self.unit:SetBreakOffDistanceMult(8.0)
                self.unit:SetSpeedMult(0.67)
                SDFBombOtheWeapon.OnGotTarget(self)
                local speedMulti = 0.67 * self.unit:GetSpeedModifier()   # [168]
                self.unit:SetSpeedMult(speedMulti)
            end,
        
            OnLostTarget = function(self)
                self.unit:SetBreakOffTriggerMult(1.0)
                self.unit:SetBreakOffDistanceMult(1.0)
                self.unit:SetSpeedMult(1.0)
                SDFBombOtheWeapon.OnLostTarget(self)
                local speedMulti = self.unit:GetSpeedModifier()   # [168]
                self.unit:SetSpeedMult(speedMulti)
            end,  	
        },
    },
	
    GetSpeedModifier = function(self)
        # this returns 1 when the plane has fuel or 0.25 when it doesn't have fuel. The movement speed penalty for
        # running out of fuel is 75% so planes with no fuel fly at 25% of max speed. [168]
        if self:GetFuelRatio() == 0 then
            return 0.25
        end
        return 1
    end,
}
TypeClass = XSA0202