do
    local UnitOld = Unit
    local BrewLANLOUDPath = import( '/lua/game.lua' ).BrewLANLOUDPath()
    local TerrainUtils = import(BrewLANLOUDPath .. '/lua/TerrainUtils.lua')
    local GetTerrainAngles = TerrainUtils.GetTerrainSlopeAnglesDegrees
    local OffsetBoneToTerrain = TerrainUtils.OffsetBoneToTerrain

    Unit = Class(UnitOld) {
	
        OnStopBeingBuilt = function(self,builder,layer, ...)
		
            local bp = UnitOld.OnStopBeingBuilt(self,builder,layer, unpack(arg))

            -- For buildings that don't flatten skirt to slope with the terrain
            if not bp.Physics.FlattenSkirt and bp.Physics.SlopeToTerrain and not self.TerrainSlope and self:GetCurrentLayer() != 'Water' then
			
                local Angles = GetTerrainAngles(self:GetPosition(),{bp.Footprint.SizeX or bp.Physics.SkirtSizeX, bp.Footprint.SizeZ or bp.Physics.SkirtSizeZ})
                local Axis1, Axis2 = 'z', 'x'
                local Axis = bp.Physics.SlopeToTerrainAxis
				
                if Axis then
                    Axis1 = Axis.Axis1 or Axis1
                    Axis2 = Axis.Axis2 or Axis2
                end
				
                if Axis.InvertAxis then
                    for i, v in Angles do
                        if Axis.InvertAxis[i] then
                            Angles[i] = -v
                        end
                    end
                end
				
                self.TerrainSlope = {
					--CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
                    CreateRotator(self, 0, Axis1, -Angles[1], 1000, 1000, 1000),
                    CreateRotator(self, 0, Axis2, Angles[2], 1000, 1000, 1000)
                }
				
            end
			
            if not bp.Physics.FlattenSkirt and bp.Physics.AltitudeToTerrain then
			
                if not self.TerrainSlope then
                    self.TerrainSlope = {}
                end
				
                for i, v in bp.Physics.AltitudeToTerrain do
				
                    if type(v) == 'string' then
                        OffsetBoneToTerrain(self,v)
                    elseif type(v) == 'table' then
                        OffsetBoneToTerrain(self,v[1])
                    end
					
                end
            end

		
        end,

    }
end
