-- Hook for Mass Point RNG mod
-- This modifies the coordsTbl based on mod configuration

do
    local OldCreateResources = CreateResources

    function CreateResources()
        
        -- Check if MassPointRNG is enabled and get mod config
        if ScenarioInfo.MassPointRNG then
            
            local modConfig = {}
            
            -- Find the MassRandom mod config
            for _, v in __active_mods do
                if v.uid == '25D57D85-7D84-27HT-A502-MASSRNG00002' then
                    modConfig = v.config
                    break
                end
            end
            
            -- Get the selected distribution type
            local distributionType = modConfig['MassDistribution'] or 'Normal'
            
            LOG("*AI DEBUG Mass Point RNG Distribution Type: " .. distributionType)
            
            -- Store the distribution type for use in CreateResources
            ScenarioInfo.MassDistributionType = distributionType
        end
        
        -- Call the original function
        OldCreateResources()
    end
end
