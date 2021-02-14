-- global score data can be read from directly
scoreData = {}
scoreData.current = {}
fullSyncOccured = false

-- score interval determines how often the historical data gets updated, this is in seconds
scoreInterval = 10

function UpdateScoreData(newData)
    scoreData.current = table.deepcopy(newData)
end

function OnFullSync()
    fullSyncOccured = true
end

-- Just enable historical tracking 

scoreData.historical = {} 

-- copy data over to historical 
local curInterval = 1 
local scoreInterval = 10 
local click=0 

function beat() 
    click=click+1 
    if click>(scoreInterval*10) then 
    click=0 
    scoreData.historical[curInterval] = table.deepcopy(scoreData.current) 
        curInterval = curInterval + 1 
    end 
end 

import('/lua/ui/game/gamemain.lua').AddBeatFunction(beat) 

function StopScoreUpdate() 
    import('/lua/ui/game/gamemain.lua').RemoveBeatFunction(beat) 
end