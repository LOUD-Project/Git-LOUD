--  File     :  /lua/sim/StrategyBuilder.lua
--  Summary  : Strategy Builder class

local AIUtils = import('/lua/ai/aiutilities.lua')
local Builder = import('/lua/sim/Builder.lua').Builder


# StrategyBuilderSpec
# This is the spec to have analyzed by the StrategyManager
#{
#   BuilderData = {
#       Some stuff could go here, eventually.
#   }
#}

StrategyBuilder = Class(Builder) {
    Create = function(self,brain,data)
        Builder.Create(self,brain,data)
        return true
    end,
    
}

function CreateStrategy(brain, data)
    local builder = StrategyBuilder()
    if builder:Create(brain, data) then
        return builder
    end
    return false
end
