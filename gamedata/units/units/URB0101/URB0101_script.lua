
local CLandFactoryUnit = import('/lua/cybranunits.lua').CLandFactoryUnit

URB0101 = Class(CLandFactoryUnit) {
    BuildAttachBone = 'Attachpoint',
    UpgradeThreshhold1 = 0.167,
    UpgradeThreshhold2 = 0.5,
}
TypeClass = URB0101