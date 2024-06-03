local CLandFactoryUnit = import('/lua/cybranunits.lua').CLandFactoryUnit

URB0201 = Class(CLandFactoryUnit) {
    BuildAttachBone = 'Attachpoint',
    UpgradeThreshhold1 = 0.267,
    UpgradeThreshhold2 = 0.53,
}
TypeClass = URB0201