local CConstructionUnit = import('/lua/cybranunits.lua').CConstructionUnit

URL0208 = Class(CConstructionUnit) {
    Treads = {
        ScrollTreads = true,
        BoneName = 'URL0208',
        TreadMarks = 'tank_treads_albedo',
        TreadMarksSizeX = 0.65,
        TreadMarksSizeZ = 0.4,
        TreadMarksInterval = 0.3,
        TreadOffset = { 0, 0, 0 },
    },
}

TypeClass = URL0208