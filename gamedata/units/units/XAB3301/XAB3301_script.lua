
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

# Setup as RemoteViewing child of AStructureUnit
local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing
AStructureUnit = RemoteViewing( AStructureUnit )

XAB3301 = Class( AStructureUnit ) {
}

TypeClass = XAB3301