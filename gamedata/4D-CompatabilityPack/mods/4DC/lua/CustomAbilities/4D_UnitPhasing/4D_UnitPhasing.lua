-----------------------------------------------------------------------------
--  File          : /lua/UnitPhasing.lua 
-- 
--  Author        : Resin_Smoker 
-- 
--  Summary       : Unit Phasing: Allows a unit so enhanced to shift it's molecules 
--                  around into extra spatial dimensions becoming translucent and 
--                  semi-ethereal, almost completely non corporeal. 
--                  The advantage to this is that a unit so enhanced can avoid a 
--                  percentage direct fire weapons by allowing them to pass thru it 
--                  harmlessly! While protected from directfire projectiles, a Phased
--                  unit is still very vunerable from laser weapons, damage over time
--                  weapons, and projectile with signifigant splash damage.  
-- 
--  Copyright © 2010 4DC  All rights reserved.
-----------------------------------------------------------------------------
-- 
--  The following is required in the units script for UnitPhasing 
--  This calls into action the UnitPhasing scripts for SAirUnit 
-- 
--  local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
--  SAirUnit = import('/mods/4DC/lua/CustomAbilities/4D_UnitPhasing/4D_UnitPhasing.lua').UnitPhasing( SAirUnit ) 
-- 
-----------------------------------------------------------------------------

-- Start of UnitPhasing(SuperClass)
function UnitPhasing(SuperClass) 
    return Class(SuperClass) {
    
    OnStopBeingBuilt = function(self,builder,layer) 
        SuperClass.OnStopBeingBuilt(self,builder,layer)      
        -- Phase Global Variables 
        self.BP = self:GetBlueprint()
        self.OldImpact = nil 
        self.PhaseEnabled = false
        self.PriorStatus = false
        self:SetMaintenanceConsumptionInactive()
        -- Enable Phasing if StartsOn true in BP
        if self.BP.Defense.Phasing.StartsOn == true then
            self:SetScriptBit('RULEUTC_SpecialToggle', true) 
        end        
        self:ForkThread(self.PhaseEconomyHeartBeat)                                                                       
    end,
    
    PhaseEconomyHeartBeat = function(self)    
        local cost = self.BP.Economy.MaintenanceConsumptionPerSecondEnergy           
        while not self:IsDead() do
            -- Verify that economy is capabile of supporting phasing and that the unit isnt in transport
            local econ = self:GetAIBrain():GetEconomyStored('Energy')           
            if (econ < cost and self.PhaseEnabled == true and self.PriorStatus == false) or ((self:IsUnitState('Attached') or self:IsUnitState('TransportLoading')) and (self.PhaseEnabled == true and self.PriorStatus == false)) then
                self.PriorStatus = true
                self:ForkThread(self.PhaseDisable) 
            elseif (econ > cost and self.PriorStatus == true and self.PhaseEnabled == false) and (not self:IsUnitState('Attached') and not self:IsUnitState('TransportUnloading') and not self:IsUnitState('TransportLoading')) then
                self.PriorStatus = false               
                self:ForkThread(self.PhaseEnable)
            end   
            -- Short delay between checks
            WaitTicks(Random(2, 4))         
        end
    end,               
                
    OnScriptBitSet = function(self, bit)  
        if bit == 7 then
            self:ForkThread(self.PhaseEnable)
        end
        SuperClass.OnScriptBitSet(self, bit)
    end,     
     
    OnScriptBitClear = function(self, bit)   
       if bit == 7 then
           if self.PriorStatus == true then
               self.PriorStatus = false
           end
           self:ForkThread(self.PhaseDisable)      
       end
       SuperClass.OnScriptBitClear(self, bit)
    end,    
    
    PhaseEnable = function(self)
        WaitSeconds(1)   
        if not self:IsDead() and not self.PhaseEnabled == true and not self:IsUnitState('Attached') then       
            self:SetMesh(self.BP.Defense.Phasing.PhaseMesh, true) 
            self.PhaseEnabled = true
            self:SetMaintenanceConsumptionActive() 
        end
    end,    
    
    PhaseDisable = function(self)
        if not self:IsDead() and not self.PhaseEnabled == false then 
            self.PhaseEnabled = false    
            self:SetMaintenanceConsumptionInactive() 
            self:SetMesh(self.BP.Defense.Phasing.StandardMesh, true)            
        end
    end,
    
    OnCollisionCheck = function(self, other, firingWeapon)
        if not self:IsDead() and self.PhaseEnabled == true then
            if EntityCategoryContains(categories.PROJECTILE, other) then 
                local random = Random(1,100)
                -- Allows % of projectiles to pass
                if random <= self.BP.Defense.Phasing.PhasePercent or other == self.OldImpact then   
                    -- remember what last impacted to prevent the same projectile from being checked twice
                    self.OldImpact = other
                    -- Returning false allows the projectile to pass thru                    
                    return false       
                else               
                    -- Projectile impacts normally
                    self.OldImpact = nil
                    return true 
                end
            end
        end
        return SuperClass.OnCollisionCheck(self, other, firingWeapon) 
    end,        
}
end 
-- End of UnitPhasing(UnitPhasing)