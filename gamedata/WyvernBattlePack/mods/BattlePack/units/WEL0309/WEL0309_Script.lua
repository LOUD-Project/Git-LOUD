local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

WEL0309 = Class(TLandUnit) {
    Weapons = {
        AA = Class(TSAMLauncher) {
        }
    },
}

TypeClass = WEL0309