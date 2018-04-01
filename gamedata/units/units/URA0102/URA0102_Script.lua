
local CAirUnit = import('/lua/cybranunits.lua').CAirUnit
local CAAAutocannon = import('/lua/cybranweapons.lua').CAAAutocannon

URA0102 = Class(CAirUnit) {

    Weapons = {
        AutoCannon = Class(CAAAutocannon) {},
    },
}

TypeClass = URA0102
