-----------------------------------------------------------------------------
--  File          : /lua/4D_DefensiveTeleportation.lua 
-- 
--  Author        : Resin_Smoker 
-- 
--  Summary       : 4D_DefensiveTeleportation: Allows a unit so enhanced to teleport
--                  when damaged to avoid enemy fire. 
-- 
--  Copyright © 2010 4DC  All rights reserved.
----------------------------------------------------------------------------- 
-- 
--  The following is required in the units script for "Defensive Teleportation"
--  This calls into action the defensive teleportation scripts for AAirUnit 
-- 
--  local AAirUnit = import('/lua/aeonunits.lua').AAirUnit
--  AAirUnit = import('/mods/4DC/lua/CustomAbilities/4D_DefensiveTeleportation/4D_DefensiveTeleportation.lua').DefensiveTeleportation( AAirUnit ) 
-- 
-----------------------------------------------------------------------------

-- Start of DefensiveTeleportation(SuperClass)
function DefensiveTeleportation(SuperClass) 
    return Class(SuperClass) {
    
    OnStopBeingBuilt = function(self,builder,layer)
        SuperClass.OnStopBeingBuilt(self,builder,layer)    
        if not self:IsDead() then 
            -- Global Varibles 
            self.MyWeapon = self:GetWeapon(1)
            self.MyMaxSpeed = self:GetBlueprint().Air.MaxAirspeed
            self.WepRng = self.MyWeapon:GetBlueprint().MaxRadius
            self.WarpFlag  = false            
            -- Start of heartbeat event
            self:ForkThread(self.HeartBeatDistanceCheck)
        end 
    end, 
    
    HeartBeatDistanceCheck = function(self)
        while self and not self:IsDead() do
            -- Make sure we have a target and we have fuel
            local myFuel = self:GetFuelRatio()
			
            if self.MyWeapon:GetCurrentTarget() and myFuel > 0 then            
                -- Verify that our current target is a valid air target
                local myTarget = self.MyWeapon:GetCurrentTarget()
				
                if table.find(myTarget:GetBlueprint().Categories,'HIGHALTAIR') and not table.find(myTarget:GetBlueprint().Categories,'EXPERIMENTAL') then
				
                    -- Get the distance to our target
                    local myPos = self:GetPosition()
                    local tarPos = myTarget:GetPosition()
                    local distance = VDist2(myPos[1], myPos[3], tarPos[1], tarPos[3])
					
                    local myTargetSpeed = myTarget:GetBlueprint().Air.MaxAirspeed
					
                    -- Sets the fighter max speed to that of the target to help prevent overshoot.
                    if distance <= self.WepRng then                                       
                        -- Compute the speed of the target and match it
                        self:SetSpeedMult(myTargetSpeed / self.MyMaxSpeed)
                        self:SetAccMult(1.0)
                        self:SetTurnMult(1.0)
                    end
					
                -- Resets the speed and turn rates                                 
                else                      
                    self:SetSpeedMult(1.0) 
                    self:SetAccMult(1.0) 
                    self:SetTurnMult(1.0)      
                end               
            end                  
            -- Delay between checks
            WaitSeconds(1.0)
        end
    end,
    
    -- Check this out later on
    -- *** HasValidTeleportDest 
    -- *** Unit:HasValidTeleportDest() 
    
    OnDamage = function(self, instigator, amount, vector, damagetype) 
        SuperClass.OnDamage(self, instigator, amount, vector, damagetype) 
        if self:IsDead() == false and instigator and IsUnit(instigator) then               
            -- Allow teleport only if cool down is not active and there is avalible fuel
            local myFuel = self:GetFuelRatio()
            if self.WarpFlag == false and myFuel > 0 then
			
                CreateAttachedEmitter( self, 'uaa0306', self:GetArmy(), '/effects/emitters/generic_teleportout_01_emit.bp') 
                self:PlayUnitSound('Warp')
				
                -- Force the weapon offline while the teleport is in progress 
                if table.find(instigator:GetBlueprint().Categories,'AIR') and not table.find(instigator:GetBlueprint().Categories,'EXPERIMENTAL') then
                    -- Our fighter teleports tacticaly as a defensive measure vs air units 
                    -- It will teleport behind its attacker and retaliate 
                    local enemyPos = instigator:CalculateWorldPositionFromRelative({0, 0, -20}) 
                    local enemyFacing = instigator:GetOrientation() 
                    self.WarpFlag = true        
                    Warp(self, enemyPos, enemyFacing)                            
                    -- Burn extra fuel
                    self:ForkThread(self.UpdateFuel)                      
                    -- Unit set to retaliate on attacker
                    IssueClearCommands({self})               
                    IssueAttack({self}, instigator)                                          
                    self:ForkThread(self.TeleportEffects)  
                else
                    -- fighter teleports randomly as a defensive measure vs non-air units 
                    local location = self:GetPosition() 
                    local ranx = location[1] + Random(-30, 30) 
                    local rany = location[2] + Random(-30, 30) 
                    local destination = {ranx, rany, location[3]} 
					
                    self.WarpFlag = true 
					
                    Warp(self,destination)
					
                    -- Burn extra fuel
                    self:ForkThread(self.UpdateFuel)
                    self:ForkThread(self.TeleportEffects) 
                end
				
                self:SetAllWeaponsEnabled(true)                 
            end 
        end 
    end,
    
    UpdateFuel = function(self)
        local currentFuel = self:GetFuelRatio()
        local newFuelLvl = currentFuel - (currentFuel * 0.05)
        if newFuelLvl > 0 then
            self:SetFuelRatio(newFuelLvl)
        end    
    end, 
    
    TeleportEffects = function(self) 
        if not self:IsDead() then 
            -- Teleportation after effects 
            CreateAttachedEmitter( self, 'uaa0306', self:GetArmy(), '/effects/emitters/generic_teleportin_01_emit.bp') 
            CreateAttachedEmitter( self, 'uaa0306', self:GetArmy(), '/effects/emitters/generic_teleportin_02_emit.bp') 
            CreateAttachedEmitter( self, 'uaa0306', self:GetArmy(), '/effects/emitters/generic_teleportin_03_emit.bp')           
            -- Short pause between teleports 
            WaitSeconds(Random(2,4))           
            -- Resets teleportation flag 
            if not self:IsDead() then                 
                self.WarpFlag = false
            end
        end 
    end,    
        
}
end 
-- End of DefensiveTeleportation(SuperClass) 