local BFG_Projectile = import('/mods/4DC/lua/4D_projectiles.lua').BFGProjectile

-- Misc local files
local EffectTemplate = import('/lua/EffectTemplates.lua')
local utilities = import('/lua/utilities.lua')
local Custom_4D_EffectTemplate = import('/mods/4DC/lua/4D_EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat


BFG_Shell = Class(BFG_Projectile) { 

    -- Beam FX templates  
    FxBeam = Custom_4D_EffectTemplate.ArcBeam,
    
    -- List of units that should not be stunned
    DoNotStunList = { 
        -- Command unit restrictions
        'COMMAND','SUBCOMMANDER', 
        -- Experimental unit restrictions
        'EXPERIMENTAL',
        -- Flying unit restrictions
        'AIR',
        -- Sub unit restrictions
        'SUBMERSIBLE','NUKESUB',        
        -- Custom unit restrictions
        'HOLOGRAM','HOLOGRAMGENERATOR','DRONE','MINE','PHASING', 
        -- Misc unit restrictions
        'POD','SATELLITE','UNTARGETABLE',
        'SHIELD','WALL','NUKE','PROJECTILE', 
        'OPERATION','CIVILIAN','INSIGNIFICANTUNIT', 
        'UNSELECTABLE','BENIGN',                  
    },      
   
    OnCreate = function(self)   
	    BFG_Projectile.OnCreate(self)
	    --Kick off BFG
        self:ForkThread(self.BFG)
    end,
    
    BFG = function(self)   
        -- Setup tables and variables
        local arcFXBag = {}
        local radius = self.DamageData.DamageRadius * 3     
        local army = self:GetArmy()       

        -- Small delay after firing before BFG arcs become active
        WaitSeconds(1)        

        -- While projectile active and has avalible damage perform BFG area damage and effects
        while not self:BeenDestroyed() and self.DamageData.DamageAmount > 0 do        

            -- Search for all enemy units in range
            local units = {}
            units = utilities.GetEnemyUnitsInSphere(self, self:GetPosition(), radius)

            -- Should there be enemy units in range loop            
            if table.getsize(units) > 0 then 

                -- Sound FX                                 
                self:PlaySound(self:GetBlueprint().Audio['Arc']) 

                -- Loop thru all avalible targets                                  
                for k, v in units do

                    -- If the DMG pool falls below "1" destroy the projectile 
                    if self.DamageData.DamageAmount <= 1 then                 
                        self:OnImpact('Terrain', nil)
                        self:Destroy()
                    else                
                        local target = v  

                        -- Attach beam to the target                                           
                        for k, a in self.FxBeam do                      
                            local beam = AttachBeamEntityToEntity(target, -2, self, -1, self:GetArmy(), a)
                            table.insert(arcFXBag, beam)
                            self.Trash:Add(beam)
                        end     

                        -- Prime arcStun flag
                        local arcStun = true                  

                        for k, v in self.DoNotStunList do   
                            -- Set flag to false if unit is on the DoNotStunList                                             
                            if EntityCategoryContains(ParseEntityCategory(v), target) then                          
                                arcStun = false
                            end                        
                        end

                        -- Apply stun if true                          
                        if arcStun == true then                        
                            target:SetStunned(1)                                     
                        end                                                          

                        -- Set the beam damage equal to a fraction of the projectiles avalible DMG pool
                        local beamDmgAmt = self.DamageData.DamageAmount * 0.05                     

                        -- Reduce the projectiles DamageAmount by what the beam amount did
                        self.DamageData.DamageAmount = self.DamageData.DamageAmount - beamDmgAmt                       

                        -- Damage and stun target                 
                        Damage(self:GetLauncher(), target:GetPosition(), target, beamDmgAmt, 'Normal')
                    end                                                           
                end                                                                  
            end            
            -- Small delay so that the beam and FX are visable
            WaitTicks(2)            
            -- Remove all FX
            for k, v in arcFXBag do
                v:Destroy()
            end            
            arcFXBag = {}              
            -- Small delay to show the FX removal
            WaitTicks(Random(2,5))                         
        end
    end,
    
    OnImpact = function(self, TargetType, targetEntity)   
        -- Basic impact decals
        local rotation = RandomFloat(0,6.28)        

        CreateDecal(self:GetPosition(), rotation, 'crater_radial01_normals', '', 'Alpha Normals', 2, 2, 120, 0, self:GetArmy())
        CreateDecal(self:GetPosition(), rotation, 'crater_radial01_albedo', '', 'Albedo', 4, 4, 120, 0, self:GetArmy()) 

        BFG_Projectile.OnImpact( self, TargetType, targetEntity )
    end,        
}
TypeClass = BFG_Shell