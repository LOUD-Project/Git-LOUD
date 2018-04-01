#****************************************************************************
# UserMusic
# Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#
#****************************************************************************

#****************************************************************************
# Config options
#****************************************************************************

# List of battle cues to cycle through
local BattleCues = {
    Sound({Cue = 'Battle', Bank = 'Music'}),
}

# List of peace cues to cycle through
local PeaceCues = {
    Sound( { Cue = 'Base_Building', Bank = 'Music' } ),
}

# How many battle events do we receive before switching to battle music
local BattleEventThreshold = 20

# Current count of battle events
local BattleEventCounter = 0

# How many ticks can elapse between NotifyBattle events before we reset the
# BattlceEventCounter (only used in peace time)
local BattleCounterReset = 30 # 3 seconds

# How many ticks of battle inactivity until we switch back to peaceful music
local PeaceTimer = 200 # 20 seconds

#****************************************************************************
# Internal
#****************************************************************************

# The last tick in which we got a battle notification
local LastBattleNotify = 0

# Current music loop if music is active
local Music = false

# Watcher thread
local MusicThread = false

# Tick when battle started, or 0 if at peace
local BattleStart = 0


local BattleCueIndex = 1
local PeaceCueIndex = 1

function NotifyBattle()

    local tick = GameTick()
    local prevNotify = LastBattleNotify
    LastBattleNotify = tick

    #LOG("*** NotifyBattle, tick=" .. repr(tick))

    if BattleStart == 0 then
        if tick - prevNotify > BattleCounterReset then
            BattleEventCounter = 1
        else
            BattleEventCounter = BattleEventCounter + 1
            if BattleEventCounter > BattleEventThreshold then
                StartBattleMusic()
            end
        end
    end
end


function StartBattleMusic()
    #LOG("*** StartBattleMusic")
    if Music then
        StopSound(Music,true) # true means stop immediately
        Music = false
    end
    #LOG('*** PLAYING BATTLE ', BattleCueIndex)
    Music = PlaySound( BattleCues[BattleCueIndex] )
    BattleCueIndex = math.mod(BattleCueIndex,table.getn(BattleCues)) + 1
    BattleStart = GameTick()

    if MusicThread then KillThread(MusicThread) end
    MusicThread = ForkThread(
        function ()
            while GameTick() - LastBattleNotify < PeaceTimer do
                WaitSeconds(1)
            end
            MusicThread = false # clear MusicThread so that StartPeaceMusic doesn't kill us.
            StartPeaceMusic(true)
        end
    )
end

function StartPeaceMusic()
    #LOG("*** StartPeaceMusic")
    BattleStart = 0
    BattleEventCounter = 0
    LastBattleNotify = GameTick()

    if MusicThread then KillThread(MusicThread) end
    MusicThread = ForkThread(
        function()
            if Music then
                #LOG('*** FADING MUSIC')
                StopSound(Music) # fade out
                WaitFor(Music)
                #LOG('**** DONE FADE')
                Music = false
            end

            WaitSeconds(3)

            #LOG('*** PLAYING PEACE ', PeaceCueIndex)
            Music = PlaySound( PeaceCues[PeaceCueIndex] )
            PeaceCueIndex = math.mod(PeaceCueIndex,table.getn(PeaceCues)) + 1
        end
    )
end
