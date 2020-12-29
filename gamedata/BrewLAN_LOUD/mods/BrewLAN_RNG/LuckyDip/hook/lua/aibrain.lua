--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
local LuckyDipUnitBag = {
    -- UEF T1 tank
    {
        'uel0201', -- Striker
        'uel0108', -- Crusher
    },
    -- UEF T1 PD
    {
        'ueb2101', -- DM1 Plasma Cannon
        'brnt1hpd', -- Thug
    },
    -- UEF T2 tank
    {
        'uel0202', -- Pillar
        'brnt2mt', -- Statue
    },
    -- UEF T2 PD
    {
        'ueb2301', -- Triad
        'brnt2pd2', -- Angry Ace
        'brnt2epd', -- Tower Boss
    },
    -- UEF T3 assault bot
    {
        'xel0305', -- Percival
        'brnt3abb', -- Ironfist
    },
    -- UEF T3 skirmish bot
    {
        'uel0303', -- Titan
        'wel0302', -- Wrecker
    },
    -- UEF T3 mobile artillery
    {
        'uel0304', -- Demolisher
        'wel03041', -- Walrus
    },
    -- UEF T3 tank
    {
        'brnt3wt', -- Warhammer
        'brnt3bt', -- Bull
        'xel0307', -- Juggernaut
        'bel0307', -- Helltank
        'wel0304', -- Rommel
    },
    -- UEF T3 mobile AA
    {
        'belk002', -- Cougar
        'sel0324', -- NG3 Longbow
        'xel0308', -- Hermes
        'wel0309', -- Banisher
    },
    -- UEF T3 PD
    {
        'xeb2306', -- Ravager
        'ueb2306', -- Brimstone
    },
    -- UEF T4 light
    {
        'brnt3ow', -- Owens
        'uel0402', -- Rampage
    },
    -- UEF T4 medium
    {
        'wel4404', -- Star Adder
        'brnt3blasp', -- Blood Asp
    },
    -- FATBOY
    {
        'uel0401', -- Fatboy
        'wel0401', -- Wyvern
        'wel1409', -- Fatboy II
    },
    -- UEF T4 heavy
    {
        'bel0402', -- Goliath
        'brnt3shbm', -- Mayhem
    },
    -- Citadel
    {
        'bea0403', -- Mk 1
        'bea0402', -- Mk 2
    },
    -- UEF T4 AA
    {
        'veb2302', -- Flayer II
        'seb2402', -- Maelstrom
    },
    -- Cybran T1 bot
    {
        'url0107', -- Mantis
        'brmt1exm1', -- Proton
    },
    -- Cybran T1 PD
    {
        'urb2101', -- Auto Gun
        'brmt1pd', -- Slyfox
    },
    -- Cybran T2 tank
    {
        'url0202', -- Rhino
        'brmt2ht', -- Hippo
    },
    -- Cybran T2 PD
    {
        'urb2301', -- Cerberus
        'brmt2pd', -- Slingshot
    },
    -- Cybran T3 amphib bot
    {
        'xrl0305', -- Brick
        'url0305', -- Crawfish
        'brmt3bm2', -- Dervish
    },
    -- Cybran T3 tank
    {
        'brmt3bt', -- Mastodon
        'wrl0301', -- Sealion
    },
    -- Cybran T3 mobile AA
    {
        'brlk001', -- Bouncer
        'srl0320', -- Slink
        'brmt3lzt', -- Trilobyte
        'wrl0309', -- Python
    },
    -- Cybran T3 MML
    {
        'srl0311', -- Hexatron
        'brmt3ml', -- Pavestone
        'brl0307', -- Hailfire
    },
    -- Cybran T3 transport
    {
        'bra0309', -- Vanisher
        'sra0306', -- Night Skimmer
    },
    -- Cybran T3 PD
    {
        'brb2306', -- Manticore
        'srb2306', -- Hades
        'brmt3pd', -- Tripple Threat
        'urb2306', -- Beholder
    },
    -- Cybran T4 light
    {
        'brmt3mcm', -- Madcat
        'brmt3vul', -- Vulture
    },
    -- Cybran T4 medium
    {
        'wrl1466', -- Storm Strider
        'url0402', -- Monkeylord
    },
    -- Cybran T4 heavy
    {
        'xrl0403', -- Megalith
        'brmt3mcm2', -- MadBolo
    },
    -- Cybran T4 superheavy
    {
        'wrl0404', -- Megaroach
        'brmt3ava', -- Avalanche
    },
    -- Soul Ripper
    {
        'ura0401', -- Mk 1
        'wra0401', -- Mk 2
    },
    -- Seadragon
    {
        'xrs0402', -- Mk 1
        'brs0402', -- Mk 2
    },
    -- Aeon T1 tank
    {
        'ual0201', -- Aurora
        'brot1mt', -- Bonfire
        'brot1bt', -- Hervour
    },
    -- Aeon T1 assault bot
    {
        'ual0108', -- Artos
        'brot1exm1', -- Medusa
    },
    -- Aeon T1 artillery
    {
        'ual0103', -- Fervor
        'brot1ml', -- Wavecrest
    },
    -- Aeon T1 PD
    {
        'uab2101', -- Erupter
        'brot1hpd', -- Zpyker
    },
    -- Aeon T2 heavy tank
    {
        'ual0202', -- Obsidian
        'bal0206', -- Zealot
    },
    -- Aeon T3 tank
    {
        'bal0310', -- Wraith
        'sal0311', -- Moldavite
        'brot3bt', -- Transoma
    },
    -- Aeon T3 assault bot
    {
        'ual0303', -- Harbinger
        'brot3hm', -- Mogul
    },
    -- Aeon T3 mobile AA
    {
        'balk003', -- Redeemer
        'sal0320', -- Armillary
        'ual0310', -- Vindicator
    },
    -- Aeon T3 PD
    {
        'bab2306', -- Aria
        'sab2306', -- Orbos
        'uab2306', -- Anachronon
    },
    -- Aeon T4 light
    {
        'brot3ham', -- Ezriel
        'wal4404', -- Maruda
    },
    -- Aeon T4 medium
    {
        'brot3shbm', -- Elias
        'ual0402', -- Overlord
        'brot3ncm', -- Eliash
    },
    -- Aeon T4 heavy
    {
        'ual0401', -- Galactic Colossus
        'wal0401', -- Universal Colossus
    },
    -- Aeon T4 hover tank
    {
        'bal0402', -- Genesis
        'sal0401', -- Absolution
    },
    -- Aeon T4 naval
    {
        'uas0401', -- Tempest
        'sas0401', -- Deluge
    },
    -- Sera T1 tank
    {
        'xsl0201', -- Thaam
        'brpt1ht', -- Yenshavoh
    },
    -- Sera T1 PD
    {
        'ssb2380', -- Uttaus
        'brpt1pd', -- Hethula-Uttaus
    },
    -- Sera T2 assault bot
    {
        'xsl0202', -- Ilshavoh
        'brpt2btbot', -- Iltha
    },
    -- Sera T3 tank
    {
        'xsl0303', -- Othuum
        'wsl0308', -- Otheeka
        'brpt3bt', -- Hethaamah
    },
    -- Sera T3 assault bot
    {
        'ssl0311', -- Ilshatha
        'bsl0310', -- Ilthysathuum
        'brpt3bot', -- Thaam-Thuum
    },
    -- Sera T3 mobile artillery
    {
        'xsl0304', -- Suthanus
        'brpt3ml', -- Heth-Zthuha
    },
    -- Sera T3 mobile AA
    {
        'bslk004', -- Uyanah
        'ssl0320', -- Atha-Ythia
    },
    -- Sera T3 transport
    {
        'bsa0309', -- Vishathal-Atah
        'ssa0306', -- Vishuum
    },
    -- Sera T3 gunship
    {
        'bsa0310', -- Vulthatha-Ioz
        'ssa0305', -- Vulthuum
    },
    -- Sera T3 PD
    {
        'bsb2306', -- Uttauthuum
        'ssb2306', -- Othuushala
        'brpt3pd', -- Athaamla
    },
    -- Sera T4 light
    {
        'brpextank', -- Yath-us
        'wsl0404', -- Yath-yen
        'bsl0406', -- Seth Ilhaas
    },
    -- Sera T4 medium
    {
        'brpexbot', -- Yenah-lao
        'bsl0401', -- Yenzotha
        'brpexhvbot', -- Athusil
    },
    -- Sera T4 heavy
    {
        'brpexshbm', -- Thaez-Itha
        'wsl0405', -- Echibum
        'xsl0401', -- Ythotha
    },
    -- Sera T4 naval
    {
        'bss0401', -- Hovatha-hauthu
        'xss0403', -- Vergra
    },
    -- Sera T4 factory
    {
        'ssb0401', -- Souiya
        'bsb2402', -- Haasioz-Iya
    },
    -- Sera T4 PD
    {
        'bsb0405', -- Uttaus-Athellu
        'brpexpd', -- Heth-Athala
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
                    if i ~= winner then
                        ScenarioFramework.AddRestriction(strArmy, categories[v])
                    end
                end
            end
        end
    end,
}
