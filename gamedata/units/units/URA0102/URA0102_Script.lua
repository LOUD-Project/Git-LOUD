local CAirUnit = import('/lua/defaultunits.lua').AirUnit
local CAAAutocannon = import('/lua/cybranweapons.lua').CAAAutocannon

URA0102 = Class(CAirUnit) {

    Weapons = {
        AutoCannon = Class(CAAAutocannon) {},
    },
}

TypeClass = URA0102
