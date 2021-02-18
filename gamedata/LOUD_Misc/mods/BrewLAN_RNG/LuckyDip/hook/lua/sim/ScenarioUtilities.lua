--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
do
    local OldCreateInitialArmyGroup = CreateInitialArmyGroup
    function CreateInitialArmyGroup(strArmy, createCommander)
        -- If R&D is enabled and affecting Lucky Dip (on by default), don't run normal LuckyDip
        local go = true
        for _, v in __active_mods do
            if v.uid == "25D57D85-9JA7-LOUD-BREW-RESEARCH00005" then
                if v.config['LuckyDip'] == 'on' then
                    LOG("LUCKYDIP: R&D/LuckyDip interaction enabled; aibrain.lua hook will not be invoked")
                    go = false
                end
                break
            end
        end

        if createCommander and go then
            GetArmyBrain(strArmy):LuckyDip(strArmy)
        end
        return OldCreateInitialArmyGroup(strArmy, createCommander)
    end
end
