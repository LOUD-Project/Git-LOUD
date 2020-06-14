--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
do
    local OldCreateInitialArmyGroup = CreateInitialArmyGroup
    function CreateInitialArmyGroup(strArmy, createCommander)
        if createCommander then
            AddBuildRestriction(strArmy, categories.RESEARCHLOCKED + categories.RESEARCHLOCKEDTECH1 + categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL)
            local AIBrain = GetArmyBrain(strArmy)
            AIBrain.BrewRND.Init(AIBrain)
        end
        return OldCreateInitialArmyGroup(strArmy, createCommander)
    end

    local OldCreateResources = CreateResources
    function CreateResources()
        if not ScenarioInfo.WindStats then
            ScenarioInfo.WindStats = {Thread = ForkThread(WindThread)}
        end
        OldCreateResources()
    end

    function WindThread()
        WaitTicks(26)
        --Declared locally for performance, since they are used a lot.
        local LOUDRAND = math.random
        local LOUDMIN = math.min
        local LOUDMAX = math.max
        local LOUDMOD = math.mod
        while true do
            ScenarioInfo.WindStats.Power = LOUDMIN(LOUDMAX( (ScenarioInfo.WindStats.Power or 0.5) + 0.5 - LOUDRAND(),0),1)
            --Defines a real number, starting from 0.5, between 0 and 1 that randomly fluctuates by up to 0.5 either direction.
            --math.random() with no args returns a real number between 0 and 1
            ScenarioInfo.WindStats.Direction = LOUDMOD((ScenarioInfo.WindStats.Direction or LOUDRAND(0,360)) + LOUDRAND(-5,5) + LOUDRAND(-5,5) + LOUDRAND(-5,5) + LOUDRAND(-5,5), 360)
            --Defines an int between 0 and 360, that fluctuates by up to 20 either direction, with a strong bias towards 0 fluctuation, that cylces around when 0 or 360 is exceeded.
            WaitTicks(30 + 1)
            --Wait ticks waits 1 less tick than it should. #timingissues
        end
    end
end
