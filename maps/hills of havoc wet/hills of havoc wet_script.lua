local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

function OnPopulate()
  ScenarioUtils.InitializeArmies()
end

function OnStart(self)
end
