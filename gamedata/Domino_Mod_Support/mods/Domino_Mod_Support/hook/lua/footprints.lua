
do

local OldSpecFootprints = SpecFootprints
SpecFootprints {
	{ Name = 'Vehicle0x0',   SizeX=0,  SizeZ=0,  Caps=LAND, MaxWaterDepth=25, MaxSlope=0.75, Flags=IgnoreStructures },
	{ Name = 'Amphibious0x0',   SizeX=0,  SizeZ=0,  Caps=LAND|SEABED, MaxWaterDepth=25, MaxSlope=0.75, Flags=IgnoreStructures },
	{ Name = 'WaterLand0x0',   SizeX=0,  SizeZ=0,  Caps=LAND|WATER, MaxWaterDepth=1, MinWaterDepth=0.1, MaxSlope=0.75, Flags=IgnoreStructures },
	{ Name = 'SurfacingSub0x0',   SizeX=0,  SizeZ=0,  Caps=SUB|WATER, MinWaterDepth=1.5, Flags=IgnoreStructures },
	{ Name = 'Water0x0',   SizeX=0,  SizeZ=0,  Caps=WATER, MaxWaterDepth=25, MinWaterDepth=0, MaxSlope=0.75, Flags=IgnoreStructures },
}

end
