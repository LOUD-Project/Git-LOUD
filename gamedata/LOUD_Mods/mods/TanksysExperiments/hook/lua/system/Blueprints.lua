do
	local oldModBlueprints = ModBlueprints
	
	function ModBlueprints(all_bps)
		oldModBlueprints(all_bps)
		
		-- This test is to experiment with reducing unit sizes.
		
		-- uniform scale is a wonky display value that controls the visual scaling of units.
		-- itterate through all units
		for id, bp in all_bps.Unit do
			-- check for categories
			if bp.Categories then
				-- itterate through all categories on the unit
				for i, cat in bp.Categories do
					-- mobile units
					if cat == "MOBILE" then
						-- check for display and uniform scale
						if bp.Display and bp.Display.UniformScale then
							-- the new scale
							local newScale = bp.Display.UniformScale * 0.66
							-- override the original scale with the new scale
							bp.Display.UniformScale = newScale
						end
					end
				end
			end
		end
	end
end