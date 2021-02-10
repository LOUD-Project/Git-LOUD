local oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {
    OnCreateHuman = function(self, planName)
        oldAIBrain.OnCreateHuman(self, planName)
        self.GenerateCities(self)
    end,

    OnCreateAI = function(self, planName)
        oldAIBrain.OnCreateAI(self, planName)
        self.GenerateCities(self)
    end,

    GenerateCities = function(self)
        local modConfig = {}
        for _, v in __active_mods do
            if v.uid == '190261d0-4bb0-11e2-bcSC-CITIES000001' then
                modConfig = v.config
                break
            end
        end

        -- default if options if not defined
        local opt = modConfig.CityscapesSpawn or 'EmptySpots'
        local opt2 = modConfig.CityscapesTeam or 'Civilian'
        local opt3 = modConfig.CityscapesExpansion or 'Disabled'
        local opt4 = modConfig.CityscapesLargeExpansion or 'Enabled'
        local opt5 = modConfig.CityscapesObjective or 'Disabled'

        if opt ~= 'false' or opt3 == 'Enabled' or opt4 == 'Enabled' or opt5 == 'Enabled' then

            local civilian = false
            for name,data in ScenarioInfo.ArmySetup do
                if name == self.Name then
                    civilian = data.Civilian
                    break
                end
            end

            if civilian and ScenarioInfo.CivCity then
                return -- this is the second civ faction
            elseif civilian and not ScenarioInfo.CivCity then
                ScenarioInfo.CivCity = true
            end

            local AIGetMarkerLocations = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
            local OpenStartZones = {}
            if opt ~= 'false' then
                for i, army in AIGetMarkerLocations('Start Location') do
                    if (civilian and not ScenarioInfo.ArmySetup[army.Name] and (opt == 'EmptySpots' or opt == 'AllSlots'))
                    or (civilian and opt2 == 'Civilian' and ScenarioInfo.ArmySetup[army.Name] and opt == 'OccupiedSlots')
                    or (civilian and opt2 == 'Civilian' and opt == 'AllSlots')
                    or (not civilian and opt2 ~= 'Civilian' and (opt == 'AllSlots' or opt == 'OccupiedSlots') and self.Name == army.Name) then
                        OpenStartZones[army.Name] = army.Position
                    end
                end
            end
            if opt3 == 'Enabled' and civilian then
                for i, marker in AIGetMarkerLocations('Expansion Area') do
                    OpenStartZones[marker.Name] = marker.Position
                end
            end
            if opt4 == 'Enabled' and civilian then
                for i, marker in AIGetMarkerLocations('Large Expansion Area') do
                    OpenStartZones[marker.Name] = marker.Position
                end
            end
            if opt5 == 'Enabled' and civilian then
                for i, marker in AIGetMarkerLocations('Objective') do
                    OpenStartZones[marker.Name] = marker.Position
                end
            end
            if table.getsize(OpenStartZones) > 0 then
                for armyname, MarkerPos in OpenStartZones do
                    local CityFunction, CityData = import('/lua/sim/ScenarioUtilities.lua').GetRandomCityFactionGenerator()
                    if CityFunction and CityData then
                        self:ForkThread(CityFunction, CityData, table.copy(MarkerPos))
                    end
                end
            end
        end
    end,
}
