#**  File     :  /lua/system/GlobalBuilderGroup.lua
#**  Summary  :  Global builder group table and blueprint methods
#**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.

BuilderGroups = {}

BuilderGroup = {}
BuilderGroupDefMeta = {}

BuilderGroupDefMeta.__index = BuilderGroupDefMeta

BuilderGroupDefMeta.__call = function(...)

    if type(arg[2]) ~= 'table' then
        LOG('Invalid BuilderGroup: ', repr(arg))
        return
    end
    
    if not arg[2].BuilderGroupName then
        WARN('Missing BuilderGroupName for BuilderGroup definition: ',repr(arg))
        return
    end
    
    if not arg[2].BuildersType then
        WARN('Missing BuildersType for BuilderGroup definition - BuilderGroupName = ' .. arg[2].BuilderGroupName)
        return
    end
    
    if arg[2].BuildersType != 'EngineerBuilder' and arg[2].BuildersType != 'FactoryBuilder' and arg[2].BuildersType != 'PlatoonFormBuilder' then
        WARN('Invalid BuildersType for BuilderGroup definition - BuilderGroupName = ' .. arg[2].BuilderGroupName)
        return
    end
    
    if BuilderGroups[arg[2].BuilderGroupName] then
        WARN('Duplicate PlatoonTemplate detected - overriding/appending old: ', arg[2].BuilderGroupName)
        for k,v in arg[2] do
            BuilderGroups[arg[2].BuilderGroupName][k] = v
        end
    else
        BuilderGroups[arg[2].BuilderGroupName] = arg[2]
    end
	
    --SPEW('BuilderGroup Registered: ', arg[2].BuilderGroupName)
	
    return arg[2].BuilderGroupName
end

setmetatable(BuilderGroup, BuilderGroupDefMeta)
