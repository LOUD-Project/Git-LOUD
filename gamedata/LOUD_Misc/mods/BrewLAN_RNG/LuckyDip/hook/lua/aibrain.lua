--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
AIBrain = Class(AIBrain) {
--------------------------------------------------------------------------------
--  Summary:  BrewcklOps Raffle!
--------------------------------------------------------------------------------
    LuckyDip = function(self, strArmy)
        local ScenarioFramework = import('/lua/ScenarioFramework.lua')

        for array, group in import('/mods/BrewLAN_RNG/LuckyDip/bag.lua').LuckyDipUnitBag do
            local groupchoices = {}
            for i, v in group do
                if __blueprints[v] then
                    table.insert(groupchoices,v)
                end
            end
            if table.getn(groupchoices) > 1 then
                local winner = math.random(1,table.getn(groupchoices))
                for i, v in groupchoices do
                    if i ~= winner then
                        ScenarioFramework.AddRestriction(strArmy, categories[v])
                    end
                end
            end
        end
    end,
}
