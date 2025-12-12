-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--
-- This is the user-specific top-level lua initialization file. It is run at initialization time
-- to set up all lua state for the user layer.

-- Init our language from prefs. This applies to both front-end and session init; for
-- the Sim init, the engine sets __language for us.

LOG("*DEBUG UserInit")

__language = GetPreference('options_overrides.language', '')


-- load global functions
doscript '/lua/globalInit.lua'

WaitFrames = coroutine.yield


local counter = {}

function trace(event, line)

    local info = debug.getinfo(2)
    local source = info.source or 'unknown'
    local name = info.name or info.what or'unknown'

    counter[source] = counter[source] or {}
    counter[source][name] = (counter[source][name] or 0) + 1

    if math.mod(counter[source][name], 100000) == 0 then
        --repr(info)
        --LOG(string.format('trace: %s:%s called %d times', source, name, counter[source][name]))
        --LOG(string.format('trace: %s:%s UI called %d times (%s/%s)', source, name, counter[source][name], tostring(event), tostring(line) ) )

        --LOG(debug.traceback())
        LOG(GameTick(), string.format('user trace: %s:%s called %d times', source, name, counter[source][name], tostring(event), tostring(line)))
    end

end

--debug.sethook(trace, "count")
--debug.sethook(trace, "line")

function WaitSeconds(n)
    local later = CurrentTime() + n
    WaitFrames(1)
    while CurrentTime() < later do
        WaitFrames(1)
    end
end

function PrintText(textData)
    if textData then
        local data = textData
        if type(textData) == 'string' then
            data = {text = textData, size = 14, color = 'ffffffff', duration = 5, location = 'center'}
        end
        import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
    end
end

-- lets see what this causes

AnyInputCapture = nil
AITarget = nil

DisplayAchievementScreen = nil

OpenURL = nil

PlayTutorialVO = nil

SetMovieVolume = nil
SaveOnlineAchievements = nil
SetOnlineAchievement = nil


-- a table designed to allow communication from different user states to the front end lua state
FrontEndData = {}

-- Prefetch user side data
Prefetcher = CreatePrefetchSet()


LOG("*DEBUG UserInit complete")

