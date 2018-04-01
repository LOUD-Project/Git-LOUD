-----------------------------------------------------------------------------
--  File          : /lua/4D_ShieldDroneSuperClass.lua 
-- 
--  Author        : Resin_Smoker 19 JULY 2010
-- 
--  Summary       : This script allots a drone to enhance MLU's (Moble Land Units) 
--                  and Structures with shields. This script acts as a discriminator
--                  removing units that the shield drone is incapable of enhancing.                   
--                   
--  Copyright © 2010 4DC  All rights reserved.
-----------------------------------------------------------------------------
-- 
--  The following is required in the units script for Drone Shields 
--  This calls into action the Shield_Drones_SuperClass scripts for AAirUnit 
-- 
--  local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
--  SAirUnit = import('/mods/4DC/lua/CustomAbilities/4D_ShieldDroneSuperClass/4D_ShieldDroneSuperClass.lua').AutoSelectShieldDrone( SAirUnit )
-- 
----------------------------------------------------------------------------- 

-- Localy imported files 
local EffectTemplate = import('/lua/EffectTemplates.lua')

-- Start of auto select Shield-Drone (SuperClass)                                                                                                              
function AutoSelectShieldDrone(SuperClass) 
    return Class(SuperClass) {
    
    -- MotionEvent is tied to a filter that is triggered when the drone is guarding a friendly unit that passes the listed restrictions
    OnMotionTurnEventChange = function(self, newEvent, oldEvent)
	
        if (not self.Dead) and self:GetGuardedUnit() then
		
            self.GUnit = self:GetGuardedUnit()             
			
            if newEvent ~= oldEvent and (not self.GUnit:IsDead()) and not IsEnemy(self:GetArmy(),self.GUnit:GetArmy()) then
			
                if self.GUnit:IsUnitState('Attached') then
                    ForkThread(FloatingEntityText, self.Sync.id, "Cannot merge - target on a transport")
                    self:Failure()
					
                elseif self.GUnit.HasDrone then
					ForkThread(FloatingEntityText, self.Sync.id, "Cannot merge - target already merged")
                    self:Failure()
					
				elseif self.GUnit:GetFractionComplete() != 1 then
					ForkThread(FloatingEntityText, self.Sync.id, "Cannot merge - target unfinished")
					self:Failure()
					
                else  
                    self.FailReason = nil
					
                    if self:Verification() == true then                                                                                                                
                        self:ForkThread(self.ShieldEnhance)
						
                    else
                        ForkThread(FloatingEntityText, self.Sync.id, "Cannot merge - "..self.FailReason)
                        self:Failure()
                    end
                end
            end
        end
    end,

    Verification = function(self)                                                                                                                                                                                                                               
        -- Check to see if a shield is already active.
        if not self.GUnit.MyShield then
		
            local gUnitBP = self.GUnit:GetBlueprint()  
            local gUnitCats = gUnitBP.Categories    

            -- Check to see if the gUnit has a Cloak, BuildRate or Economy, if so return false
            if gUnitBP.Intel.Cloak then 
                -- WARN('Shield Drone, reason: Cloak', gUnitBP.Intel.Cloak)
                self.FailReason = 'UNIT CAN CLOAK'
                return false                                            
            elseif gUnitBP.Economy.BuildRate > 1 then 
                -- WARN('Shield Drone, reason: BuildRate', gUnitBP.Economy.BuildRate )
                self.FailReason = 'UNIT IS BUILDER'
                return false                              
            elseif gUnitBP.Economy.MaintenanceConsumptionPerSecondEnergy > 0 then 
                -- WARN('Shield Drone, reason: Maint Cost', gUnitBP.Economy.MaintenanceConsumptionPerSecondEnergy)
                self.FailReason = 'UNIT HAS ECONOMY'
                return false 
            else
                -- Check if any of the weapons require energy to fire
                for i = 1, self.GUnit:GetWeaponCount() do
                    local wep = self.GUnit:GetWeapon(i)
                    if wep:GetBlueprint().EnergyRequired > 1 then
                        self.FailReason = 'WEAPON REQUIRES ENERGY TO FIRE'
                        return false
                    end 
                end                                                                                                                                                                                                                                                                                    
            end   
            
            -- Unit Categories the shield drone is not allowed to enhance                   
            local excludedCats = { 
                -- Custom unit restrictions
                'HOLOGRAM','HOLOGRAMGENERATOR','DRONE','MINE','PHASING', 
                -- Misc unit restrictions
                'POD','SATELLITE','UNTARGETABLE',
                'SHIELD','WALL','PROJECTILE', 
                'OPERATION','CIVILIAN','INSIGNIFICANTUNIT', 
                'UNSELECTABLE','BENIGN','CYBRAN','AEON','UEF'                 
            }                      
            -- Compare the gUnit Blueprint with the excludedCats
            -- Should no matches be found return false
            for k, v in excludedCats do 
                if table.find(gUnitCats, v) then  
                    -- WARN('*** This Unit Type Not allowed: ', gUnitBP.General.UnitName)
                    -- WARN('*** Reason: ', excludedCats[k] ) 
                    self.FailReason = excludedCats[k]     
                    return false
                end           
            end                                            
            -- Retrun true if no matches are found
            return true                                   
        else
            -- Error Sound Effect
            self.FailReason = 'UNIT IS SHIELDED'
            return false   
        end     
    end,
    
    Failure = function(self)
        -- Sound FX
        self:PlayUnitSound('EnhanceFail') 
        -- Removes any residual commands
        IssueClearCommands({self})
        -- Force unit to halt
        IssueStop({self})
        -- Remove FX
        self:RemoveBuildFX()        
    end,       

    -- Drone will attempt to close on the unit it is guarding before spawning the shield
    ShieldEnhance = function(self)
	
        if not self.Dead and not self.GUnit:IsDead() then         
		
            -- Verify distance to the guarded unit                 
            while not self.GUnit:IsDead() and self:ReturnDist(self.GUnit) >= 4 and not self:IsDead() and self.GUnit.HasDrone ~= true do            
                -- Attempt to move closer if out of range
                IssueClearCommands({self})
                IssueMove({self}, self.GUnit)                
                WaitSeconds(1)
            end
			
            if not self:IsDead() and not self.GUnit:IsDead() and self.GUnit.HasDrone ~= true then                  
                -- Removes any residual commands
                IssueClearCommands({self})                              
                -- Start Sound effects
                self:PlayUnitSound('EnhanceStart')                
                -- Kicks off beam effects
                self:ForkThread(self.BeamThread)
                -- Area FX 
                CreateAttachedEmitter( self, 'xsa0201', self:GetArmy(), '/effects/emitters/seraphim_shield_generator_t3_03_emit.bp'):ScaleEmitter(0.5) 
                CreateAttachedEmitter( self, 'xsa0201', self:GetArmy(), '/effects/emitters/seraphim_shield_generator_t3_04_emit.bp'):ScaleEmitter(0.5)                                                                  
                WaitSeconds(2)
				
                if not self:IsDead() and not self.GUnit:IsDead() and self.GUnit.HasDrone ~= true then                                                
                    -- Disables user control 
                    self.SetUnSelectable(self, true)                                                                          
                    -- Sets a flag so the guarded units can not possibly have more then one shield drone                                  
                    self.GUnit.HasDrone = true                                                                                    
                    -- Removal of build beams
                    if self.BuildEffectsBag then
                        for k,v in self.BuildEffectsBag do                
                            v:Destroy()
                        end 			
                    end                     
                    -- End Sound effects
                    self:PlayUnitSound('EnhanceEnd')
					
                    -- Select the shield type to provide the unit (Disabled as this is a WIP)                                                                           
                    #if table.find(self.GUnit:GetBlueprint().Categories,'FACTORY') and not table.find(self.GUnit:GetBlueprint().Categories,'EXPERIMENTAL') 
                    #and not table.find(self.GUnit:GetBlueprint().Categories,'NAVAL') then                    
                    #    ### Creates a bubble shield on the guarded structure
                    #    self.GUnit:SpawnDomeShield()     
                    #else                                                     
                        ### Creates a personal shield on the guarded unit
						
                        self.GUnit:SpawnPersonalShield()
						
                    #end
					
                    self:PlayUnitSound('Warp')
                    WaitSeconds(0.2)
					
                    if self:IsDead() then return end       
					
                    self:HideBone('xsa0201', true)                                        
                    -- Small delay before drone removal
                    WaitSeconds(0.3)                                                                         
                    -- Removes the drone
                    if not self:IsDead() then                                
                        self:Destroy()	
                    end
                else
                    self:Failure()
                end
            else
                self:Failure()
            end
        else
            self:Failure()
        end
    end,
    
    -- Build beam special effects   
    BeamThread = function( self )
	    local army = self:GetArmy()
        local bones = self:GetBlueprint().General.BuildBones.BuildEffectBones
        for kBone, vBone in bones do
            for k, v in EffectTemplate.SeraphimBuildBeams01 do
                local beamEffect = AttachBeamEntityToEntity(self, kBone, self.GUnit, -1, army, v )
                self.BuildEffectsBag:Add(beamEffect)
            end
	    end             
    end,    
       
    -- Simple distance check function                     
    ReturnDist = function(self, unit)
        local myPos = self:GetPosition()
        local tarPos = unit:GetPosition()
        local distance = VDist2(myPos[1], myPos[3], tarPos[1], tarPos[3])
        return distance
    end,

    -- Cleanup scripts for build effects if they still exsist        
    RemoveBuildFX = function(self)
        if self.BuildEffectsBag then
            for k,v in self.BuildEffectsBag do                
                v:Destroy()
            end 			
        end
    end,
       
    OnDestroy = function(self) 
        self:RemoveBuildFX()
        SuperClass.OnDestroy(self) 
    end,        
}
end 
-- End of auto select Shield-Drone (SuperClass)