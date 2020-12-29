--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
local LuckyDipUnitBag = {
    -- T3 Point defences
    {
        'bab2306', -- Aria
        'sab2306', -- Orbos
    },
    {
        'bsb2306', -- Uttauthuum
        'ssb2306', -- Othuushala
    },
    --T3 transport
    {
        'bra0309', -- Vanisher
        'sra0306', -- Night Skimmer
    },
    {
        'baa0309', -- Illuminate
        'saa0306', -- Solaris
    },
    {
        'bsa0309', -- Vishathal-Atah
        'ssa0306', -- Vishuum
    },
    -- Sera T3 gunship
    {
        'bsa0310', -- Vulthatha-Ioz
        'ssa0305', -- Vulthuum
    },
    -- T3 mobile AA
    {
        'balk003', -- Redeemer
        'sal0320', -- Armillary
    },
    {
        'belk002', -- Cougar
        'sel0324', -- NG3 Longbow
    },
    {
        'brlk001', -- Bouncer
        'srl0320', -- Slink
    },
    -- Aeon T3 tank
    {
        'bal0310', -- Wraith
        'sal0311', -- Moldavite
    },
}

AIBrain = Class(AIBrain) {
--------------------------------------------------------------------------------
--  Summary:  BrewcklOps Raffle!
--------------------------------------------------------------------------------
    LuckyDip = function(self, strArmy)
        local ScenarioFramework = import('/lua/ScenarioFramework.lua')

        for array, group in LuckyDipUnitBag do
            local groupchoices = {}
            for i, v in group do
                if __blueprints[v] then
                    table.insert(groupchoices,v)
                end
            end
            if table.getn(groupchoices) > 1 then
                local winner = math.random(1,table.getn(groupchoices))
                for i, v in groupchoices do
                    if i == winner then
                        LOG("BrewLAN LuckyDip: A WINNAR IS " .. v)
                    else
                        ScenarioFramework.AddRestriction(strArmy, categories[v])
                    end
                end
            end
        end
    end,
}
