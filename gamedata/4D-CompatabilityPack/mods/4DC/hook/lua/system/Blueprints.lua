----------------------------------------------------------------------
-- Drone Shield Personal Mesh Extractor Author:  Resin_Smoker 18 JULY 2010  
----------------------------------------------------------------------
do
    function ExtractCustomShieldMeshBlueprint(bp)
        
        -- Verifiy the units Mesh and Mesh ID
        local meshid = bp.Display.MeshBlueprint
        if not meshid then return end
        local meshbp = original_blueprints.Mesh[meshid]
        if not meshbp then return end 
        
        -- Check to see if the unit has a Cloak, BuildRate or Economy, if so return              
        if bp.Intel.Cloak then
            -- WARN('Mesh Extractor, reason:  Cloak ', meshid)
            return
        elseif bp.Economy.BuildRate > 1 then
            -- WARN('Mesh Extractor, reason:  BuildRate ', meshid)            
            return
        elseif bp.Economy.MaintenanceConsumptionPerSecondEnergy > 0 then 
            -- WARN('Mesh Extractor, reason:  Maint Cost', meshid)              
            return 
        end 
        
        -- Unit types the shield drone is not allowed to make shield meshes for
        local excludedCats = { 
            -- Custom unit restrictions
            'HOLOGRAM','HOLOGRAMGENERATOR','DRONE','MINE','PHASING',  
            -- Misc unit restrictions
            'POD','SATELLITE','UNTARGETABLE',
            'SHIELD','WALL','PROJECTILE', 
            'OPERATION','CIVILIAN','INSIGNIFICANTUNIT', 
            'UNSELECTABLE','BENIGN',                 
        }                                  
        
        -- Verify the unit type is one that we are allowed to enhance, if so retrun      
        for k, v in excludedCats do 
            if table.find(bp.Categories, v) then
                -- WARN('Mesh Extractor, Category not allowed: ', excludedCats[k], meshid )
                return      
            end           
        end
        
        -- Check if any of the weapons require energy to fire, if so return
        if bp.Weapon then
            for k, v in bp.Weapon do    -- table.getn(bp.Weapon)
                -- WARN(k .. " = " .. repr(v)) 
                if bp.Weapon[k].EnergyRequired > 1 then
                    -- WARN('UNIT: ', bp.General.UnitName, ' WEAPON REQUIRES ENERGY TO FIRE')
                    return 
                end             
            end
        end      
                    
        -- Set a personal shield mesh for the unit based upon that units faction         	
        local pshieldmeshbp = table.deepcopy(meshbp)
		
        if pshieldmeshbp.LODs then
		
            for i,lod in pshieldmeshbp.LODs do
			
                if table.find(bp.Categories, 'AEON') then 
                    -- WARN('### AEON mesh created for UnitID: ', meshid)
                    lod.ShaderName = 'PhaseShield'                     
                    lod.LookupName = '/effects/entities/ShieldSection01/ShieldSection01b_Albedo.dds'                  
                elseif table.find(bp.Categories, 'CYBRAN') then 
                    -- WARN('### CYBRAN mesh created for UnitID: ', meshid) 
                    lod.ShaderName = 'PhaseShield'                                                      
                    lod.LookupName = '/effects/entities/ForceField01/ForceField01_Albedo.dds'                                       
                elseif table.find(bp.Categories, 'UEF') then 
                    -- WARN('### UEF mesh created for UnitID: ', meshid)  
                    lod.ShaderName = 'PhaseShield'                                       
                    lod.LookupName = '/effects/entities/CybranPhalanxSphere01/CybranPhalanxSphere01_Normals.dds' 
                elseif table.find(bp.Categories, 'SERAPHIM') then 
                    -- WARN('### SERAPHIM mesh created for UnitID: ', meshid)   
                    lod.ShaderName = 'SeraphimPersonalShield'
                    lod.LookupName = '/effects/entities/ShieldSection01/ShieldSection01b_Albedo.dds'                  
                    lod.SecondaryName = '/effects/entities/PhaseShield/PhaseShieldLookup.dds'                                                                                            
                else    
                    -- WARN('### GENERIC mesh created for UnitID: ', meshid)                 
                    lod.ShaderName = 'PhaseShield'                                   
                    lod.LookupName = '/effects/entities/PhaseShield/PhaseShieldLookup.dds'                                               
                end
                -- Verify the end result of mesh via the WARN but comment out if not needed
                #if pshieldmeshbp.LODs then          
                #    for k, v in pshieldmeshbp.LODs do 
                #        WARN(k .. " = " ..  repr(v)) 
                #    end        
                #end                 
            end
        end
        pshieldmeshbp.BlueprintId = meshid .. '_PhaseShield'
        bp.Display.PShieldMeshBlueprint = pshieldmeshbp.BlueprintId
        MeshBlueprint(pshieldmeshbp)                  
    end		

	local OldModBlueprints = ModBlueprints
	function ModBlueprints(all_blueprints)
		OldModBlueprints(all_blueprints)
		for id,bp in all_blueprints.Unit do
			ExtractCustomShieldMeshBlueprint(bp)
		end
	end
end