do
    local UnitOld = Unit
    local BrewLANLOUDPath = import( '/lua/game.lua' ).BrewLANLOUDPath()
    local TerrainUtils = import(BrewLANLOUDPath .. '/lua/TerrainUtils.lua')
    local GetTerrainAngles = TerrainUtils.GetTerrainSlopeAnglesDegrees
    local OffsetBoneToTerrain = TerrainUtils.OffsetBoneToTerrain

    Unit = Class(UnitOld) {
	
        OnStopBeingBuilt = function(self,builder,layer, ...)
		
            local bp = UnitOld.OnStopBeingBuilt(self,builder,layer, unpack(arg))
			
            --local bp = self:GetBlueprint()

            --
            -- For buildings that don't flatten skirt to slope with the terrain
            --
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


            -- Checks for satellite allowances
            if EntityCategoryContains(categories.SATELLITEUPLINK + categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
			
                self:ForkThread( function() WaitTicks(1) self:OnSatelliteCapacityChange() end )
				
            end
			
        end,

        --
        -- Checks for satellite allowances
        --
        OnKilled = function(self, instigator, type, overkillRatio)
		
            if EntityCategoryContains(categories.SATELLITEUPLINK + categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
                self:OnSatelliteCapacityChange(true)
            end
			
            UnitOld.OnKilled(self, instigator, type, overkillRatio)
        end,

        OnDestroy = function(self)
		
            if EntityCategoryContains(categories.SATELLITEUPLINK + categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
                self:OnSatelliteCapacityChange(true)
            end
			
            UnitOld.OnDestroy(self)
        end,
		
        --
        -- Checks for satellite allowances
        --
        OnSatelliteCapacityChange = function(self, deathcheck)
		
            -- Gather data
            local AIBrain = self:GetAIBrain()  -- (entityCategory, needToBeIdle, requireBuilt)
            local uplinks = AIBrain:GetListOfUnits(categories.SATELLITEUPLINK, false, true)
            local satellites = AIBrain:GetListOfUnits(categories.SATELLITEWITHNOPARENTALSUPERVISION, false, false) --requireBuilt true here makes it easy to exceed the cap
			
            -- Remove self from list if death check
            if deathcheck then
			
                if EntityCategoryContains(categories.SATELLITEUPLINK, self) then
                    table.removeByValue(uplinks, self)
                end
				
                if EntityCategoryContains(categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
                    table.removeByValue(satellites, self)
                end
				
            end
			
            -- If this is being called by something dying, check we are allowed satellites
            if deathcheck and table.getn(uplinks) == 0 and table.getn(satellites) > 0 then
			
                for i, v in satellites do
				
                    LOG(v.StartUnguidedOrbitalDecay)
					
                    if v.StartUnguidedOrbitalDecay then
                        v:StartUnguidedOrbitalDecay(v)
                    else
                        v:Kill()
                    end
					
                end
				
            else
                -- calculate if we should allow more construction
				
                -- prep some vars
                local usedcap, maxcap = 0, 0
				
                -- Calculate max capacity
                for i, v in uplinks do
                    maxcap = maxcap + (v:GetBlueprint().General.SatelliteCapacity or 1)
                end
				
                -- calculate used capacity
                for i, v in satellites do
                    usedcap = usedcap + (v:GetBlueprint().General.CapCost or 1)
                    -- Prevent preventable satellite explosions
                    if v.UnguidedOrbitalDecay then
                        v:StopUnguidedOrbitalDecay(v)
                    end
                end
				
                -- should we allow more?
                -- Doesn't currently take into account the potential for satellites that use more than 1 capacity.
                -- Don't know if I care.
                if (maxcap - usedcap) < 1 then
				
                    --This is done per-unit to prevent any conflicts with R&D unlock satellites, and potential game restrictions.
                    --Is it more costly to check it can actually build, and or build satellites first, or do it and not care?
                    for i, v in uplinks do
					
                        v:AddBuildRestriction(categories.SATELLITEWITHNOPARENTALSUPERVISION)
                    end
					
                else
				
                    for i, v in uplinks do
                        v:RemoveBuildRestriction(categories.SATELLITEWITHNOPARENTALSUPERVISION)
                    end
					
                end
				
                self:RequestRefreshUI() -- worth checking if it actually needs a refresh?
            end
        end,

    }
end
