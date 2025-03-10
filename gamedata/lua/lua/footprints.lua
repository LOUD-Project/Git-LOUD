-- Layer caps
LAND = 0x01
SEABED = 0x02
SUB = 0x04
WATER = 0x08
AIR = 0x10
ORBIT = 0x20

-- Flags
IgnoreStructures = 0x01

-- Each footprint spec causes pathfinding structures to be created over the entire map for units
-- with that footprint, so keep the number of entries here down to the bare minimum we actually
-- need.
--
-- The script "data/lua/tests/dump_footprints.lua" can be used to figure out what footprint shapes
-- the blueprints are currently expecting.

SpecFootprints {
	{ Name = 'Vehicle0x0',   SizeX=0,  SizeZ=0,  Caps=LAND, MaxWaterDepth=25, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'Vehicle1x1',   SizeX=1,  SizeZ=1,  Caps=LAND, MaxWaterDepth=0.05, MaxSlope=0.75, Flags=0 },
    { Name = 'Vehicle2x2',   SizeX=2,  SizeZ=2,  Caps=LAND, MaxWaterDepth=0.05, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'Vehicle5x5',   SizeX=5,  SizeZ=5,  Caps=LAND, MaxWaterDepth=0.05, MaxSlope=0.75, Flags=IgnoreStructures },

	{ Name = 'Amphibious0x0',   SizeX=0,  SizeZ=0,  Caps=LAND|SEABED, MaxWaterDepth=25, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'Amphibious1x1',   SizeX=1,  SizeZ=1,  Caps=LAND|SEABED, MaxWaterDepth=40, MaxSlope=0.75, Flags=0 },
    { Name = 'Amphibious2x2',   SizeX=2,  SizeZ=2,  Caps=LAND|SEABED, MaxWaterDepth=40, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'Amphibious3x3',   SizeX=3,  SizeZ=3,  Caps=LAND|SEABED, MaxWaterDepth=40, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'Amphibious6x6',   SizeX=6,  SizeZ=6,  Caps=LAND|SEABED, MaxWaterDepth=40, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'Amphibious8x8',   SizeX=8,  SizeZ=8,  Caps=LAND|SEABED, MaxWaterDepth=40, MaxSlope=0.75, Flags=IgnoreStructures },    

	{ Name = 'WaterLand0x0',   SizeX=0,  SizeZ=0,  Caps=LAND|WATER, MaxWaterDepth=1, MinWaterDepth=0.1, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'WaterLand1x1',   SizeX=1,  SizeZ=1,  Caps=LAND|WATER, MaxWaterDepth=1, MinWaterDepth=0.1, MaxSlope=0.75, Flags=0 },
    { Name = 'WaterLand2x2',   SizeX=2,  SizeZ=2,  Caps=LAND|WATER, MaxWaterDepth=1, MinWaterDepth=0.1, MaxSlope=0.75, Flags=0 },
    { Name = 'WaterLand3x3',   SizeX=3,  SizeZ=3,  Caps=LAND|WATER, MaxWaterDepth=5, MinWaterDepth=0, MaxSlope=0.75, Flags=0 },
    { Name = 'WaterLand5x5',   SizeX=5,  SizeZ=5,  Caps=LAND|WATER, MaxWaterDepth=5, MinWaterDepth=0, MaxSlope=0.75, Flags=0 },
    { Name = 'WaterLand6x6',   SizeX=6,  SizeZ=6,  Caps=LAND|WATER, MaxWaterDepth=5, MinWaterDepth=0, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'WaterLand8x8',   SizeX=8,  SizeZ=8,  Caps=LAND|WATER, MaxWaterDepth=5, MinWaterDepth=0, MaxSlope=0.75, Flags=IgnoreStructures },
    
	{ Name = 'SurfacingSub0x0',   SizeX=0,  SizeZ=0,  Caps=SUB|WATER, MinWaterDepth=1.5, Flags=IgnoreStructures },
    { Name = 'SurfacingSub2x2',   SizeX=2,  SizeZ=2,  Caps=SUB|WATER, MinWaterDepth=1.5, Flags=0 },
    { Name = 'SurfacingSub3x3',   SizeX=3,  SizeZ=3,  Caps=SUB|WATER, MinWaterDepth=1.5, Flags=0 },
    { Name = 'SurfacingSub4x4',   SizeX=4,  SizeZ=4,  Caps=SUB|WATER, MinWaterDepth=1.5, Flags=0 },
    { Name = 'SurfacingSub12x12', SizeX=12, SizeZ=12, Caps=SUB|WATER, MinWaterDepth=1.5, Flags=0 },

	{ Name = 'Water0x0',   SizeX=0,  SizeZ=0,  Caps=WATER, MaxWaterDepth=25, MinWaterDepth=0, MaxSlope=0.75, Flags=IgnoreStructures },
    { Name = 'Water1x1',   SizeX=1,  SizeZ=1,  Caps=WATER, MinWaterDepth=1.5, Flags=0 },
    { Name = 'Water3x3',   SizeX=3,  SizeZ=3,  Caps=WATER, MinWaterDepth=0.25, Flags=0 },
    { Name = 'Water4x4',   SizeX=4,  SizeZ=4,  Caps=WATER, MinWaterDepth=1.5, Flags=0 },
    { Name = 'Water6x6',   SizeX=6,  SizeZ=6,  Caps=WATER, MinWaterDepth=1.5, Flags=0 },
    { Name = 'Water8x8',   SizeX=8,  SizeZ=8,  Caps=WATER, MinWaterDepth=1.5, Flags=0 },
--    { Name = 'Water11x11', SizeX=11, SizeZ=11, Caps=WATER, MinWaterDepth=1.5, Flags=0 },
}
