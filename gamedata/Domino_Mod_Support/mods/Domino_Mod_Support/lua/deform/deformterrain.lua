#in order of aperance
#chose deformation type code for all deform functions
#artilery deformation code for most weapons
#code to deform the terain

#-------------------------------------------------------------------------
#chose deformation type code
#-------------------------------------------------------------------------

#types
#artilery
#nuke?
#czar beam
#czar die


#deformsettings = {
#
#	artilery = {     -- deforms a crater for standard artilery
#	radiusI = 5,  -- Radius of inner bowl
#	radiusO = 6,   -- Width of outer mound
#	depth = 2,   -- Depth of bowl
#	mound = 1   -- Height of mound
#	}
#
#	Beam = {
#	radius = 5,  -- Radius of crater
#	rate = 1 -- deduction in height per second
#	}
#
#	CZAR = {
#	rotation = 180 --rotation of czar
#	}
#
#}


Deform = function(x, z, deformsettings)
	if deformsettings.artilery then
		local artilery = deformsettings.artilery
		LOG('artilery crater at --> '..x..' , '..z)
		artilerycrater(x,z,artilery.radiusI, artilery.radiusO, artilery.Depth, artilery.mound)
	else
		PrintText("deformsetings incorrect",20,'FFFFFFFF',10,'center')
	end
end

#-------------------------------------------------------------------------
#artilery deformation code
#-------------------------------------------------------------------------

artilerycrater = function(x,z,radiusI,radiusO,depth,mound)
	local modheights = {}
	zonesize = 1
	x = math.floor(x)
	z = math.floor(z)
	local totalradius = radiusI+radiusO
	--Calculate all height changes
		for j = -totalradius, totalradius-1 do
			for k = -totalradius, totalradius-1 do
			local radius = VDist2(j+25, k+25, 25, 25)
				if radius < totalradius then
					local heightmod = 0

					if radius < radiusI then
						-- Inner bowl
						heightmod = -(math.sqrt(radiusI*radiusI - radius*radius)) * depth / radiusI
					else
						-- Outer berm
						if radiusO > 0 then
							local r2 = totalradius - radius
							heightmod = math.sqrt(radiusO*radiusO - r2*r2) * mound / radiusO
						end
					end
					local height = GetTerrainHeight(x + j, z + k)
					modheights[table.getn(modheights)+1] = {x+j, z+k,heightmod, height}

				end
			end
		end
		PerformModifications(modheights)
end

#-------------------------------------------------------------------------
#master deformer code
#-------------------------------------------------------------------------

function PerformModifications(modheights)
	local sizeX, sizeZ = GetMapSize()
	records = table.getn(modheights)
		for row = 1, records do
#		gather data from table
		teraindat = modheights[row]
		local x = teraindat[1]
		local z = teraindat[2]
		local heightmod = teraindat[3]
		local height = teraindat[4]
		FlattenMapRect(x, z, 0, 0, height + heightmod)				
		end
end
