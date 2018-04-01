local TSonarUnit = import('/lua/terranunits.lua').TSonarUnit

UEB3202 = Class(TSonarUnit) {
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'UEB3202',
            },
            Offset = {
                0,
                -1.3,
                0,
            },
            Type = 'SonarBuoy01',
        },
    },
}

TypeClass = UEB3202