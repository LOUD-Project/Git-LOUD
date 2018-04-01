
local ASonarUnit = import('/lua/aeonunits.lua').ASonarUnit

UAB3102 = Class(ASonarUnit) {
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'Probe',
            },
            Type = 'SonarBuoy01',
        },
    },
}

TypeClass = UAB3102