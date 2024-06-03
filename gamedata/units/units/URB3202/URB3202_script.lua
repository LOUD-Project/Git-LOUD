local CSonarUnit = import('/lua/defaultunits.lua').SonarUnit

URB3202 = Class(CSonarUnit) {
    TimedSonarTTIdleEffects = {
        { Bones = {'URB3202'}, Offset = {0,-0.8,0}, Type = 'SonarBuoy01' },
    },
}

TypeClass = URB3202