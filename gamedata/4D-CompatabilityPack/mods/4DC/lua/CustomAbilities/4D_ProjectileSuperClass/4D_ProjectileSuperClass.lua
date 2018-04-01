-----------------------------------------------------------------------------
--  File          : /lua/4D_ProjectileSuperClass.lua 
-- 
--  Author        : Resin_Smoker 
-- 
--  Summary       : 4D_ProjectileSuperClass: Allows special abilities to be 
--                  easily added to custom projectiles by adding a few simple
--                  lines of script to that projectiles lua. 
-- 
--  Copyright © 2010 4DC  All rights reserved.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- *** Shield Disruptor Ability ***
--
-- Summary: Allows projectiles to disrupt a shields integrity by 33% per impact
--
-- The following is required in the projectiles script
-- 
-- local MyProjectile = import('/lua/aeonprojectiles.lua').WhateverMuzzleEffectsYouWantGoesHereProjectile
-- Disruptor_Projectile = import('/mods/4DC/lua/CustomAbilities/4D_ProjectileSuperClass/4D_ProjectileSuperClass.lua').ShieldDisruptor( MyProjectile )
--  
----------------------------------------------------------------------------- 
-- Start of Shield Disruptor(SuperClass) 
function ShieldDisruptor(SuperClass) 
    return Class(SuperClass) {
    
    OnImpact = function(self, targetType, targetEntity)
        SuperClass.OnImpact(self, targetType, targetEntity)
        if targetEntity and targetType == 'Shield' and targetEntity:GetMaxHealth() > 0 then
            -- Disruption amount is 33% of shields current health
            local dmgAmt = targetEntity:GetHealth() * 0.33
            if dmgAmt > 0 and targetEntity:GetHealth() > 0 then
                if dmgAmt < targetEntity:GetHealth() then
                    -- LOG('Shield Disruption DMG: ', dmgAmt)
                    Damage(self, {0,0,0}, targetEntity, dmgAmt, 'Normal')
                else
                    -- LOG('Shield Kill')               
                    Damage(self, {0,0,0}, targetEntity, TargetEntity:GetHealth(), 'Normal')               
                end
                -- LOG('Wrong unit type or No Dmg Data passed or the Target shield has no health')
            end	
            -- LOG('Target health after impact: ', TargetEntity:GetHealth() )        			
        end
    end,
           
}
end 
-- End of Shield Disruptor(SuperClass)


-----------------------------------------------------------------------------
-- *** Gauss Rifle Ability #1 ***
--
-- Summary: Allows projectiles to pass thru up to 3 targets
--
-- The following is required in the projectiles script
-- 
-- local MyProjectile = import('/lua/aeonprojectiles.lua').WhateverMuzzleEffectsYouWantGoesHereProjectile
-- Gauss1_Projectile = import('/mods/4DC/lua/CustomAbilities/4D_ProjectileSuperClass/4D_ProjectileSuperClass.lua').GaussRifle1( MyProjectile )
--  
--
-- The following is required within the Unit.lua
--
--  OnCollisionCheck = function(self, other, firingWeapon)
--      if other.LastImpact and other.LastImpact == self:GetEntityId() then
--          --LOG('Hit the same unit twice')
--          return false 
--      end 
--      return oldUnit.OnCollisionCheck(self, other, firingWeapon) 
--  end,    
----------------------------------------------------------------------------- 
-- Start of Gauss Rifle(SuperClass) 
function GaussRifle1(SuperClass) 
    return Class(SuperClass) {
    
    OnCreate = function(self, inWater)
        SuperClass.OnCreate(self, inWater)  
        -- Initialize the counter
        self.ImpactCounter = 0
    end,
       
    OnImpact = function(self, targetType, targetEntity)  
        if targetEntity and targetType == 'Unit' then       
            -- LOG('OnImpact, hit unit')
            -- Check to see if we hit the same target                     
            if not self.LastImpact or self.LastImpact != targetEntity:GetEntityId() then
                -- Remember what was hit last
                -- LOG('OnImpact, saving last target hit') 
                self.LastImpact = targetEntity:GetEntityId()                
                -- Perform DMG and effects
                SuperClass.OnImpact(self, targetType, targetEntity)                
                if self.ImpactCounter then
                    -- LOG('OnImpact, counter: ', self.ImpactCounter) 
                    if self.ImpactCounter < 2 then
                        -- LOG('OnImpact, incrementing Counter') 
                        self.ImpactCounter = self.ImpactCounter + 1 
                    end 
                else
                   -- LOG('OnImpact, starting counter') 
                   -- Advance the counter
                   self.ImpactCounter = 1 
                end                          
            else
               -- If the same target is hit do nothing
               -- LOG('OnImpact, hit the same unit')
            end
        else
            -- Upon hitting a non-unit, perform DMG and effects
            -- LOG('OnImpact, passing dmg effects to non-unit target')
            SuperClass.OnImpact(self, targetType, targetEntity)            
        end
    end,      
          
    OnImpactDestroy = function( self, targetType, targetEntity ) 
        if targetEntity and targetType == 'Unit' then 
            -- LOG('OnImpactDestroy, Hit unit')
            -- LOG('OnImpactDestroy, Current count: ', self.ImpactCounter)
            if self.ImpactCounter < 2 then
                -- LOG('OnImpactDestroy, Counter < 3')
                return            
            else
                -- Destroy projectile if impact count = 3
                -- LOG('OnImpactDestroy, hit 3 or more units, destroying projectile') 
                SuperClass.OnImpactDestroy(self, targetType, targetEntity)      
            end
        else
            -- Destroy projectile if non-unit impacted
            -- LOG('OnImpactDestroy, hit non-unit')           
            SuperClass.OnImpactDestroy(self, targetType, targetEntity)
        end     
    end,     
           
}
end 
-- End of Gauss Rifle(SuperClass)