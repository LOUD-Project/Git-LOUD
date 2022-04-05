local TSonarUnit = import('/lua/defaultunits.lua').SonarUnit

UEB3102 = Class(TSonarUnit) {
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'B14',
            },
            Offset = {
                0,
                -0.6,
                0,
            },
            Type = 'SonarBuoy01',
        },
    },
}

TypeClass = UEB3102