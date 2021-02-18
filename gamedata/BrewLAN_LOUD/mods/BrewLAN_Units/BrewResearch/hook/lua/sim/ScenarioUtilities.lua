--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
do
    
    local function RnDLuckyDipSetup(strArmy, AIBrain)
        AIBrain.LDipRestricts = categories.NOTHINGIMPORTANT
        AIBrain.LDipUnrestricts = {
            TECH1 = categories.NOTHINGIMPORTANT,
            TECH2 = categories.NOTHINGIMPORTANT,
            TECH3 = categories.NOTHINGIMPORTANT,
            EXPERIMENTAL = categories.NOTHINGIMPORTANT,
        }

        local bag = import('/mods/BrewLAN_RNG/LuckyDip/bag.lua').LuckyDipUnitBag
        for array, group in bag do
            local groupchoices = {}
            for i, v in group do
                if __blueprints[v] then
                    table.insert(groupchoices,v)
                end
            end
            if table.getn(groupchoices) > 1 then
                local winner = math.random(1, table.getn(groupchoices))
                for i, v in groupchoices do
                    if i ~= winner then
                        -- Prevent building this unit, and don't unlock it
                        -- when a new Tech level is researched, either
                        AddBuildRestriction(strArmy, categories[v])
                        AIBrain.LDipRestricts = AIBrain.LDipRestricts + categories[v]
                    else
                        -- Don't research lock lucky winner units at tech 1;
                        -- don't show research items for any lucky winners
                        if table.find(__blueprints[v].Categories, 'TECH1') then
                            AIBrain.LDipUnrestricts.TECH1 = AIBrain.LDipUnrestricts.TECH1 + categories[v]
                        elseif table.find(__blueprints[v].Categories, 'TECH2') then
                            AIBrain.LDipUnrestricts.TECH2 = AIBrain.LDipUnrestricts.TECH2 + categories[v]
                        elseif table.find(__blueprints[v].Categories, 'TECH3') then
                            AIBrain.LDipUnrestricts.TECH3 = AIBrain.LDipUnrestricts.TECH3 + categories[v]
                        elseif table.find(__blueprints[v].Categories, 'EXPERIMENTAL') then
                            AIBrain.LDipUnrestricts.EXPERIMENTAL = AIBrain.LDipUnrestricts.EXPERIMENTAL + categories[v]
                        end
                        AIBrain.LDipRestricts = AIBrain.LDipRestricts + categories[v..'rnd']
                        AddBuildRestriction(strArmy, categories[v..'rnd'])
                    end
                end
            end
        end
    end

    local OldCreateInitialArmyGroup = CreateInitialArmyGroup
    function CreateInitialArmyGroup(strArmy, createCommander)
        if createCommander then
            -- AddBuildRestriction(strArmy, categories.RESEARCHLOCKED + categories.RESEARCHLOCKEDTECH1 + categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL)
            local AIBrain = GetArmyBrain(strArmy)

            -- RAT: Not pretty having to check this for every army, but 
            -- I'd rather not litter this module with variables
            local ldipEnabled = false
            local ldipConfig = false
            for _, v in __active_mods do
                if v.uid == '25D57D85-9JA7-LOUD-BREW-RESEARCH00005' then
                    if v.config['LuckyDip'] == 'on' then
                        ldipConfig = true
                    end
                elseif v.uid == '25D57D85-7D84-27HT-A502-LDIPS0000002' then
                    ldipEnabled = true
                end
            end
            if ldipEnabled and ldipConfig then
                LOG("R&D: Applying LuckyDip restrictions")
                RnDLuckyDipSetup(strArmy, AIBrain)
            end

            AddBuildRestriction(strArmy, 
                (categories.RESEARCHLOCKED + categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL) - 
                (AIBrain.LDipUnrestricts.TECH1 or categories.NOTHINGIMPORTANT))
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
        -- Declared locally for performance, since they are used a lot.
        local LOUDRAND = math.random
        local LOUDMIN = math.min
        local LOUDMAX = math.max
        local LOUDMOD = math.mod
        while true do
            ScenarioInfo.WindStats.Power = LOUDMIN(LOUDMAX((ScenarioInfo.WindStats.Power or 0.5) + 0.5 - LOUDRAND(), 0), 1)
            -- Defines a real number, starting from 0.5, between 0 and 1 that randomly fluctuates by up to 0.5 either direction.
            -- math.random() with no args returns a real number between 0 and 1
            ScenarioInfo.WindStats.Direction = LOUDMOD((ScenarioInfo.WindStats.Direction or
            LOUDRAND(0, 360)) + LOUDRAND(-5, 5) + LOUDRAND(-5, 5) + LOUDRAND(-5, 5) + LOUDRAND(-5, 5), 360)
            -- Defines an int between 0 and 360, that fluctuates by up to 20 either direction,
            -- with a strong bias towards 0 fluctuation, that cylces around when 0 or 360 is exceeded.
            WaitTicks(30 + 1)
            -- Wait ticks waits 1 less tick than it should. #timingissues
        end
    end
end
