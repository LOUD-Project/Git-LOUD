
local ASonarUnit = import('/lua/aeonunits.lua').ASonarUnit

UAB3202 = Class(ASonarUnit) {
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'Probe',
            },
            Type = 'SonarBuoy01',
        },
    },
}

TypeClass = UAB3202