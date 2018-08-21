local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
--local Weather = import('/lua/weather.lua') 

function OnPopulate()
	ScenarioUtils.InitializeArmies()
--	Weather.CreateWeather() 
end

function OnStart(self)
end
