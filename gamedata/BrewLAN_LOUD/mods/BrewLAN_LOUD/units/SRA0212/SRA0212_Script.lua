local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CAAAutocannon = import('/lua/cybranweapons.lua').CAAAutocannon

SRA0102 = Class(CAirUnit) {
    Weapons = {
        AutoCannon = Class(CAAAutocannon) {},
    },
}

TypeClass = SRA0102
