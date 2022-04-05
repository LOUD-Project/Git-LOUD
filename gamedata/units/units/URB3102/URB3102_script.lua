
local CSonarUnit = import('/lua/defaultunits.lua').SonarUnit

URB3102 = Class(CSonarUnit) {
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'URB3102',
            },
            Offset = {
                0,
                -0.8,
                0,
            },
            Type = 'SonarBuoy01',
        },
    },
}

TypeClass = URB3102