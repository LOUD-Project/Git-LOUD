do
	function UpdateActiveFilters()
		activeFilters = Prefs.GetFromCurrentProfile('activeFilters') or {}
		SetActiveOverlays()
	end
end
